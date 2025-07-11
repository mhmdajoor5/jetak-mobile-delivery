import 'dart:async';

import 'package:deliveryboy/src/helpers/FirebaseUtils.dart';
import 'package:deliveryboy/src/helpers/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import '../repository/user_repository.dart' as userRepo;

import '../../generated/l10n.dart';
import '../elements/DrawerWidget.dart';
import '../models/route_argument.dart';
import '../pages/map.dart';
import '../pages/orders.dart';
import '../pages/orders_history.dart';
import '../pages/profile.dart';

// ignore: must_be_immutable
class PagesTestWidget extends StatefulWidget {
  dynamic currentTab;
 late DateTime currentBackPressTime;
 late RouteArgument routeArgument;
  Widget currentPage = OrdersWidget();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  PagesTestWidget({
      super. key,
    this.currentTab,
  }) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else {
      currentTab = 1;
    }
  }

  @override
  _PagesTestWidgetState createState() {
    return _PagesTestWidgetState();
  }
}

class _PagesTestWidgetState extends State<PagesTestWidget> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Timer? timer;

  initState() {
    registerFCM();
    userRepo.updateDriverAvailability(true);
    _getCurrentPosition();
    super.initState();
    _selectTab(widget.currentTab);
    timer = Timer.periodic(Duration(seconds: 15), (Timer t) {
      print("Updating location on -> ${DateTime.now().toString()}");
      _getCurrentPosition();
    });
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!(hasPermission == true)) {
      return;
    }
    final position = await _geolocatorPlatform.getCurrentPosition();
    try {
      await userRepo.updateDriverLocation(
          position.latitude, position.longitude);
    } catch (e) {
      print(e);
    }
  }

  Future<void> registerFCM() async {
    await FirebaseUtil.registerFCM(await userRepo.getCurrentUserAsync());
  }

  @override
  void didUpdateWidget(PagesTestWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem == 3 ? 1 : tabItem;
      switch (tabItem) {
        case 0:
          widget.currentPage =
              ProfileWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 1:
          widget.currentPage =
              OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 2:
          widget.currentPage =
                 OrderHistoryPage();
          break;
        case 3:
          widget.currentPage = MapWidget(
              parentScaffoldKey: widget.scaffoldKey,
              routeArgument: widget.routeArgument);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        body: widget.currentPage,
        bottomNavigationBar: Container(
          height: 85,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, -5),
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.transparent,
              selectedFontSize: 0,
              unselectedFontSize: 0,
              iconSize: 26,
              elevation: 0,
              backgroundColor: Colors.transparent,
              unselectedItemColor: Colors.transparent,
              currentIndex: widget.currentTab,
              onTap: (int i) {
                print(i);
                this._selectTab(i);
              },
              items: [
                // Profile Tab
                BottomNavigationBarItem(
                  icon: _buildNavItem(
                    icon: Icons.person_rounded,
                    isSelected: widget.currentTab == 0,
                    color: Colors.purple[600]!,
                    label: 'Profile',
                  ),
                  label: "",
                ),
                // Home Tab (Center with special design)
                BottomNavigationBarItem(
                  label: "",
                  icon: _buildCenterNavItem(
                    isSelected: widget.currentTab == 1,
                  ),
                ),
                // History Tab
                BottomNavigationBarItem(
                  icon: _buildNavItem(
                    icon: Icons.history_rounded,
                    isSelected: widget.currentTab == 2,
                    color: Colors.orange[600]!,
                    label: 'History',
                  ),
                  label: "",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build regular nav items
  Widget _buildNavItem({
    required IconData icon,
    required bool isSelected,
    required Color color,
    required String label,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSelected ? 12 : 8),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              borderRadius: BorderRadius.circular(isSelected ? 16 : 12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? color : Colors.grey[500],
              size: isSelected ? 26 : 22,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSelected ? 11 : 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? color : Colors.grey[500],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build center nav item (Home)
  Widget _buildCenterNavItem({required bool isSelected}) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(top: isSelected ? 0 : 5),
      child: Container(
        width: isSelected ? 55 : 50,
        height: isSelected ? 55 : 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    Color(0xFF4A90E2),
                    Color(0xFF357ABD),
                    Color(0xFF2E6DA4),
                  ]
                : [
                    Colors.grey[400]!,
                    Colors.grey[500]!,
                  ],
          ),
          borderRadius: BorderRadius.circular(isSelected ? 18 : 15),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.blue.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: isSelected ? 15 : 8,
              offset: Offset(0, isSelected ? 8 : 4),
              spreadRadius: isSelected ? 2 : 0,
            ),
            if (isSelected)
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 25,
                offset: Offset(0, 12),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background pulse effect when selected
            if (isSelected)
              AnimatedContainer(
                duration: Duration(milliseconds: 600),
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: isSelected ? 28 : 24,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (widget.currentBackPressTime == null ||
        now.difference(widget.currentBackPressTime) > Duration(seconds: 2)) {
      widget.currentBackPressTime = now;
      Fluttertoast.showToast(msg: S.of(context).tapBackAgainToLeave);
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  }

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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
