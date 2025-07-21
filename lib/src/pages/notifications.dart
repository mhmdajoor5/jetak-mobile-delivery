import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/notification_controller.dart';
import '../elements/DrawerWidget.dart';
import '../elements/EmptyNotificationsWidget.dart';
import '../elements/NotificationItemWidget.dart';

class NotificationsWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState>? parentScaffoldKey;

  const NotificationsWidget({super. key, this.parentScaffoldKey})  ;

  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();
}

class _NotificationsWidgetState extends StateMVC<NotificationsWidget> {
  late NotificationController _con;

  _NotificationsWidgetState() : super(NotificationController()) {
    _con = (controller as NotificationController?)!;
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => _con.scaffoldKey.currentState?.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).notifications,
          style:  TextStyle(letterSpacing: 1.3)),
        ),


      body: RefreshIndicator(
        onRefresh: _con.refreshNotifications,
        child: _con.notifications.isEmpty
            ? EmptyNotificationsWidget()
            : Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.notifications,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).notifications,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      subtitle: Text(
                        S.of(context).swip_left_the_notification_to_delete_or_read__unread,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con.notifications.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 15,);
                      },
                      itemBuilder: (context, index) {
                        return NotificationItemWidget(
                          notification: _con.notifications[index],
                          onMarkAsRead: ()=>
                            _con.doMarkAsReadNotifications(_con.notifications[index]),
                          onMarkAsUnRead: ()=> _con.doMarkAsUnReadNotifications(_con.notifications[index]),
                          onRemoved: ()=> _con.doRemoveNotification(_con.notifications[index]),
                          
                        );
                      } 
                    
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
