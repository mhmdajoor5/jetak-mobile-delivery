import 'package:deliveryboy/src/elements/CircularLoadingWidget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:map_launcher/map_launcher.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/order_details_controller.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';

class OrderWidget extends StatefulWidget {
  final RouteArgument? routeArgument;

  const OrderWidget({Key? key, this.routeArgument}) : super(key: key);

  @override
  _OrderWidgetState createState() {
    return _OrderWidgetState();
  }
}

class _OrderWidgetState extends StateMVC<OrderWidget> {
  late OrderDetailsController _con;

  _OrderWidgetState() : super(OrderDetailsController()) {
    _con = controller as OrderDetailsController;
  }

  @override
  void initState() {
    _con.listenForOrder(id: widget.routeArgument?.id);
    super.initState();
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'order received':
        return Colors.orange[600]!;
      case 'preparing':
      case 'in preparation':
        return Colors.blue[600]!;
      case 'ready for pickup':
      case 'ready':
        return Colors.purple[600]!;
      case 'on the way':
      case 'in delivery':
        return Colors.indigo[600]!;
      case 'delivered':
      case 'completed':
        return Colors.green[600]!;
      case 'cancelled':
      case 'rejected':
        return Colors.red[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      backgroundColor: Colors.grey[50],
      body:
          _con.order == null
              ? CircularLoadingWidget(height: 400)
              : CustomScrollView(
                slivers: <Widget>[
                  // Enhanced Modern App Bar
                  SliverAppBar(
                    expandedHeight: 160,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      titlePadding: EdgeInsets.only(left: 72, bottom: 16),
                      title: Container(
                        child: Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF4A90E2),
                              Color(0xFF357ABD),
                              Color(0xFF2E6DA4),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: SafeArea(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 50, 20, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Order Title Section
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.receipt_long,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Order Details',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            '#${_con.order?.id ?? 'N/A'}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(0, 1),
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  blurRadius: 3,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Payment Method Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _con.order?.payment?.method
                                                        ?.toLowerCase() ==
                                                    'cash'
                                                ? Icons.money
                                                : Icons.credit_card,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            _con.order?.payment?.method ??
                                                'Cash',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12),

                                // Status and Date Row
                                Row(
                                  children: [
                                    // Status Badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(
                                          _con.order?.orderStatus?.status ?? "",
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        _con.order?.orderStatus?.status ??
                                            "Unknown",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 12),

                                    // Date and Time
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.white70,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              _con.order?.dateTime != null
                                                  ? DateFormat(
                                                    'MMM dd, yyyy • HH:mm',
                                                  ).format(
                                                    _con.order!.dateTime!,
                                                  )
                                                  : 'N/A',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    leading: Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    actions: [
                      Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            _con.listenForOrder(id: widget.routeArgument?.id);
                          },
                        ),
                      ),
                    ],
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: 10),

                        // Order Items Section
                        _buildOrderItemsSection(),
                        SizedBox(height: 16),

                        // Customer Info Section
                        _buildCustomerInfoSection(),
                        SizedBox(height: 16),

                        // Pricing Section
                        _buildPricingSection(),
                        SizedBox(height: 100), // Space for bottom button
                      ],
                    ),
                  ),
                ],
              ),

      // Modern Bottom Action Button
      bottomNavigationBar:
          _con.order == null ? null : _buildBottomActionButton(),
    );
  }

  Widget _buildOrderItemsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    color: Colors.orange[700],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Ordered Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_con.order?.foodOrders?.length ?? 0} items',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 0, color: Colors.grey[200]),

          // Food Items List
          ListView.separated(
            padding: EdgeInsets.all(16),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _con.order?.foodOrders?.length ?? 0,
            separatorBuilder: (context, index) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final foodOrder = _con.order?.foodOrders?.elementAt(index);
              return Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.fastfood, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodOrder?.food?.name ?? 'Unknown Item',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Qty: ${foodOrder?.quantity?.toInt() ?? 0}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Helper.getPrice(
                      foodOrder?.price ?? 0.0,
                      context,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, color: Colors.green[700], size: 20),
                ),
                SizedBox(width: 12),
                Text(
                  'Customer Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 0, color: Colors.grey[200]),

          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Customer Name
                _buildInfoRow(
                  icon: Icons.person_outline,
                  title: 'Customer Name',
                  value: _con.order?.user?.name ?? 'N/A',
                  color: Colors.blue,
                ),

                SizedBox(height: 16),

                // Phone Number with Call Button
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  title: 'Phone Number',
                  value: _con.order?.user?.phone ?? 'N/A',
                  color: Colors.green,
                  action:
                      _con.order?.user?.phone != null &&
                              _con.order!.user!.phone!.isNotEmpty
                          ? IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.call,
                                color: Colors.green[700],
                                size: 18,
                              ),
                            ),
                            onPressed: () {
                              launch("tel:${_con.order!.user!.phone}");
                            },
                          )
                          : null,
                ),

                SizedBox(height: 16),

                // Delivery Address with Map Button
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  title: 'Delivery Address',
                  value:
                      _con.order?.deliveryAddress?.address ??
                      'Address not provided',
                  color: Colors.orange,
                  maxLines: 3,
                  action:
                      _con.order?.deliveryAddress?.latitude != null &&
                              _con.order?.deliveryAddress?.longitude != null
                          ? IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.directions,
                                color: Colors.blue[700],
                                size: 18,
                              ),
                            ),
                            onPressed: () async {
                              Position? position = await _getCurrentPosition();
                              if (position == null) return;
                              MapLauncher.showDirections(
                                mapType: MapType.waze,
                                destination: Coords(
                                  _con.order!.deliveryAddress!.latitude ?? 0.0,
                                  _con.order!.deliveryAddress!.longitude ?? 0.0,
                                ),
                                origin: Coords(
                                  position.latitude,
                                  position.longitude,
                                ),
                              );
                            },
                          )
                          : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    Widget? action,
    int maxLines = 2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildPricingSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: Colors.purple[700],
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 0, color: Colors.grey[200]),

          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                _buildPriceRow(
                  'Subtotal',
                  Helper.getSubTotalOrdersPrice(_con.order!),
                ),
                SizedBox(height: 12),
                _buildPriceRow('Delivery Fee', _con.order!.deliveryFee ?? 0.0),
                SizedBox(height: 12),
                _buildPriceRow(
                  'Tax (${_con.order!.tax}%)',
                  Helper.getTaxOrder(_con.order!),
                ),
                SizedBox(height: 16),
                Divider(color: Colors.grey[300]),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    Helper.getPrice(
                      Helper.getTotalOrdersPrice(_con.order!),
                      context,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Helper.getPrice(
          amount,
          context,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButton() {
    if (_con.order?.orderStatus?.id == '5') {
      // Order Delivered
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green[600], size: 24),
              SizedBox(width: 12),
              Text(
                '✅ Order Delivered Successfully',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Active Order - Show Action Button
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Icon(
          (_con.order?.orderStatus?.id == "3")
              ? Icons.directions_car
              : Icons.check_circle,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          (_con.order?.orderStatus?.id == "3")
              ? "🚗 Start Delivery"
              : "✅ Mark as Delivered",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onPressed: () {
          String title =
              (_con.order?.orderStatus?.id == "3")
                  ? "Start Delivery?"
                  : "Confirm Delivery?";
          String message =
              (_con.order?.orderStatus?.id == "3")
                  ? "Mark this order as 'On The Way' to customer?"
                  : "Confirm that you have delivered all items to the customer?";

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                content: Text(message),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (_con.order?.orderStatus?.id == "3")
                              ? Colors.blue[600]
                              : Colors.green[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      (_con.order?.orderStatus?.id == "3")
                          ? "Start"
                          : "Confirm",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (_con.order?.orderStatus?.id == "3") {
                        _con.doOnTheWayOrder(_con.order!);
                      } else {
                        _con.doDeliveredOrder(_con.order!);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              (_con.order?.orderStatus?.id == "3")
                  ? Colors.blue[600]
                  : Colors.green[600],
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
