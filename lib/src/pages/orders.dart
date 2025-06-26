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

  OrdersWidget({super. key,  this.parentScaffoldKey}) ;

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends StateMVC<OrdersWidget> {
 late OrderController _con;

  _OrdersWidgetState() : super(OrderController()) {
    _con = (controller as OrderController?)!;
  }

  @override
  void initState() {
    _con.listenForOrders();
    _con.updateCurrentUserStatus(DriverStatusUtil.driverStatus);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey?.currentState!.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).orders,
          style:  TextStyle(letterSpacing: 1.3),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Colors.black54),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshOrders,
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 10),
          children: <Widget>[
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Center(
                      child: Text(
                    "Driver Status: ${_con.driverAvailability ? "Available" : "Not Available"}",
                    style: Theme.of(context).textTheme.bodyLarge,
                  )),
                  Center(
                    child: Switch(
                      value: _con.driverAvailability,
                      onChanged: (value) {
                        _con.updateCurrentUserStatus(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            _con.orders.isEmpty
                ? EmptyOrdersWidget()
                : ListView.separated(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: _con.orders.length,
                    itemBuilder: (context, index) {
                      var _order = _con.orders.elementAt(index);
                      return OrderItemWidget(
                          expanded: index == 0 ? true : false, order: _order);
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 20);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
