import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/notification_controller.dart';

class ShoppingCartButtonWidget extends StatefulWidget {
  const ShoppingCartButtonWidget({
   required this.iconColor,
 required   this.labelColor,
    super.key,
  })  ;

  final Color iconColor;
  final Color labelColor;

  @override
  _ShoppingCartButtonWidgetState createState() => _ShoppingCartButtonWidgetState();
}

class _ShoppingCartButtonWidgetState extends StateMVC<ShoppingCartButtonWidget> {
 late NotificationController _con;

  _ShoppingCartButtonWidgetState() : super(NotificationController()) {
    _con = (controller as NotificationController?)!;
  }

  @override
  void initState() {
    //_con.listenForCartsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      onPressed: () {
        Navigator.of(context).pushNamed('/Notifications');
      },
      color: Colors.transparent,
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: <Widget>[
          Icon(
            Icons.notifications_none,
            color: widget.iconColor,
            size: 28,
          ),
          Container(
            padding: EdgeInsets.all(0),
            decoration: BoxDecoration(color: widget.labelColor, borderRadius: BorderRadius.all(Radius.circular(10))),
            constraints: BoxConstraints(minWidth: 13, maxWidth: 13, minHeight: 13, maxHeight: 13),
            child: Text(
              _con.unReadNotificationsCount.toString(),
              textAlign: TextAlign.center,
              style:
                    TextStyle(color: Colors.black54, fontSize: 8, height: 1.3),

            ),
          ),
        ],
      ),
    );
  }
}
