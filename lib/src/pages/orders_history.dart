import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';

class OrdersHistoryWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  const OrdersHistoryWidget({super.key, required this.parentScaffoldKey});

  @override
  _OrdersHistoryWidgetState createState() => _OrdersHistoryWidgetState();
}

class _OrdersHistoryWidgetState extends StateMVC<OrdersHistoryWidget> {
  late OrderController _con;

  _OrdersHistoryWidgetState() : super(OrderController()) {
    _con = (controller as OrderController?)!;
  }

  @override
  void initState() {
    _con.listenForOrdersHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Scaffold(
      key: _con.scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState!.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          ShoppingCartButtonWidget(
            iconColor: Theme.of(context).hintColor,
            labelColor: Colors.black54,
          ),
        ],
        centerTitle: true,
        title: Text(
          S.of(context).orders_history,
          style: TextStyle(letterSpacing: 1.3),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _con.refreshOrdersHistory,
        child: ListView(
          shrinkWrap: true,
          primary: true,
          padding: EdgeInsets.symmetric(vertical: 10),
          children: <Widget>[
            _con.orders.isEmpty
                ? EmptyOrdersWidget()
                : ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  primary: false,
                  itemCount:
                      _con.orders
                          .where((e) => e.orderStatus?.status == 'Delivered')
                          .length,
                  itemBuilder: (context, index) {
                    var _order = _con.orders
                        .where((e) => e.orderStatus?.status == 'Delivered')
                        .elementAt(index);
                    return OrderItemWidget(
                      expanded: index == 0 ? true : false,
                      order: _order,
                    );
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
