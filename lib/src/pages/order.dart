import 'package:deliveryboy/src/elements/CircularLoadingWidget.dart';
import 'package:deliveryboy/src/elements/FoodOrderItemWidget.dart';
import 'package:deliveryboy/src/repository/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:map_launcher/map_launcher.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../controllers/order_details_controller.dart';
import '../elements/DrawerWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';

class OrderWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  OrderWidget({super.key, required this.routeArgument}) ;

  @override
  _OrderWidgetState createState() {
    return _OrderWidgetState();
  }
}

class _OrderWidgetState extends StateMVC<OrderWidget>
    with SingleTickerProviderStateMixin {
 late TabController _tabController;
  int _tabIndex = 0;
  late OrderDetailsController _con;

  _OrderWidgetState() : super(OrderDetailsController()) {
    _con = (controller as OrderDetailsController?)!;
  }

  @override
  void initState() {
    _con.listenForOrder(id: widget.routeArgument.id!);
    _tabController =
        TabController(length: 2, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      bottomNavigationBar: _con.order == null
          ? Container(
              height: 193,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.15),
                        offset: Offset(0, -2),
                        blurRadius: 5.0)
                  ]),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
              ),
            )
          : Container(
              height: _con.order.orderStatus!.id == '5' ? 190 : 250,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).focusColor.withOpacity(0.15),
                        offset: Offset(0, -2),
                        blurRadius: 5.0)
                  ]),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.of(context).subtotal,
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        ),
                        Helper.getPrice(
                            Helper.getSubTotalOrdersPrice(_con.order), context,
                            style: Theme.of(context).textTheme. bodySmall)
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.of(context).delivery_fee,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Helper.getPrice(_con.order.deliveryFee ??0.0, context,
                            style: Theme.of(context).textTheme.bodySmall)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${S.of(context).tax} (${_con.order.tax}%)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Helper.getPrice(Helper.getTaxOrder(_con.order), context,
                            style: Theme.of(context).textTheme.bodySmall)
                      ],
                    ),
                    Divider(height: 30),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.of(context).total,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Helper.getPrice(
                            Helper.getTotalOrdersPrice(_con.order), context,
                            style: Theme.of(context).textTheme.bodySmall)
                      ],
                    ),
                    _con.order.orderStatus!.id != '5'
                        ? SizedBox(height: 20)
                        : SizedBox(height: 0),
                    _con.order.orderStatus!.id != '5'
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width - 40,
                            child: MaterialButton(
                              elevation: 0,
                              focusElevation: 0,
                              highlightElevation: 0,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(S
                                            .of(context)
                                            .delivery_confirmation),
                                        content: Text(S
                                            .of(context)
                                            .would_you_please_confirm_if_you_have_delivered_all_meals),
                                        actions: <Widget>[
                                          // usually buttons at the bottom of the dialog
                                          MaterialButton(
                                            elevation: 0,
                                            focusElevation: 0,
                                            highlightElevation: 0,
                                            child:
                                                new Text(S.of(context).confirm),
                                            onPressed: () {
                                              if (_con.order.orderStatus!.id ==
                                                  "3") {
                                                _con.doOnTheWayOrder(
                                                    _con.order);
                                              } else {
                                                _con.doDeliveredOrder(
                                                    _con.order);
                                              }
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          MaterialButton(
                                            elevation: 0,
                                            focusElevation: 0,
                                            highlightElevation: 0,
                                            child:
                                                new Text(S.of(context).dismiss),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                              padding: EdgeInsets.symmetric(vertical: 14),
                              color: Colors.black54,
                              shape: StadiumBorder(),
                              child: Text(
                                _con.order.orderStatus!.id == "3"
                                    ? "Mark as on The way"
                                    : S.of(context).delivered,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Colors.black54),
                              ),
                            ),
                          )
                        : SizedBox(height: 0),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
      body: _con.order == null
          ? CircularLoadingWidget(height: 400)
          : CustomScrollView(slivers: <Widget>[
              SliverAppBar(
                snap: true,
                floating: true,
                automaticallyImplyLeading: false,
                leading: new IconButton(
                  icon:
                      new Icon(Icons.sort, color: Theme.of(context).hintColor),
                  onPressed: () => _con.scaffoldKey?.currentState?.openDrawer(),
                ),
                centerTitle: true,
                title: Text(
                  S.of(context).order_details,
                  style:  TextStyle(letterSpacing: 1.3) ,
                ),
                actions: <Widget>[
                  new ShoppingCartButtonWidget(
                      iconColor: Theme.of(context).hintColor,
                      labelColor: Colors.black54),
                ],
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: 230,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    margin: EdgeInsets.only(top: 95, bottom: 65),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black54.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                            color:
                                Theme.of(context).focusColor.withOpacity(0.1),
                            blurRadius: 5,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).order_id +
                                          ": #${_con.order.id}",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      _con.order.orderStatus?.status ??"",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      DateFormat('yyyy-MM-dd HH:mm')
                                          .format(_con.order.dateTime!),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Helper.getPrice(
                                      Helper.getTotalOrdersPrice(_con.order),
                                      context,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  Text(
                                    _con.order.payment?.method ??
                                        S.of(context).cash_on_delivery,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${S.of(context).items}: ${_con.order?.foodOrders?.length ?? 0}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  collapseMode: CollapseMode.pin,
                ),
                bottom: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelPadding: EdgeInsets.symmetric(horizontal: 10),
                    unselectedLabelColor: Colors.black54,
                    labelColor: Colors.black54,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.black54),
                    tabs: [
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                                  width: 1)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(S.of(context).ordered_foods),
                          ),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                                  width: 1)),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(S.of(context).customer),
                          ),
                        ),
                      ),
                    ]),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Offstage(
                    offstage: 0 != _tabIndex,
                    child: ListView.separated(
                      padding: EdgeInsets.only(top: 20, bottom: 50),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      primary: false,
                      itemCount: _con.order.foodOrders?.length ?? 0,
                      separatorBuilder: (context, index) {
                        return SizedBox(height: 15);
                      },
                      itemBuilder: (context, index) {
                        return FoodOrderItemWidget(
                            heroTag: 'my_orders',
                            order: _con.order,
                            foodOrder: _con.order.foodOrders!.elementAt(index));
                      },
                    ),
                  ),
                  Offstage(
                    offstage: 1 != _tabIndex,
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).fullName,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      _con.order.user?.name ?? "",
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: MaterialButton(
                                  elevation: 0,
                                  focusElevation: 0,
                                  highlightElevation: 0,
                                  padding: EdgeInsets.all(0),
                                  disabledColor: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.4),
                                  //onPressed: () {
//                                    Navigator.of(context).pushNamed('/Profile',
//                                        arguments: new RouteArgument(param: _con.order.deliveryAddress));
                                  //},
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.black54,
                                    size: 24,
                                  ),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.9),
                                  shape: StadiumBorder(), onPressed: () {  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).deliveryAddress,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      _con.order.deliveryAddress?.address ??
                                          S
                                              .of(context)
                                              .address_not_provided_please_call_the_client,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: MaterialButton(
                                  elevation: 0,
                                  focusElevation: 0,
                                  highlightElevation: 0,
                                  padding: EdgeInsets.all(0),
                                  disabledColor: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.4),
                                  onPressed: () async {
                                    Position? position = await _getCurrentPosition();
                                    if(position == null) return;
                                    MapLauncher.showDirections(
                                        mapType: MapType.waze,
                                        destination: Coords(
                                            _con.order.deliveryAddress?.latitude ?? 0.0,
                                            _con.order.deliveryAddress?.longitude ?? 0.0),
                                    origin: Coords(position.latitude, position.longitude));
                                  },
                                  child: Icon(
                                    Icons.directions,
                                    color: Colors.black54,
                                    size: 24,
                                  ),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.9),
                                  shape: StadiumBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 7),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      S.of(context).phoneNumber,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      _con.order.user?.phone ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 42,
                                height: 42,
                                child: MaterialButton(
                                  elevation: 0,
                                  focusElevation: 0,
                                  highlightElevation: 0,
                                  padding: EdgeInsets.all(0),
                                  onPressed: () {
                                    launch("tel:${_con.order.user?.phone}");
                                  },
                                  child: Icon(
                                    Icons.call,
                                    color: Colors.black54,
                                    size: 24,
                                  ),
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.9),
                                  shape: StadiumBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              )
            ]),
    );
  }

  void launchWaze(double lat, double lng) async {
    var url = 'waze://?ll=${lat.toString()},${lng.toString()}';
    var fallbackUrl =
        'https://waze.com/ul?ll=${lat.toString()},${lng.toString()}&navigate=yes';
    try {
      bool launched =
          await launch(url, forceSafariVC: false, forceWebView: false);
      if (!launched) {
        await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
      }
    } catch (e) {
      await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
    }
  }


  Future<Position?> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!(hasPermission == true)) {
      return null;
    }
    final position = await _geolocatorPlatform.getCurrentPosition();
    try {
      await updateDriverLocation(
          position.latitude, position.longitude);
    } catch (e) {
      print(e);
    }

    return position;
  }

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }
}
