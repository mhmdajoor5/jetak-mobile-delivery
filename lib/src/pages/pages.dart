import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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

  @override
  initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    await registerFCM();
    await userRepo.updateDriverAvailability(true);
    await _getCurrentPosition();
    _selectTab(widget.currentTab);
    
    // تحديث الموقع كل 30 ثانية بدلاً من 15 لتوفير البطارية
    timer = Timer.periodic(Duration(seconds: 30), (Timer t) {
      if (userRepo.currentUser.value.id != null) {
        print("📍 Auto-updating location at ${DateTime.now().toString()}");
      _getCurrentPosition();
      } else {
        print("⚠️ User not authenticated, skipping location update");
      }
    });
  }

  Future<void> _getCurrentPosition() async {
    try {
    final hasPermission = await _handlePermission();

    if (!(hasPermission == true)) {
        print('❌ Location permission denied');
      return;
    }
      
      print('📍 Getting current position...');
      final position = await _geolocatorPlatform.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // تحديث فقط إذا تحرك السائق 10 متر
        ),
      );
      
      print('📍 Position obtained: lat=${position.latitude}, lng=${position.longitude}');
      
      // حفظ الموقع محلياً أولاً
      await _saveLocationLocally(position.latitude, position.longitude);
      
      // إرسال الموقع للخادم
      final prefs = await SharedPreferences.getInstance();
      final int? orderId = prefs.getInt('last_order_id');
      await userRepo.updateDriverLocation(position.latitude, position.longitude, orderId ?? 0);
      
    } catch (e) {
      print('❌ Error getting position: $e');
      // في حالة الخطأ، جرب استخدام آخر موقع محفوظ
      await _useLastKnownLocation();
    }
  }

  Future<void> _saveLocationLocally(double lat, double lng) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_lat', lat);
      await prefs.setDouble('last_lng', lng);
      await prefs.setInt('last_location_time', DateTime.now().millisecondsSinceEpoch);
            print('💾 Location saved locally');
    } catch (e) {
      print('❌ Error saving location locally: $e');
    }
  }

  Future<void> _useLastKnownLocation() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('last_lat') && prefs.containsKey('last_lng')) {
        double lat = prefs.getDouble('last_lat') ?? 0.0;
        double lng = prefs.getDouble('last_lng') ?? 0.0;
        int lastTime = prefs.getInt('last_location_time') ?? 0;
        
        int? orderId = prefs.getInt('last_order_id');
        // استخدم آخر موقع فقط إذا كان حديث (أقل من 5 دقائق)
        int timeDiff = DateTime.now().millisecondsSinceEpoch - lastTime;
        if (timeDiff < 300000) { // 5 دقائق
          print('📍 Using last known location: lat=$lat, lng=$lng');
         
         // Use the order_id from shared preferences if available
         await userRepo.updateDriverLocation(lat, lng, orderId ?? 0);
        } else {
          print('⚠️ Last known location is too old');
        }
      }
    } catch (e) {
      print('❌ Error using last known location: $e');
      rethrow;
    }
  }

  Future<void> registerFCM() async {
    print('Registering FCM...');
    // FCM registration logic will be handled in FirebaseUtil
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
              OrdersWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 1:
          widget.currentPage =
              ProfileWidget(parentScaffoldKey: widget.scaffoldKey);
          break;
        case 2:
          widget.currentPage =
                 OrderHistoryPage();
          break;
        }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult:(didPop, result)async =>await onWillPop(),
      child: Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        body: widget.currentPage,
        bottomNavigationBar: Container(
          height: 100,
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
                color: Colors.black.withAlpha(5),
                blurRadius: 20,
                offset: Offset(0, -5),
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withAlpha(5),
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
                _selectTab(i);
              },
              items: [
                // Home Tab (Center with special design)
                BottomNavigationBarItem(
                  label: "",
                  icon: _buildNavItem(
                    icon: Icons.home_rounded,
                    isSelected: widget.currentTab == 0,
                    color: Colors.blue,
                    label: 'Home',
                  ),
                  
                ),
                // Profile Tab
                BottomNavigationBarItem(
                  icon: _buildNavItem(
                    icon: Icons.person_rounded,
                    isSelected: widget.currentTab == 1,
                    color: Colors.blue,
                    label: 'Profile',
                  ),
                  label: "",
                ),
                
                // History Tab
                 BottomNavigationBarItem(
                  icon: _buildNavItem(
                    icon: Icons.history_rounded,
                    isSelected: widget.currentTab == 2,
                    color: Colors.blue,
                    label: 'History',
                  ),
                  label: "",
                ),
                // Map Tab
               
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
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSelected ? 12 : 8),
            decoration: BoxDecoration(
             color:isSelected? Colors.grey.shade200:Colors.transparent,
              borderRadius: BorderRadius.circular(isSelected ? 16 : 12),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: isSelected?Colors.grey.withValues(alpha: .1):Colors.transparent,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? color : Colors.grey.withValues(alpha: .6),
              size: isSelected ? 22 : 20,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isSelected ? 11 : 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? color : Colors.grey.withValues(alpha: .1),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(widget.currentBackPressTime) > Duration(seconds: 2)) {
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
