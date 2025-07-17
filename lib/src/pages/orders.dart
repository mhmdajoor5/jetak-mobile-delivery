import 'dart:async';
import 'package:deliveryboy/src/elements/OrderItemWidget.dart';
import 'package:deliveryboy/src/helpers/driver_status_helper.dart';
import 'package:deliveryboy/src/models/pending_order_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';

class OrdersWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  OrdersWidget({super.key, this.parentScaffoldKey});

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
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
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
          '🚚 Delivery pendingOrdersModel',
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
                      color: Colors.black.withOpacity(0.1),
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
                          activeColor: Colors.green,
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
              _con.pendingOrdersModel.isEmpty
                  ? EmptyOrdersWidget()
                  : Column(
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
                                              color: Colors.orange.withOpacity(0.2),
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
                                                    color: order.address != null && 
                                                           order.address != "Address not available"
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
                                                    // Directions functionality
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
                                            // Accept Button with enhanced design
                                            Expanded(
                                              child: Container(
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: () => _showAcceptDialog(context, order),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.green[600],
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shadowColor: Colors.green.withOpacity(0.3),
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
                                              child: Container(
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: () => _showRejectDialog(context, order),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red[600],
                                                    foregroundColor: Colors.white,
                                                    elevation: 0,
                                                    shadowColor: Colors.red.withOpacity(0.3),
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
                child: Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Refresh pendingOrdersModel',
              ),
    );
  }

     void _showAcceptDialog(BuildContext context, PendingOrderModel order) async {
     final confirmed = await showDialog<bool>(
       context: context,
       barrierDismissible: false,
       builder: (context) => AlertDialog(
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(16),
         ),
         title: Container(
           padding: EdgeInsets.all(12),
           decoration: BoxDecoration(
             color: Colors.green[50],
             borderRadius: BorderRadius.circular(8),
           ),
           child: Row(
             children: [
               Container(
                 padding: EdgeInsets.all(6),
                 decoration: BoxDecoration(
                   color: Colors.green[600],
                   borderRadius: BorderRadius.circular(6),
                 ),
                 child: Icon(Icons.check_circle, color: Colors.white, size: 20),
               ),
               SizedBox(width: 12),
               Expanded(
                 child: Text(
                   'تأكيد قبول الطلب',
                   style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                     color: Colors.green[800],
                   ),
                 ),
               ),
             ],
           ),
         ),
         content: Container(
           padding: EdgeInsets.symmetric(vertical: 8),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 'هل تريد قبول هذا الطلب؟',
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w500,
                   color: Colors.black87,
                 ),
               ),
               SizedBox(height: 12),
               Container(
                 padding: EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.grey[50],
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.grey[200]!),
                 ),
                 child: Column(
                   children: [
                     Row(
                       children: [
                         Text('رقم الطلب: ', style: TextStyle(fontWeight: FontWeight.w500)),
                         Text('#${order.orderId}', style: TextStyle(color: Colors.green[700])),
                       ],
                     ),
                     SizedBox(height: 4),
                     Row(
                       children: [
                         Text('العميل: ', style: TextStyle(fontWeight: FontWeight.w500)),
                         Expanded(child: Text(order.customerName ?? 'غير محدد')),
                       ],
                     ),
                     SizedBox(height: 4),
                     Row(
                       children: [
                         Text('المبلغ: ', style: TextStyle(fontWeight: FontWeight.w500)),
                         Text('${(order.tax + order.deliveryFee).toStringAsFixed(2)} ₪', 
                              style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                       ],
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(false),
             child: Text(
               'إلغاء',
               style: TextStyle(
                 color: Colors.grey[600],
                 fontSize: 16,
               ),
             ),
           ),
           ElevatedButton(
             onPressed: () => Navigator.of(context).pop(true),
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.green[600],
               foregroundColor: Colors.white,
               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(8),
               ),
             ),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(Icons.check, size: 18),
                 SizedBox(width: 6),
                 Text('قبول الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               ],
             ),
           ),
         ],
       ),
     );
     
     if (confirmed == true) {
       // Show loading dialog
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (context) => AlertDialog(
           content: Row(
             children: [
               CircularProgressIndicator(),
               SizedBox(width: 16),
               Text('جاري قبول الطلب...'),
             ],
           ),
         ),
       );
       
       await _con.acceptOrder(order.orderId.toString());
       Navigator.of(context).pop(); // Close loading dialog
     }
   }

   void _showRejectDialog(BuildContext context, PendingOrderModel order) async {
     final confirmed = await showDialog<bool>(
       context: context,
       barrierDismissible: false,
       builder: (context) => AlertDialog(
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(16),
         ),
         title: Container(
           padding: EdgeInsets.all(12),
           decoration: BoxDecoration(
             color: Colors.red[50],
             borderRadius: BorderRadius.circular(8),
           ),
           child: Row(
             children: [
               Container(
                 padding: EdgeInsets.all(6),
                 decoration: BoxDecoration(
                   color: Colors.red[600],
                   borderRadius: BorderRadius.circular(6),
                 ),
                 child: Icon(Icons.cancel, color: Colors.white, size: 20),
               ),
               SizedBox(width: 12),
               Expanded(
                 child: Text(
                   'تأكيد رفض الطلب',
                   style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                     color: Colors.red[800],
                   ),
                 ),
               ),
             ],
           ),
         ),
         content: Container(
           padding: EdgeInsets.symmetric(vertical: 8),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 'هل تريد رفض هذا الطلب؟',
                 style: TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w500,
                   color: Colors.black87,
                 ),
               ),
               SizedBox(height: 8),
               Text(
                 'سيتم إشعار العميل برفض الطلب',
                 style: TextStyle(
                   fontSize: 14,
                   color: Colors.grey[600],
                 ),
               ),
               SizedBox(height: 12),
               Container(
                 padding: EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.grey[50],
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: Colors.grey[200]!),
                 ),
                 child: Column(
                   children: [
                     Row(
                       children: [
                         Text('رقم الطلب: ', style: TextStyle(fontWeight: FontWeight.w500)),
                         Text('#${order.orderId}', style: TextStyle(color: Colors.red[700])),
                       ],
                     ),
                     SizedBox(height: 4),
                     Row(
                       children: [
                         Text('العميل: ', style: TextStyle(fontWeight: FontWeight.w500)),
                         Expanded(child: Text(order.customerName ?? 'غير محدد')),
                       ],
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(false),
             child: Text(
               'إلغاء',
               style: TextStyle(
                 color: Colors.grey[600],
                 fontSize: 16,
               ),
             ),
           ),
           ElevatedButton(
             onPressed: () => Navigator.of(context).pop(true),
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.red[600],
               foregroundColor: Colors.white,
               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
               shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(8),
               ),
             ),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(Icons.close, size: 18),
                 SizedBox(width: 6),
                 Text('رفض الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
               ],
             ),
           ),
         ],
       ),
     );
     
     if (confirmed == true) {
       // Show loading dialog
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (context) => AlertDialog(
           content: Row(
             children: [
               CircularProgressIndicator(),
               SizedBox(width: 16),
               Text('جاري رفض الطلب...'),
             ],
           ),
         ),
       );
       
       await _con.rejectOrder(order.orderId.toString());
       Navigator.of(context).pop(); // Close loading dialog
     }
  }
}
