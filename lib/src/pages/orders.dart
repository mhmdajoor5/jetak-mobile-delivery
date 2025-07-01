import 'dart:async';
import 'package:deliveryboy/src/elements/OrderItemWidget.dart';
import 'package:deliveryboy/src/helpers/driver_status_helper.dart';
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
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
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
                        Icon(
                          Icons.person,
                          color: Colors.blue[600],
                          size: 20,
                        ),
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
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _con.driverAvailability ? Colors.green : Colors.red,
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
                          _con.driverAvailability ? Icons.check_circle : Icons.cancel,
                          color: _con.driverAvailability ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _con.driverAvailability 
                              ? "You're online and ready to receive orders"
                              : "You're offline and won't receive new orders",
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

              // Orders Count Header
              if (_con.orders.isNotEmpty)
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
                          Icon(Icons.notifications_active, color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "${_con.orders.length} New Order${_con.orders.length > 1 ? 's' : ''} Available",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

              // Orders List
              _con.orders.isEmpty
                  ? EmptyOrdersWidget()
                  : Column(
                      children: [
                        SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _con.orders.length,
                          itemBuilder: (context, index) {
                            var _order = _con.orders.elementAt(index);
                            return OrderItemWidget(
                              expanded: index == 0 ? true : false,
                              order: _order,
                              orderController: _con,
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
      floatingActionButton: _con.orders.isEmpty ? null : FloatingActionButton(
        onPressed: () {
          _con.refreshOrders();
          setState(() {
            _lastRefresh = DateTime.now();
          });
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Refresh Orders',
      ),
    );
  }
}
