import 'package:deliveryboy/src/models/order_status.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/ProfileAvatarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';

class ProfileWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  ProfileWidget({super.key, required this.parentScaffoldKey});

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends StateMVC<ProfileWidget> {
  late ProfileController _con;

  _ProfileWidgetState() : super(ProfileController()) {
    _con = (controller as ProfileController?)!;
  }

  @override
  void initState() {
    _con.listenForRecentOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    for (var e in _con.recentOrders) {
      print(e.toString());
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.sort, color: Colors.black54),
          onPressed: () => widget.parentScaffoldKey?.currentState?.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black54,
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          ShoppingCartButtonWidget(
            iconColor: Colors.black54,
            labelColor: Theme.of(context).hintColor,
          ),
        ],
        title: Text(
          S.of(context).profile,
          style: TextStyle(letterSpacing: 1.3, color: Colors.black54),
        ),
      ),

      key: _con.scaffoldKey,
      body:
          _con.user.apiToken == null
              ? CircularLoadingWidget(height: 500)
              : SingleChildScrollView(
                //              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Column(
                  children: <Widget>[
                    ProfileAvatarWidget(user: _con.user),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: Icon(
                        Icons.person,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).about,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _con.user.bio ?? "",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: Icon(
                        Icons.shopping_basket,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).recent_orders,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    _con.recentOrders
                            .where((e) => e.orderStatus?.status == 'Delivered')
                            .isEmpty
                        ? CircularLoadingWidget(height: 200)
                        : ListView.separated(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          primary: false,
                          itemCount:
                              _con.recentOrders
                                  .where(
                                    (e) => e.orderStatus?.status == 'Delivered',
                                  )
                                  .length,
                          itemBuilder: (context, index) {
                            var _order = _con.recentOrders
                                .where(
                                  (e) => e.orderStatus?.status == 'Delivered',
                                )
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
