import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/settings_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/ProfileSettingsDialog.dart';
import '../helpers/helper.dart';
import '../repository/user_repository.dart' as userRepo;
import '../repository/order_repository.dart' as orderRepo;
import '../notification_controller.dart';
import '../elements/IntercomButtonWidget.dart';
import '../helpers/intercom_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends StateMVC<SettingsWidget> {
  late SettingsController  _con;

  _SettingsWidgetState() : super(SettingsController()) {
    _con = (controller as SettingsController?)!;
  }

  Widget _buildTestButtons() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report, color: Colors.orange[600], size: 20),
              SizedBox(width: 8),
              Text(
                'API Testing',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Test Order Status History Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.timeline, size: 18),
              label: Text('Test Order Status History (Order #223)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                _showLoadingDialog();
                try {
                  print('🧪 Testing order status history API...');
                  final history = await orderRepo.getOrderStatusHistory('223');
                  
                  Navigator.of(context).pop(); // Close loading dialog
                  
                  if (history != null) {
                    _showSuccessDialog(
                      'Status History Loaded Successfully!',
                      'Found ${history.statusHistory.length} status entries for order #${history.orderId}',
                    );
                    print('✅ Status History Test Result:');
                    print('   Order ID: ${history.orderId}');
                    print('   Status entries: ${history.statusHistory.length}');
                    for (var item in history.statusHistory) {
                      print('   - ${item.statusName} (${item.timestamp})');
                    }
                  } else {
                    _showErrorDialog(
                      'Status History Test Failed',
                      'Could not load status history for order #223. Check API authentication and endpoint.',
                    );
                  }
                } catch (e) {
                  Navigator.of(context).pop(); // Close loading dialog
                  print('❌ Status History Test Error: $e');
                  _showErrorDialog(
                    'API Test Error',
                    'Error testing status history: $e',
                  );
                }
              },
            ),
          ),
          
          SizedBox(height: 12),
          
          // Existing sound test button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.volume_up, size: 18),
              label: Text('Test Notification Sound'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _testNotificationSound(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTrackingCard() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue[600], size: 24),
              SizedBox(width: 8),
              Text(
                'تتبع الموقع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Location Status
          FutureBuilder<Map<String, dynamic>>(
            future: _getLocationStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('جاري التحقق من حالة الموقع...'),
                    ],
                  ),
                );
              }
              
              final status = snapshot.data ?? {};
              final bool hasPermission = status['hasPermission'] ?? false;
              final bool serviceEnabled = status['serviceEnabled'] ?? false;
              final DateTime? lastUpdate = status['lastUpdate'];
              final double? lat = status['lat'];
              final double? lng = status['lng'];
              
              return Column(
                children: [
                  // Permission Status
                  _buildStatusRow(
                    'صلاحية الموقع',
                    hasPermission ? 'مُفعّلة' : 'غير مُفعّلة',
                    hasPermission ? Colors.green : Colors.red,
                    hasPermission ? Icons.check_circle : Icons.error,
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Service Status
                  _buildStatusRow(
                    'خدمة الـ GPS',
                    serviceEnabled ? 'مُفعّلة' : 'غير مُفعّلة',
                    serviceEnabled ? Colors.green : Colors.red,
                    serviceEnabled ? Icons.gps_fixed : Icons.gps_off,
                  ),
                  
                  if (lat != null && lng != null) ...[
                    SizedBox(height: 8),
                    _buildStatusRow(
                      'آخر موقع',
                      '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                      Colors.blue,
                      Icons.place,
                    ),
                  ],
                  
                  if (lastUpdate != null) ...[
                    SizedBox(height: 8),
                    _buildStatusRow(
                      'آخر تحديث',
                      _formatLastUpdate(lastUpdate),
                      _getUpdateColor(lastUpdate),
                      Icons.access_time,
                    ),
                  ],
                ],
              );
            },
          ),
          
          SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _updateLocationNow,
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text('تحديث الآن', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _clearLocationData,
                  icon: Icon(Icons.clear, color: Colors.white),
                  label: Text('مسح البيانات', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getLocationStatus() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      bool hasPermission = permission == LocationPermission.always || 
                          permission == LocationPermission.whileInUse;
      
      // Check if service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      
      // Get last saved location
      SharedPreferences prefs = await SharedPreferences.getInstance();
      double? lat = prefs.getDouble('last_lat');
      double? lng = prefs.getDouble('last_lng');
      int? lastTime = prefs.getInt('last_location_time');
      
      DateTime? lastUpdate;
      if (lastTime != null) {
        lastUpdate = DateTime.fromMillisecondsSinceEpoch(lastTime);
      }
      
      return {
        'hasPermission': hasPermission,
        'serviceEnabled': serviceEnabled,
        'lat': lat,
        'lng': lng,
        'lastUpdate': lastUpdate,
      };
    } catch (e) {
      print('Error getting location status: $e');
      return {
        'hasPermission': false,
        'serviceEnabled': false,
      };
    }
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 1) {
      return 'منذ ثوانٍ قليلة';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else {
      return 'منذ ${difference.inDays} يوم';
    }
  }

  Color _getUpdateColor(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inMinutes < 2) {
      return Colors.green; // حديث
    } else if (difference.inMinutes < 10) {
      return Colors.orange; // قديم نسبياً
    } else {
      return Colors.red; // قديم جداً
    }
  }

  Future<void> _updateLocationNow() async {
    try {
      _showLoadingDialog();
      
      // Request location update
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Get the last order ID and save location
      final prefs = await SharedPreferences.getInstance();
      final int? orderId = prefs.getInt('last_order_id');
      // await userRepo.updateDriverLocation(position.latitude, position.longitude, orderId ?? 0);
      
      // Save locally
      await prefs.setDouble('last_lat', position.latitude);
      await prefs.setDouble('last_lng', position.longitude);
      await prefs.setInt('last_location_time', DateTime.now().millisecondsSinceEpoch);
      
      Navigator.of(context).pop(); // Close loading dialog
      
      _showSuccessDialog('تم تحديث الموقع بنجاح', 
        'الموقع: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}');
      
      setState(() {}); // Refresh UI
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorDialog('خطأ في تحديث الموقع', e.toString());
    }
  }

  Future<void> _clearLocationData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_lat');
      await prefs.remove('last_lng');
      await prefs.remove('last_location_time');
      
      _showSuccessDialog('تم مسح البيانات', 'تم مسح بيانات الموقع المحفوظة محلياً');
      setState(() {}); // Refresh UI
    } catch (e) {
      _showErrorDialog('خطأ في مسح البيانات', e.toString());
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Testing API endpoint...'),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _testNotificationSound() async {
    await NotificationController.testNotificationSound();
  }

  Widget _buildDebugPanel() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bug_report,
                  color: Colors.red[700],
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لوحة التطوير والاختبار',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'أدوات اختبار وتشخيص النظام',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // أزرار الاختبار
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.volume_up, size: 18),
              label: Text('Test Notification Sound'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _testNotificationSound(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _con.scaffoldKey,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).settings,
            style:  TextStyle(letterSpacing: 1.3)),
          ),

        body: userRepo.currentUser.value.id == null
            ? CircularLoadingWidget(height: 500)
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  children: <Widget>[
                    // Debug Panel
                    _buildDebugPanel(),
                    
                    // Location Tracking Card
                    _buildLocationTrackingCard(),
                    
                    // Notification Management Card
                    _buildNotificationManagementCard(),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  userRepo.currentUser.value.name ?? "",
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                                Text(
                                  userRepo.currentUser.value.email?? "",
                                  style: Theme.of(context).textTheme.displaySmall,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                              width: 55,
                              height: 55,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(300),
                                onTap: () {
                                  Navigator.of(context).pushNamed('/Pages', arguments: 0);
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(userRepo.currentUser.value.image?.thumb?? ""),
                                ),
                              )),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)],
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text(
                              S.of(context).profile_settings,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            trailing: ButtonTheme(
                              padding: EdgeInsets.all(0),
                              minWidth: 50.0,
                              height: 25.0,
                              child: ProfileSettingsDialog(
                                user: userRepo.currentUser.value,
                                onChanged: () {
                                  _con.update(userRepo.currentUser.value);
                                  //setState(() {});
                                },
                              ),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context).full_name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            trailing: Text(
                              userRepo.currentUser.value.name?? "",
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context).email,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            trailing: Text(
                              userRepo.currentUser.value.email?? "",
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context).phone,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            trailing: Text(
                              userRepo.currentUser.value.phone?? "",
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context).address,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            trailing: Text(
                              Helper.limitString(userRepo.currentUser.value.address?? ""),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () {},
                            dense: true,
                            title: Text(
                              S.of(context).about,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            trailing: Text(
                              Helper.limitString(userRepo.currentUser.value.bio?? ""),
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.15), offset: Offset(0, 3), blurRadius: 10)],
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        primary: false,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.settings),
                            title: Text(
                              S.of(context).app_settings,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed('/Languages');
                            },
                            dense: true,
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.translate,
                                  size: 22,
                                  color: Theme.of(context).focusColor,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  S.of(context).languages,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                            trailing: Text(
                              S.of(context).english,
                              style: TextStyle(color: Theme.of(context).focusColor),
                            ),
                          ),
                          ListTile(
                            onTap: () async {
                              // اختبار صوت التنبيه
                              await NotificationController.testNotificationSound();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم تشغيل صوت التنبيه للاختبار'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            dense: true,
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.volume_up,
                                  size: 22,
                                  color: Theme.of(context).focusColor,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'اختبار صوت التنبيه',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed('/Help');
                            },
                            dense: true,
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.help,
                                  size: 22,
                                  color: Theme.of(context).focusColor,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  S.of(context).help_support,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                          ListTile(
                            onTap: () async {
                              await IntercomHelper.displayMessenger();
                            },
                            dense: true,
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.support_agent,
                                  size: 22,
                                  color: Theme.of(context).focusColor,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  S.of(context).live_chat_support,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                            trailing: IntercomButtonWidget(
                              size: 32,
                              backgroundColor: Colors.transparent,
                              iconColor: Theme.of(context).primaryColor,
                            ),
                          ),
                          ListTile(
                            onTap: () async {
                              await _con.logoutFromIntercom();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم تسجيل الخروج من الدعم المباشر'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            dense: true,
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.logout,
                                  size: 22,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  S.of(context).logout_from_intercom,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ));
  }

  Widget _buildNotificationManagementCard() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: Colors.orange[700],
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة الإشعارات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'إعدادات إشعارات الطلبات الجديدة',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // إحصائيات الإشعارات
          FutureBuilder<Map<String, dynamic>>(
            future: Future.value(NotificationController.getNotificationStats()),
            builder: (context, snapshot) {
              final stats = snapshot.data ?? {};
              final isActive = stats['is_checking_active'] ?? false;
              final notifiedCount = stats['notified_orders_count'] ?? 0;
              final isChecking = stats['is_currently_checking'] ?? false;
              
              return Column(
                children: [
                  // حالة النظام
                  _buildStatusRow(
                    'حالة فحص الطلبات',
                    isActive ? 'مُفعّل' : 'غير مُفعّل',
                    isActive ? Colors.green : Colors.red,
                    isActive ? Icons.check_circle : Icons.error,
                  ),
                  
                  SizedBox(height: 8),
                  
                  // عداد الطلبات المبلغ عنها
                  _buildStatusRow(
                    'الطلبات المبلغ عنها',
                    '$notifiedCount طلب',
                    Colors.blue,
                    Icons.notification_important,
                  ),
                  
                  if (isChecking) ...[
                    SizedBox(height: 8),
                    _buildStatusRow(
                      'الحالة الحالية',
                      'يتم فحص الطلبات الآن...',
                      Colors.orange,
                      Icons.sync,
                    ),
                  ],
                ],
              );
            },
          ),
          
          SizedBox(height: 16),
          
          // أزرار التحكم
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await NotificationController.startOrderChecking();
                    setState(() {}); // تحديث الواجهة
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ تم تفعيل فحص الطلبات الجديدة'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: Icon(Icons.play_arrow, color: Colors.white),
                  label: Text('تفعيل', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    NotificationController.stopOrderChecking();
                    setState(() {}); // تحديث الواجهة
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('⏹️ تم إيقاف فحص الطلبات'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  icon: Icon(Icons.stop, color: Colors.white),
                  label: Text('إيقاف', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // أزرار إضافية
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await NotificationController.resetNotificationHistory();
                    setState(() {}); // تحديث الواجهة
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🔄 تم إعادة تعيين تاريخ الإشعارات'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text('إعادة تعيين', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await NotificationController.playNotificationSound();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🔊 تم تشغيل صوت الإشعار'),
                          backgroundColor: Colors.purple,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ خطأ في تشغيل الصوت: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.volume_up, color: Colors.white),
                  label: Text('اختبار الصوت', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // زر اختبار الصوت للأيفون
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await NotificationController.testNotificationSound();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📱 تم اختبار الصوت للأيفون'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ خطأ في اختبار الصوت: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.phone_iphone, color: Colors.white),
                  label: Text('اختبار الأيفون', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      // محاكاة إشعار طلب جديد
                      await NotificationController.sendNewOrderNotification(
                        "123",
                        "أحمد محمد",
                        "شارع الملك فهد، الرياض"
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🆕 تم اختبار إشعار الطلب الجديد'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ خطأ في اختبار الإشعار: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.delivery_dining, color: Colors.white),
                  label: Text('اختبار الطلب', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await NotificationController.requestPermissions();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🔐 تم طلب الأذونات'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ خطأ في طلب الأذونات: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.security, color: Colors.white),
                  label: Text('طلب الأذونات', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // أزرار إضافية للصوت
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await NotificationController.ensureBackgroundAudio();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🎵 تم ضمان الصوت في الخلفية'),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ خطأ: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.music_note, color: Colors.white),
                  label: Text('ضمان الخلفية', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 12),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await NotificationController.restartAudioPlayer();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🔄 تم إعادة تشغيل مشغل الصوت'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ خطأ: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text('إعادة تشغيل', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
