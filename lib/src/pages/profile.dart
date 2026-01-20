import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/profile_controller.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../elements/IntercomButtonWidget.dart';
import '../constants/theme/colors_manager.dart';
import '../repository/user_repository.dart' as userRepo;
import '../models/user.dart';

class ProfileWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  const ProfileWidget({super.key, required this.parentScaffoldKey});

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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied!'),
        backgroundColor: ColorsManager.success,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: ColorsManager.error, size: 28),
            SizedBox(width: 8),
            Text('האם אתה בטוח?'),
          ],
        ),
        content: Text(
          'פעולה זו תמחק את החשבון שלך לצמיתות. לא ניתן לבטל פעולה זו.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ביטול'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog
              _performAccountDeletion();
            },
            child: Text('מחק', style: TextStyle(color: ColorsManager.error)),
          ),
        ],
      ),
    );
  }

  void _performAccountDeletion() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Deleting account...'),
          ],
        ),
      ),
    );

    // Call delete API
    final result = await userRepo.deleteAccount();

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (result['success'] == true) {
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/Login', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: ColorsManager.success,
          ),
        );
      }
    } else {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete account'),
            backgroundColor: ColorsManager.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = userRepo.currentUser.value;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.sort, color: Colors.black54),
          onPressed: () => widget.parentScaffoldKey.currentState?.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
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
      body: RefreshIndicator(
        onRefresh: () async => await _con.refreshProfile(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              // Profile Header
              _buildProfileHeader(user),

              // Driver Info
              _buildDriverInfoCard(user),

              // Recent Orders
              _buildRecentOrdersSection(),

              // Quick Actions
              _buildQuickActionsCard(),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ColorsManager.primary500, ColorsManager.primary600],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Name with verified badge
          if (user.name != null && user.name!.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    user.name!,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (user.verifiedPhone == true) ...[
                  SizedBox(width: 6),
                  Icon(Icons.verified, color: ColorsManager.success, size: 20),
                ],
              ],
            ),
            SizedBox(height: 4),
          ],
          if (user.email != null && user.email!.isNotEmpty) ...[
            Text(
              user.email!,
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            SizedBox(height: 4),
          ],

          // Referral Code (if exists)
          if (user.referralCode != null && user.referralCode!.isNotEmpty) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.card_giftcard, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    user.referralCode!,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _copyToClipboard(user.referralCode!),
                    child: Icon(Icons.copy, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 12),

          // Online/Offline Toggle
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: (user.available == true) ? ColorsManager.success : ColorsManager.grey,
                ),
                SizedBox(width: 6),
                Text(
                  (user.available == true) ? 'Online' : 'Offline',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: user.available ?? false,
                  onChanged: (value) async {
                    await userRepo.updateDriverAvailability(value);
                    setState(() => user.available = value);
                  },
                  activeColor: ColorsManager.success,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard(User user) {
    // Only show info items that have actual data
    List<Widget> infoItems = [];

    if (user.vehicleType != null && user.vehicleType!.isNotEmpty) {
      infoItems.add(_buildInfoItem(Icons.directions_car, 'Vehicle', user.vehicleType!));
    }
    if (user.deliveryCity != null && user.deliveryCity!.isNotEmpty) {
      infoItems.add(_buildInfoItem(Icons.location_city, 'City', user.deliveryCity!));
    }
    if (user.languagesSpoken != null && user.languagesSpoken!.isNotEmpty) {
      infoItems.add(_buildInfoItem(Icons.language, 'Languages', user.languagesSpoken!));
    }
    if (user.phone != null && user.phone!.isNotEmpty) {
      infoItems.add(_buildInfoItem(Icons.phone, 'Phone', user.phone!));
    }
    if (user.address != null && user.address!.isNotEmpty) {
      infoItems.add(_buildInfoItem(Icons.home, 'Address', user.address!));
    }
    if (user.bio != null && user.bio!.isNotEmpty) {
      infoItems.add(_buildInfoItem(Icons.info_outline, 'About', user.bio!));
    }

    // If no info items exist, don't show the card at all
    if (infoItems.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).about,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ...infoItems,
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: ColorsManager.grey),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 13, color: ColorsManager.grey, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: ColorsManager.charcoal, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).recent_orders,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/Pages', arguments: 2),
                child: Text('View All', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          SizedBox(height: 12),
          _con.recentOrders.where((e) => e.orderStatus?.status == 'Delivered').isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.inbox, size: 48, color: ColorsManager.grey),
                        SizedBox(height: 8),
                        Text('No recent orders', style: TextStyle(color: ColorsManager.grey)),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: _con.recentOrders.where((e) => e.orderStatus?.status == 'Delivered').take(3).length,
                  itemBuilder: (context, index) {
                    var order = _con.recentOrders.where((e) => e.orderStatus?.status == 'Delivered').elementAt(index);
                    return OrderItemWidget(expanded: false, order: order);
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 10),
                ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Settings & Language
          Row(
            children: [
              Expanded(
                child: _buildActionButton(Icons.settings, 'Settings', () => Navigator.of(context).pushNamed('/Settings')),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(Icons.language, 'Language', () => Navigator.of(context).pushNamed('/Languages')),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Help & Support
          Row(
            children: [
              Expanded(
                child: _buildActionButton(Icons.help_outline, 'Help', () => Navigator.of(context).pushNamed('/Help')),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: IntercomFloatingButton(
                      backgroundColor: ColorsManager.primary500,
                      iconColor: Colors.white,
                      tooltip: 'Support',
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 8),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await userRepo.logout();
                          Navigator.of(context).pushNamedAndRemoveUntil('/Login', (route) => false);
                        },
                        child: Text('Logout', style: TextStyle(color: ColorsManager.error)),
                      ),
                    ],
                  ),
                );
              },
              icon: Icon(Icons.logout, size: 18),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.error,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          SizedBox(height: 12),

          // Delete Account Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteAccountDialog(),
              icon: Icon(Icons.delete_forever, size: 18),
              label: Text('מחיקת חשבון'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ColorsManager.error,
                side: BorderSide(color: ColorsManager.error),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: ColorsManager.primary500.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: ColorsManager.primary500, size: 24),
            SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ColorsManager.charcoal),
            ),
          ],
        ),
      ),
    );
  }
}
