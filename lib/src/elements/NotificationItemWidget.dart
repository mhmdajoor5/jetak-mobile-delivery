import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../helpers/helper.dart';
import '../helpers/swipe_widget.dart';
import '../models/notification.dart' as model;
import 'package:mvc_pattern/mvc_pattern.dart';

class NotificationItemWidget extends StatefulWidget {
  final model.Notification notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsUnRead;
  final VoidCallback onRemoved;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onMarkAsUnRead,
    required this.onRemoved,
  });

  @override
  _NotificationItemWidgetState createState() => _NotificationItemWidgetState();
}

class _NotificationItemWidgetState extends StateMVC<NotificationItemWidget> {
  late model.Notification notification;
  late VoidCallback onMarkAsRead;
  late VoidCallback onMarkAsUnRead;
  late VoidCallback onRemoved;

  @override
  void initState() {
    super.initState();
    notification = widget.notification;
    onMarkAsRead = widget.onMarkAsRead;
    onMarkAsUnRead = widget.onMarkAsUnRead;
    onRemoved = widget.onRemoved;
  }

  @override
  Widget build(BuildContext context) {
    return 
    Container(
      height: 100,
      color: Colors.black12,
      child: OnSlide(
      
        backgroundColor: (notification.read ?? false) ? Theme.of(context).scaffoldBackgroundColor : Colors.black54,
        items: <ActionItems>[
          ActionItems(
              icon: (notification.read ?? false)
                  ? Icon(
                      Icons.panorama_fish_eye,
                      color: Theme.of(context).cardColor,
                    )
                  : Icon(
                      Icons.brightness_1,
                      color: Theme.of(context).cardColor,
                    ),
              onPress: () {
                if ((notification.read ?? false)) {
                  onMarkAsUnRead();
                } else {
                  onMarkAsRead();
                }
              },
              backgroundColor: (notification.read ?? false) ? Theme.of(context).scaffoldBackgroundColor : Colors.black54),
          ActionItems(
              icon: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Icon(Icons.delete, color: Theme.of(context).canvasColor),  
              ),
              onPress: () {
                onRemoved();
              },
              backgroundColor: (notification.read ?? false) ? Theme.of(context).scaffoldBackgroundColor : Colors.black54),
        ],
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                          Theme.of(context).focusColor.withOpacity(0.7),
                          Theme.of(context).focusColor.withOpacity(0.05),
                        ])),
                    child: Icon(
                      Icons.notifications,
                      color: (notification.read ?? false) ? Theme.of(context).scaffoldBackgroundColor : Colors.black54,
                      size: 40,
                    ),
                  ),
                  Positioned(
                    right: -30,
                    bottom: -50,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(150),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    top: -50,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(150),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(width: 15),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(
                      
                      Helper.trans(notification.type ??"", context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.justify,
                      style:  TextStyle(fontWeight: (notification.read ?? false) ? FontWeight.w300 : FontWeight.w600),
                    ),
                    Text(
                      DateFormat('yyyy-MM-dd | HH:mm').format(notification.createdAt!),
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
