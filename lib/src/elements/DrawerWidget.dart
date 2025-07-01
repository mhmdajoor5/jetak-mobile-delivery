import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends StateMVC<DrawerWidget> {
  //ProfileController _con;

  _DrawerWidgetState() : super(ProfileController()) {
    //_con = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: currentUser.value.apiToken == null
          ? CircularLoadingWidget(height: 500)
          : Container(
                    decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Modern Header
                  _buildModernHeader(context),
                  
                  // Main Content
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(0),
                      children: [
                        SizedBox(height: 10),
                        
                        // Main Navigation Section
                        _buildSectionHeader('📋 Navigation', context),
                        _buildMenuItem(
                          context,
                          icon: Icons.receipt_long,
                          title: S.of(context).orders,
                          subtitle: 'View active orders',
                          color: Colors.blue,
                          onTap: () => Navigator.of(context).pushNamed('/Pages', arguments: 1),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.notifications_outlined,
                          title: S.of(context).notifications,
                          subtitle: 'Check alerts',
                          color: Colors.orange,
                          onTap: () => Navigator.of(context).pushNamed('/Notifications'),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.history,
                          title: S.of(context).history,
                          subtitle: 'Past deliveries',
                          color: Colors.purple,
                          onTap: () => Navigator.of(context).pushNamed('/Pages', arguments: 2),
                        ),
                        
                        SizedBox(height: 20),
                        Divider(color: Colors.grey[300], thickness: 1),
                        
                        // Settings Section
                        _buildSectionHeader('⚙️ Settings', context),
                        _buildMenuItem(
                          context,
                          icon: Icons.help_outline,
                          title: S.of(context).help__support,
                          subtitle: 'Get assistance',
                          color: Colors.green,
                          onTap: () => Navigator.of(context).pushNamed('/Help'),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.settings_outlined,
                          title: S.of(context).settings,
                          subtitle: 'App preferences',
                          color: Colors.grey[600]!,
                          onTap: () => Navigator.of(context).pushNamed('/Settings'),
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.language,
                          title: S.of(context).languages,
                          subtitle: 'Change language',
                          color: Colors.indigo,
                          onTap: () => Navigator.of(context).pushNamed('/Languages'),
                        ),
                        
                        // Debug Option (for development)
                        _buildMenuItem(
                          context,
                          icon: Icons.bug_report,
                          title: 'Debug Info',
                          subtitle: 'API & Token diagnostics',
                          color: Colors.purple,
                          onTap: () => Navigator.of(context).pushNamed('/Debug'),
                        ),
                        
                        SizedBox(height: 20),
                        Divider(color: Colors.grey[300], thickness: 1),
                        
                        // Theme Toggle
                        _buildThemeToggle(context),
                        
                        SizedBox(height: 20),
                        Divider(color: Colors.grey[300], thickness: 1),
                        
                        // Logout
                        _buildLogoutButton(context),
                        
                        SizedBox(height: 20),
                        
                        // Version Info
                        if (setting.value.enableVersion)
                          _buildVersionInfo(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[600]!,
            Colors.blue[800]!,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              
              // Profile Picture
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  backgroundImage: currentUser.value.image?.thumb != null && 
                      currentUser.value.image!.thumb!.isNotEmpty
                      ? NetworkImage(currentUser.value.image!.thumb!)
                      : null,
                  child: currentUser.value.image?.thumb == null || 
                         currentUser.value.image!.thumb!.isEmpty
                      ? Icon(Icons.person, size: 35, color: Colors.grey[600])
                      : null,
                ),
              ),
              
              SizedBox(height: 10),
              
              // User Name
              Text(
                currentUser.value.name ?? "Driver",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 3),
              
              // User Email
              Text(
                currentUser.value.email ?? "driver@demo.com",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 10),
              
              // Driver Status Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green[400],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'ACTIVE DRIVER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 8),
              
              // Edit Profile Button
              GestureDetector(
                  onTap: () {
                  Navigator.of(context).pushNamed('/Pages', arguments: 0);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
                  ),
                  title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.yellow.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: isDark ? Colors.yellow[700] : Colors.grey[700],
            size: 22,
          ),
                  ),
                  title: Text(
          isDark ? 'Light Mode' : 'Dark Mode',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          isDark ? 'Switch to light theme' : 'Switch to dark theme',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: CupertinoSwitch(
          value: isDark,
          onChanged: (value) {
            if (isDark) {
                      setBrightness(Brightness.light);
                      setting.value.brightness.value = Brightness.light;
                    } else {
                      setting.value.brightness.value = Brightness.dark;
                      setBrightness(Brightness.dark);
                    }
                    setting.notifyListeners();
                  },
          activeColor: Colors.blue[600],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Logout', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    logout().then((value) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/Login', 
                          (Route<dynamic> route) => false
                        );
                    });
                  },
                  ),
                ],
              );
            },
          );
        },
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.exit_to_app,
            color: Colors.red[600],
            size: 22,
          ),
                  ),
                  title: Text(
                    S.of(context).log_out,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red[700],
          ),
        ),
        subtitle: Text(
          'Sign out of your account',
          style: TextStyle(
            fontSize: 12,
            color: Colors.red[400],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.red[400],
        ),
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey[600],
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Version',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${setting.value.appVersion}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
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
}
