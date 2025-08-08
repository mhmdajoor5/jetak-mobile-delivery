import 'dart:async';
import 'package:deliveryboy/src/helpers/driver_status_helper.dart';
import 'package:deliveryboy/src/models/food_order.dart';
import 'package:deliveryboy/src/models/pending_order_model.dart';
import 'package:deliveryboy/src/models/route_argument.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/order_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';

class OrdersWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  const OrdersWidget({super.key, this.parentScaffoldKey});

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends StateMVC<OrdersWidget> {
  late OrderController _con;
  Timer? _refreshTimer;
  DateTime _lastRefresh = DateTime.now();

  _OrdersWidgetState() : super(OrderController()) {
    _con = (controller as OrderController?)!;
  }

  @override
  void initState() {
    _con.listenForOrders();
    _con.updateCurrentUserStatus(DriverStatusUtil.driverStatus);
    _startAutoRefresh();
    super.initState();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 180), (timer) {
      if (_con.driverAvailability) {
        _con.refreshOrders();
        setState(() {
          _lastRefresh = DateTime.now();
        });
      }
    });
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black87),
          onPressed: () => widget.parentScaffoldKey?.currentState!.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '🚚 Delivery Orders',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          ShoppingCartButtonWidget(
            iconColor: Colors.black87,
            labelColor: Colors.red,
          ),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _con.refreshOrders();
          setState(() {
            _lastRefresh = DateTime.now();
          });
        },
        color: Colors.green,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column( 
            children: <Widget>[
              // Driver Status Card
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue[600], size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Driver Status",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _con.driverAvailability
                                    ? Colors.green
                                    : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _con.driverAvailability ? "AVAILABLE" : "OFFLINE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          _con.driverAvailability
                              ? Icons.check_circle
                              : Icons.cancel,
                          color:
                              _con.driverAvailability
                                  ? Colors.green
                                  : Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _con.driverAvailability
                                ? "You're online and ready to receive pendingOrdersModel"
                                : "You're offline and won't receive new pendingOrdersModel",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        CupertinoSwitch(
                          value: _con.driverAvailability,
                          onChanged: (value) {
                            _con.updateCurrentUserStatus(value);
                          },
                          activeTrackColor: Colors.green,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // pendingOrdersModel Count Header
              if (_con.pendingOrdersModel.isNotEmpty)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "${_con.pendingOrdersModel.length} New Order${_con.pendingOrdersModel.length > 1 ? 's' : ''} Available",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "LIVE",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.update, color: Colors.grey[600], size: 12),
                          SizedBox(width: 4),
                          Text(
                            "Last updated: ${_getTimeAgo(_lastRefresh)}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                          Spacer(),
                          Text(
                            "Auto-refresh: ON",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // pendingOrdersModel List
              if (_con.pendingOrdersModel.isEmpty) EmptyOrdersWidget() else Column(
                    children: [
                      SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _con.pendingOrdersModel.length,
                        itemBuilder: (context, index) {
                          final order = _con.pendingOrdersModel[index];

                          // Debugging: Print detailed order information
                          print('🖼️ UI Display Debug - Order $index:');
                          print('  - Order ID: ${order.orderId}');
                          print('  - Customer Name (getter): ${order.customerName}');
                          print('  - User Name (direct): ${order.user.name}');
                          print('  - User Object: ${order.user}');
                          print('  - Address (getter): ${order.address}');
                          print('  - Delivery Address: ${order.deliveryAddress}');
                          print('  - Delivery Address Text: ${order.deliveryAddress?.address}');
                          print('  - Tax: ${order.tax}');
                          print('  - Delivery Fee: ${order.deliveryFee}');
                          print('  - Food Orders Count: ${order.foodOrders.length}');
                          
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.green.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                children: [
                                  // Header Section with Order ID and Amount
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.green[50]!, Colors.green[100]!],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green[600],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.receipt_long,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Order #${order.orderId}',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green[800],
                                                ),
                                              ),
                                              Text(
                                                'طلب جديد • ${order.foodOrders.length} عنصر',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green[600],
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.green.withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            '${(order.tax + order.deliveryFee).toStringAsFixed(2)} ₪',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Content Section
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        // Customer Information Card
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[100],
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.blue[700],
                                                  size: 16,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      order.customerName ?? "اسم غير متوفر",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                        color: order.customerName != null 
                                                            ? Colors.blue[800] 
                                                            : Colors.red[600],
                                                      ),
                                                    ),
                                                    if (order.user.phone != null && order.user.phone!.isNotEmpty)
                                                      Text(
                                                        order.user.phone!,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.blue[600],
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              if (order.user.phone != null && order.user.phone!.isNotEmpty)
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.green[100],
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.call,
                                                      color: Colors.green[700],
                                                      size: 18,
                                                    ),
                                                    onPressed: () {
                                                      // Call functionality
                                                    },
                                                    padding: EdgeInsets.all(6),
                                                    constraints: BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        
                                        SizedBox(height: 12),
                                        
                                        // Address Information Card
                                        Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.orange.withValues(alpha: 0.2),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange[100],
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  Icons.location_on,
                                                  color: Colors.orange[700],
                                                  size: 16,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  order.address ?? "عنوان غير متوفر",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: order.address != "Address not available"
                                                        ? Colors.orange[800]
                                                        : Colors.red[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[100],
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.directions,
                                                    color: Colors.blue[700],
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pushNamed(
                                                      '/OrderTracking',
                                                      arguments: RouteArgument(
                                                        param:{"current_order" :order,"pending_orders" :_con.pendingOrdersModel, },
                                                        id: order.orderId.toString(),
                                                      ),
                                                    );
                                                                                                    },
                                                  padding: EdgeInsets.all(6),
                                                  constraints: BoxConstraints(
                                                    minWidth: 32,
                                                    minHeight: 32,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        SizedBox(height: 16),
                                        
                                        // Enhanced Action Buttons
                                        Row(
                                          children: [
                                            // Show Order Button with clean and Detailed design
                                            Expanded(
                                              child: SizedBox(
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: () => _showOrderDetailsBottomSheet(context, order),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blue[600],
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shadowColor: Colors.blue.withValues(alpha: 0.3),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                  ),
                                                  child: Icon(Icons.remove_red_eye_rounded , color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),

                                            // Accept Button with enhanced design
                                            Expanded(
                                              child: SizedBox(
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: () => _showAcceptBottomSheet(context, order),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green[600],
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shadowColor: Colors.green.withValues(alpha: 0.3),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.check_circle, size: 20),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'قبول',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            SizedBox(width: 12),
                                            
                                            // Reject Button with enhanced design
                                            Expanded(
                                              child: SizedBox(
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: () => _showRejectBottomSheet(context, order),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red[600],
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shadowColor: Colors.red.withValues(alpha: 0.3),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.cancel, size: 20),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'رفض',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 100), // Space for bottom navigation
                    ],
                  ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          _con.pendingOrdersModel.isEmpty
              ? null
              : FloatingActionButton(
                onPressed: () {
                  _con.refreshOrders();
                  setState(() {
                    _lastRefresh = DateTime.now();
                  });
                },
                backgroundColor: Colors.green,
                tooltip: 'Refresh pendingOrdersModel',
                child: Icon(Icons.refresh, color: Colors.white),
              ),
    );
  }
void _showAcceptBottomSheet(BuildContext context, PendingOrderModel order) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      margin: EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            margin: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'قبول الطلب',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'تأكيد قبول طلب العميل',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Order Info Card
          Container(
            margin: EdgeInsets.all(24),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              children: [
                _buildInfoRow('رقم الطلب', '#${order.orderId}', Colors.green[700]),
                SizedBox(height: 12),
                _buildInfoRow('العميل', order.customerName ?? 'غير محدد', Colors.black87),
                SizedBox(height: 12),
                _buildInfoRow('المبلغ', '${(order.tax + order.deliveryFee).toStringAsFixed(2)} ₪', Colors.green[700]),
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 34),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'قبول الطلب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  if (result == true) {
    _showLoadingBottomSheet(context, 'جاري قبول الطلب...');
    await _con.acceptOrder(order.orderId.toString());
    Navigator.of(context).pop(); // Close loading bottom sheet
  }
}

void _showRejectBottomSheet(BuildContext context, PendingOrderModel order) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      margin: EdgeInsets.only(top: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Container(
            margin: EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.cancel_outlined,
                    color: Colors.red[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رفض الطلب',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'سيتم إشعار العميل برفض الطلب',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Order Info Card
          Container(
            margin: EdgeInsets.all(24),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              children: [
                _buildInfoRow('رقم الطلب', '#${order.orderId}', Colors.red[700]),
                SizedBox(height: 12),
                _buildInfoRow('العميل', order.customerName ?? 'غير محدد', Colors.black87),
              ],
            ),
          ),
          
          // Action Buttons
          Container(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 34),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'رفض الطلب',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  if (result == true) {
    _showLoadingBottomSheet(context, 'جاري رفض الطلب...');
    await _con.rejectOrder(order.orderId.toString());
    Navigator.of(context).pop(); // Close loading bottom sheet
  }
}

// Helper method for info rows
Widget _buildInfoRow(String label, String value, Color? valueColor) {
  return Row(
    children: [
      Text(
        '$label: ',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[700],
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ),
    ],
  );
}

// Loading bottom sheet helper
void _showLoadingBottomSheet(BuildContext context, String message) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
            ),
            SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
void _showOrderDetailsBottomSheet(BuildContext context, PendingOrderModel order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل الطلب #${order.orderId}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                         order.updatedAt  ,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.orderStatus.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(order.orderStatus.status),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(order.orderStatus.status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Information
                    _buildSectionCard(
                      title: 'معلومات العميل',
                      icon: Icons.person_outline,
                      color: Colors.blue,
                      children: [
                        _buildDetailRow('الاسم', order.customerName ?? 'غير محدد'),
                        if (order.user.phone != null) ...[
                          SizedBox(height: 12),
                          _buildDetailRow('الهاتف', order.user.phone!),
                        ],
                        ...[
                        SizedBox(height: 12),
                        _buildDetailRow('البريد الإلكتروني', order.user.email),
                      ],
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Delivery Information
                    _buildSectionCard(
                      title: 'معلومات التوصيل',
                      icon: Icons.location_on_outlined,
                      color: Colors.orange,
                      children: [
                        _buildDetailRow('العنوان', order.deliveryAddress?.address ?? 'غير محدد'),
                        if (order.hint != null) ...[
                          SizedBox(height: 12),
                          _buildDetailRow('ملاحظات التوصيل', order.hint!),
                        ],
                        // SizedBox(height: 12),
                        // _buildDetailRow('وقت التوصيل المطلوب', order. ?? 'في أقرب وقت'),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Order Items
                    _buildSectionCard(
                      title: 'عناصر الطلب',
                      icon: Icons.shopping_bag_outlined,
                      color: Colors.green,
                      children: [
                        if (order.foodOrders.isNotEmpty) ...[
                          ...order.foodOrders.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            return Column(
                              children: [
                                if (index > 0) ...[
                                  SizedBox(height: 12),
                                  Divider(color: Colors.grey[200], height: 1),
                                  SizedBox(height: 12),
                                ],
                                _buildOrderItem(item),
                              ],
                            );
                          }),
                        ] else ...[
                          Text(
                            'لا توجد عناصر في الطلب',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Payment Summary
                    _buildSectionCard(
                      title: 'ملخص الدفع',
                      icon: Icons.payment_outlined,
                      color: Colors.purple,
                      children: [
                        _buildDetailRow('المجموع الفرعي', '${order.foodOrders.fold<double>(0, (sum, order) => sum + (order.price??0) * (order.quantity??1)).toStringAsFixed(2)} ₪'),
                        SizedBox(height: 12),
                        _buildDetailRow('الضريبة', '${order.tax.toStringAsFixed(2)} ₪'),
                        SizedBox(height: 12),
                        _buildDetailRow('رسوم التوصيل', '${order.deliveryFee.toStringAsFixed(2)} ₪'),
                        if (order.deliveryFee > 0) ...[
                          SizedBox(height: 12),
                          _buildDetailRow('الضريبة', '-${order.tax.toStringAsFixed(2)} ₪', 
                            valueColor: Colors.green[600]),
                        ],
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'المجموع الكلي',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${order.foodOrders.fold<double>(0, (sum, order) => sum + (order.price??0) * (order.quantity??1)).toInt() + order.tax.toInt() + order.deliveryFee.toInt()} ₪',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    if (order.hint != null) ...[
                      SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'ملاحظات إضافية',
                        icon: Icons.note_outlined,
                        color: Colors.grey,
                        children: [
                          Text(
                            order.hint!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
          ],
        ),
      ),
    ),
  );
}

// Helper method to build section cards
Widget _buildSectionCard({
  required String title,
  required IconData icon,
  required MaterialColor color,
  required List<Widget> children,
}) {
  return Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey[200]!),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color[600],
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ...children,
        
      ],
    ),
  );
}

// Helper method for detail rows
Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 100,
        child: Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ),
      Expanded(
        child: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.black87,
            height: 1.3,
          ),
        ),
      ),
    ],
  );
}

// Helper method for order items
Widget _buildOrderItem(FoodOrder item) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child:Icon(
                    Icons.fastfood_outlined,
                    color: Colors.grey[600],
                    size: 24,
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.food?.name ?? 'عنصر غير محدد',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                
                ],
             
            ),
          ),
        ],
      ),

            Row(
              children: [
                Text(
                  'الكمية: ${item.quantity ?? 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                Text(
                  '${((item.price??0)* (item.quantity ?? 1)).toStringAsFixed(2)} ₪',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,  
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
    
    ],
  );
}

// Helper methods for status and date formatting
Color _getStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'accepted':
      return Colors.green;
    case 'rejected':
      return Colors.red;
    case 'delivered':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

String _getStatusText(String? status) {
  switch (status?.toLowerCase()) {
    case 'pending':
      return 'في الانتظار';
    case 'accepted':
      return 'مقبول';
    case 'rejected':
      return 'مرفوض';
    case 'delivered':
      return 'تم التوصيل';
    default:
      return 'غير محدد';
  }
}

String _formatOrderDate(DateTime? date) {
  if (date == null) return 'تاريخ غير محدد';
  
  final now = DateTime.now();
  final difference = now.difference(date);
  
  if (difference.inDays == 0) {
    return 'اليوم ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } else if (difference.inDays == 1) {
    return 'أمس ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } else {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
}