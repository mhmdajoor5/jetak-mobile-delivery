import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deliveryboy/src/constants/theme/colors_manager.dart';
import 'package:deliveryboy/src/controllers/order_history_controller.dart';
import 'package:deliveryboy/src/models/order.dart';
import 'package:deliveryboy/src/models/order_status.dart';
import 'package:deliveryboy/src/models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  Timer? _locationUpdateTimer;
  String? _currentActiveOrderId;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }
  
  void _startLocationUpdates(String orderId) {
    print('📍 Starting location updates for order: $orderId');
    
    // Cancel any existing timer
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    
    // Set the current active order ID
    _currentActiveOrderId = orderId;
    
    // Request location permissions first
    _checkLocationPermission().then((hasPermission) {
      if (!hasPermission) {
        print('❌ Location permission not granted for order $orderId');
        return;
      }
      
      print('✅ Location permission granted, starting timer...');
      
      // Start a new timer that updates location every 10 seconds
      _locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        if (!mounted) {
          print('⚠️ Widget not mounted, cancelling timer');
          timer.cancel();
          return;
        }
        
        if (_currentActiveOrderId == null) {
          print('⚠️ No active order ID, cancelling timer');
          timer.cancel();
          return;
        }
        
        print('🔄 Updating location for order: $_currentActiveOrderId');
        
        try {
          // Get current position with high accuracy
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          
          print('📍 Got position: ${position.latitude}, ${position.longitude}');
          
          // Update driver location
          await orderRepo.updateOrderDriverLocation(
            position.latitude,
            position.longitude,
            int.parse(_currentActiveOrderId!),
          );
          
          print('✅ Location updated successfully for order: $_currentActiveOrderId');
        } on LocationServiceDisabledException {
          print('❌ Location services are disabled');
          _showLocationError('Location services are disabled. Please enable them to continue.');
          timer.cancel();
        } on PermissionDeniedException {
          print('❌ Location permissions are denied');
          _showLocationError('Location permissions are required to update your position.');
          timer.cancel();
        } catch (e) {
          print('⚠️ Error updating driver location: $e');
          // Don't stop the timer on error, try again next interval
        }
      });
      
      print('✅ Location update timer started for order: $orderId');
    });
  }
  
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Location services are disabled');
      // Optionally request to enable location services
      return false;
    }
    
    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Location permissions are denied');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      print('❌ Location permissions are permanently denied');
      return false;
    }
    
    return true;
  }
  
  void _showLocationError(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Settings',
          textColor: Colors.white,
          onPressed: () {
            // Open app settings to enable location
            Geolocator.openAppSettings();
          },
        ),
      ),
    );
  }
  
  void _stopLocationUpdates() {
    _locationUpdateTimer?.cancel();
    _currentActiveOrderId = null;
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
        orderStatuses = snapshot.data??[];
        orderStatuses.removeWhere((element) => (element.id!= "3"&&element.id!="4"&&element.id!="5")||(element.status!="Delivered"&&element.status!="Ready"&& element.status!="On the Way" ));
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
      final OrderHistoryModel order = orders[index];
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
                    'طلب رقم: ${order.id}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // Static filter chip (non-clickable)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status??"").withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(order.status??"").withValues(alpha: .3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(order.status??""),
                          size: 16,
                          color: _getStatusColor(order.status??""),
                        ),
                        SizedBox(width: 4),
                        Text(
                          order.status??"",
                          style: TextStyle(
                            color: _getStatusColor(order.status??""),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Client Info
              _buildInfoRow(Icons.person, 'العميل', order.user?.name??'الاسم غير معروف'),
              SizedBox(height: 8),
              _buildInfoRow(Icons.phone, 'الهاتف', order.user?.phone??'الهاتف غير معروف'),
              
              SizedBox(height: 8),
              _buildInfoRow(Icons.location_on, 'العنوان', order.deliveryAddress?.address??'العنوان غير معروف', maxLines: 2),
              
              SizedBox(height: 12),
              Wrap(
                children: List.generate(order.foodOrders?.length ?? 0, (index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: order.foodOrders?[index].food?.media?[0].url ?? '', 
                    width: 50, 
                    height: 50, 
                    errorWidget: (context, url, error) => Column(
                      children: [
                        Icon(Icons.error),
                        Text('No image', style: TextStyle(color: Colors.grey, fontSize: 8)),
                      ],
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(),
                  ), 
                )),
              ), 
              SizedBox(height: 12),
              
              // Bottom Row with Date/Time and Amount
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
              
              SizedBox(height: 16),
              
              // Action Button Row with Enhanced Design
              if (order.status != "Delivered")
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _buildActionButton(order),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

// Enhanced Action Button Widget with States and Animations
Widget _buildActionButton(OrderHistoryModel order) {
  final bool isOnTheWay = order.status == "On the Way";
  final bool isLoading = _loadingOrders.contains(order.id.toString()); // You'll need to add this state variable
  
  return TweenAnimationBuilder<double>(
    duration: Duration(milliseconds: 400),
    tween: Tween(begin: 0.0, end: 1.0),
    curve: Curves.easeInOut,
    builder: (context, scale, child) {
      return Transform.scale(
        scale: scale,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isOnTheWay 
                ? [Colors.green.shade400, Colors.green.shade600]
                : [Colors.blue.shade400, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: (isOnTheWay ? Colors.green : Colors.blue).withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isLoading 
                ? null 
                : (isOnTheWay 
                    ? () => _handleMarkDelivered(order)
                    : () => _handleStartOrder(order)),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: RotationTransition(
                              turns: animation,
                              child: child,
                            ),
                          );
                        },
                        child: Icon(
                          isOnTheWay ? Icons.check_circle_rounded : Icons.rocket_launch_rounded,
                          key: ValueKey(isOnTheWay ? 'delivered' : 'start'),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    
                    SizedBox(width: 12),
                    
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 200),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: Text(
                          isLoading 
                            ? 'Processing...'
                            : (isOnTheWay ? 'Mark as Delivered' : 'Start Order'),
                          key: ValueKey(isLoading 
                            ? 'loading' 
                            : (isOnTheWay ? 'delivered' : 'start')),
                        ),
                      ),
                    ),
                    
                    if (!isLoading) ...[
                      SizedBox(width: 8),
                      AnimatedRotation(
                        duration: Duration(milliseconds: 300),
                        turns: isOnTheWay ? 0 : 0.1,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 18,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// Add this state variable to your class
Set<String> _loadingOrders = {};
Future<void> _handleStartOrder(OrderHistoryModel order,) async {
  print('🚀 1. _handleStartOrder called with order: ${order.id}');
  
  // Validate order data
  if (order == null || order.id == null) {
    print('❌ Invalid order data');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invalid order data')),
    );
    return;
  }
  
  // Show loading indicator
  print('🔄 2. Showing loading dialog');
  bool isLoadingDialogShown = true;
  
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              isLoadingDialogShown = false;
            }
          },
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Updating order status...'),
              ],
            ),
          ),
        );
      },
    );
    
    // Find the "On the Way" status ID from orderStatuses
    print('🔍 3. Finding On the Way status');
    OrderStatus onTheWayStatus;
    try {
      onTheWayStatus = orderStatuses.firstWhere(
        (status) => status.status?.toLowerCase() == "on the way",
        orElse: () {
          print('⚠️ 3a. On the Way status not found by name, falling back to ID 4');
          return orderStatuses.firstWhere(
            (status) => status.id == 4,
            orElse: () => throw Exception('Could not find On the Way status (ID 4)'),
          );
        },
      );
      print('✅ Found status: ${onTheWayStatus.status} (ID: ${onTheWayStatus.id})');
    } catch (e) {
      print('❌ Error finding status: $e');
      throw Exception('Could not determine order status: $e');
    }
    
    print('🚀 4. Starting order: ${order.id} with status ID: ${onTheWayStatus.id}');
    
    // 1. First update the driver's current location
    print('📍 5. Updating driver location...');
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await orderRepo.updateOrderDriverLocation(
        position.latitude,
        position.longitude,
       order.id??0,
      );
      print('✅ Driver location updated');
    } catch (e) {
      print('⚠️ Could not update driver location: $e');
      // Continue even if location update fails
    }
    
    // 2. Update order status to "On the Way"
    print('🔄 6. Updating order status...');
    try {
      print('📤 Calling changeOrderStatus with order ID: ${order.id}, status ID: ${onTheWayStatus.id}');
      final Order updatedOrder = await orderRepo.changeOrderStatus(
        order.id.toString(), 
        onTheWayStatus.id.toString(),
      );
      
      if (updatedOrder == null) {
        throw Exception('Failed to update order status: Server returned null');
      }
      
      print('✅ Order status updated successfully');
      
      // 3. Start periodic location updates for this order
      print('📍 7. Starting periodic location updates...');
      _startLocationUpdates(order.id.toString());
      
      // 4. Update UI state
      setState(()  {
        _currentActiveOrderId = order.id.toString();
      });
        final prefs = await SharedPreferences.getInstance();

        prefs.setInt('last_order_id', order.id??0);
    
      

      // 5. Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order started successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // 6. Refresh the order list
      await _refreshData();
      
    } catch (e) {
      print('❌ Error in changeOrderStatus: $e');
      rethrow;
    }
    
    // Close loading dialog
    Navigator.of(context).pop();
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('last_order_id', order.id??0);
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order started and is now on the way'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    // final PendingOrderModel pendingOrderModel = PendingOrderModel.fromOrderHistoryModel(order);
    // final List<PendingOrderModel> pendingOrdersModel = orders.map((e) => PendingOrderModel.fromOrderHistoryModel(e)).toList();
    if (mounted) {
      print('Navigating to OrderTracking');
      // print('Current Order: ${pendingOrderModel.toJson()}');
      // print('Pending Orders: ${pendingOrdersModel}');
      //  Navigator.of(context).pushNamed(
      //                                                   '/OrderTracking',
      //                                                   arguments: RouteArgument(
      //                                                     param:{"current_order" :pendingOrderModel,"pending_orders" :pendingOrdersModel, },
      //                                                     id: order.orderNumber,
      //                                                   ),
      //                                                 );  
    }
    await _refreshData();
    
  } catch (e) {
    // Close loading dialog if still open
    Navigator.of(context, rootNavigator: true).pop();
    
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to start order: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
    
    print('Error starting order: $e');
  }
}

// Enhanced Handler for Mark as Delivered button with Loading State
Future<void> _handleMarkDelivered(OrderHistoryModel order) async {
  setState(() {
    _loadingOrders.add(order.id.toString());
  });

  try {
    // Find the "Delivered" status ID from orderStatuses
    final deliveredStatus = orderStatuses.firstWhere(
      (status) => status.status == "Delivered",
      orElse: () => orderStatuses.firstWhere((status) => status.id == 5), // Fallback to ID 5
    );
    
    print('Marking order as delivered: ${order.id} with status ID: ${deliveredStatus.id}');      
    
    // Update order status to "Delivered"
    final updatedOrder = await orderRepo.changeOrderStatus(
      order.id.toString(), 
      deliveredStatus.id.toString(),
    );
    
    // Show success message with custom design
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.celebration_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Order Delivered! 🎉',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Customer has received their order',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
      ),
    );
    
    await _refreshData();
    
  } catch (e) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to Mark as Delivered',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    e.toString().length > 50 
                      ? '${e.toString().substring(0, 50)}...'
                      : e.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 4),
      ),
    );
    
    print('Error marking order as delivered: $e');
  } finally {
    setState(() {
      _loadingOrders.remove(order.id.toString());
    });
  }
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
