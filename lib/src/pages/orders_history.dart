import 'package:cached_network_image/cached_network_image.dart';
import 'package:deliveryboy/src/constants/theme/colors_manager.dart';
import 'package:deliveryboy/src/models/order_status.dart';
import 'package:flutter/material.dart';
import '../controllers/order_history_controller.dart';
import '../models/order_history_model.dart';
import '../repository/order_repository.dart' as orderRepo;

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final OrderHistoryController controller = OrderHistoryController();
  String selectedStatus = 'delivered'; // Default to delivered orders
  bool isLoading = true;
  List<OrderHistoryModel> orders = [];
  Map<String, dynamic> statistics = {};
  List<OrderStatus> orderStatuses = [];
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    
    try {
      final [ordersList, stats] = await Future.wait([
        controller.getOrdersByStatus(selectedStatus),
        controller.getOrdersStatistics(),
      ]);
      
      setState(() {
        orders = ordersList as List<OrderHistoryModel>;
        statistics = stats as Map<String, dynamic>;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      case 'preparing':
      case 'accepted':
        return Colors.blue;
      case 'ready':
      case 'ready for pickup':
        return Colors.purple;
      case 'on the way':
      case 'in delivery':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel;
      case 'preparing':
      case 'accepted':
        return Icons.restaurant;
      case 'ready':
      case 'ready for pickup':
        return Icons.assignment_turned_in;
      case 'on the way':
      case 'in delivery':
        return Icons.local_shipping;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سجل الطلبات'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _refreshData,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              // Statistics Cards
              if (statistics.isNotEmpty) _buildStatisticsSection(),
              
              // Filter Tabs
              _buildFilterTabs(),
              
              // Orders List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : orders.isEmpty
                        ? _buildEmptyState()
                        : _buildOrdersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      height: 150,
      padding: EdgeInsets.all(16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            'مكتملة',
            '${statistics['total_delivered'] ?? 0}',
            Icons.check_circle,
            Colors.green,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'معلقة',
            '${statistics['total_pending'] ?? 0}',
            Icons.schedule,
            Colors.orange,
          ),
            SizedBox(width: 12),
          _buildStatCard(
            'ملغية',
            '${statistics['total_cancelled'] ?? 0}',
            Icons.cancel,
            Colors.red,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'متوسط سعر الطلب',
            '${statistics['average_order_value'].toStringAsFixed(2) ?? 0}',
            Icons.monetization_on_rounded,
            Colors.blue,
          ),
          SizedBox(width: 12),
          _buildStatCard(
            'الأرباح',
            '${(statistics['total_earnings'] ?? 0.0).toStringAsFixed(0)} ₪',
            Icons.arrow_circle_up_rounded,
            Colors.blue,
          ),
        
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 120,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .6)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return FutureBuilder<List<OrderStatus>>(
      future: orderRepo.debugOrderStatuses(),
      builder:(context, snapshot) {
        if(snapshot.hasData){
        orderStatuses = snapshot.data!;
        return  SizedBox(
          height: 50,
          child: ListView.builder(
            itemCount: orderStatuses.length,
            itemBuilder: (context, index) =>_buildFilterChip(orderStatuses[index].status??"", orderStatuses[index].status??""),
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            
          ),
                
        );
        }else if(snapshot.connectionState==ConnectionState.waiting){
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        else{
          return const Center(child: Text("حدث خطأ"));
        }
      } 
    );
  }

  Widget _buildFilterChip(String status, String label) {
    final isSelected = selectedStatus == status;
    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : ColorsManager.selection, fontSize: 14, fontWeight:isSelected? FontWeight.bold: FontWeight.normal)),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              selectedStatus = status;
            });
            _loadData();
          }
        },
        backgroundColor: ColorsManager.selection.withValues(alpha: .2),
        selectedColor: ColorsManager.selection,
        side: BorderSide(color: ColorsManager.selection),
        checkmarkColor: ColorsManager.success,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('لا يوجد طلبات'),
          SizedBox(height: 8),
          Text(
            'لم يتم العثور على طلبات بهذه الحالة',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: Icon(Icons.refresh),
            label: Text('إعادة التحميل'),
          ),
        ],
      ),
    );
  }
  ///class OrderStatus {
  ///String? id;
  ///String? status;

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'طلب رقم: ${order.orderNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                   PopupMenuButton<Map<String, dynamic>>(
  onSelected: (selectedStatus) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      print('Selected status: ${selectedStatus['status']} with ID: ${selectedStatus['id']}');
      
      // Update order status
      final updatedOrder = await orderRepo.acceptOrderWithStatus(
        order.orderNumber!, 
        selectedStatus['id'].toString(),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to ${selectedStatus['status']}'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    await  _refreshData();
    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context, rootNavigator: true).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      
      print('Error updating order status: $e');
    }
  },
  itemBuilder: (BuildContext context) {
    return orderStatuses.map((status) {
      return PopupMenuItem<Map<String, dynamic>>(
        value: {
          'id': status.id,
          'status': status.status,
        },
        child: Row(
          children: [
            Icon(
              _getStatusIcon(status.status!),
              size: 16,
              color: _getStatusColor(status.status!),
            ),
            SizedBox(width: 8),
            Text(status.status!),
            Spacer(),
            Text(
              'ID: ${status.id}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }).toList();
  },
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: _getStatusColor(order.status).withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: _getStatusColor(order.status).withValues(alpha: .3),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          _getStatusIcon(order.status),
          size: 16,
          color: _getStatusColor(order.status),
        ),
        SizedBox(width: 4),
        Text(
          order.status,
          style: TextStyle(
            color: _getStatusColor(order.status),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        SizedBox(width: 4),
        Icon(
          Icons.arrow_drop_down,
          size: 16,
          color: _getStatusColor(order.status),
        ),
      ],
    ),
  ),
)
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Client Info
                _buildInfoRow(Icons.person, 'العميل', order.clientName),
                SizedBox(height: 8),
                _buildInfoRow(Icons.phone, 'الهاتف', order.phoneNumber),
                SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, 'العنوان', order.deliveryAddress, maxLines: 2),
                
                SizedBox(height: 12),
                Wrap(
                  children: List.generate(order.foodOrders?.length??0, (index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(imageUrl: order.foodOrders?[index].food?.image?.url??'', width: 50, height: 50, 
                    errorWidget: (context, url, error) => Column(
                      children: [
                        Icon(Icons.error),
                        Text('No image', style: TextStyle(color: Colors.grey, fontSize: 8),),
                      ],
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    ), 
                    )),
                ), 
                SizedBox(height: 12),
                // Bottom Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.shortDate,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          order.timeOnly,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      order.formattedAmount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
