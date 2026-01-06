import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:deliveryboy/src/models/route_argument.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/order_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;

class OrderNotificationScreen extends StatefulWidget {
  final dynamic routeArgument;

  const OrderNotificationScreen({super.key, this.routeArgument});

  @override
  _OrderNotificationScreenState createState() =>
      _OrderNotificationScreenState();
}

class _OrderNotificationScreenState extends StateMVC<OrderNotificationScreen> {
  late OrderController _con;
  AudioPlayer? _audioPlayer;

  _OrderNotificationScreenState() : super(OrderController()) {
    _con = (controller as OrderController?)!;
  }

  @override
  void initState() {
    super.initState();
    _playNotificationSound();
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _playNotificationSound() async {
    try {
      _audioPlayer = AudioPlayer();
      await _audioPlayer?.play(AssetSource("notification_sound.wav"));
      _audioPlayer?.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print("❌ Error playing sound: $e");
    }
  }

  void _stopNotificationSound() {
    _audioPlayer?.stop();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    Map<String, dynamic> argsMap = {};
    try {
      final args = (widget.routeArgument as Map<String, dynamic>)["message"];
      argsMap = json.decode(args as String);
    } catch (e) {
      print("❌ Error parsing notification args: $e");
    }

    final orderId = argsMap['id']?.toString() ?? '';
    final title = argsMap['title'] ?? 'New Order';
    final restaurant = argsMap['restaurant'] ?? '';
    final restaurantLocation = argsMap['restaurant_location'] ?? '';
    final customer = argsMap['user'] ?? 'Customer';
    final total = argsMap['total']?.toString() ?? '0.0';
    final status = argsMap['status'] ?? 'Pending';
    final pickupAddress = restaurantLocation.toString().isNotEmpty
        ? restaurantLocation
        : (restaurant.isNotEmpty ? restaurant : 'Pickup');
    final dropAddress = argsMap['address'] ?? '';

    final double? pickupLat = _asDouble(argsMap['restaurant_latitude']);
    final double? pickupLng = _asDouble(argsMap['restaurant_longitude']);
    final double? dropLat = _asDouble(argsMap['delivery_latitude']);
    final double? dropLng = _asDouble(argsMap['delivery_longitude']);
    final distanceKm = _calcDistanceKm(pickupLat, pickupLng, dropLat, dropLng);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: size.height * 0.36,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildHeaderMap(pickupLat, pickupLng, dropLat, dropLng),
                  ),
                  // Overlay gradient for readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.black.withOpacity(0.45),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      onPressed: () {
                        _stopNotificationSound();
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Order #$orderId",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.local_shipping, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "New delivery",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          Spacer(),
                          if (distanceKm != null)
                            Text(
                              "${distanceKm.toStringAsFixed(2)} km",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        restaurant.isNotEmpty ? restaurant : 'Pickup location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Always show restaurant location (pickup address) under restaurant name
                      Text(
                        restaurantLocation.toString().isNotEmpty
                            ? restaurantLocation.toString()
                            : 'Pickup address not provided',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      _locationRow(Icons.location_on, pickupAddress, Colors.blue),
                      SizedBox(height: 10),
                      _locationRow(Icons.place, dropAddress, Colors.green),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.black87),
                          SizedBox(width: 6),
                          Text(
                            total,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if (customer.toString().isNotEmpty) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person_outline, color: Colors.grey[700]),
                            SizedBox(width: 6),
                            Text(
                              customer,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ],
                      // لا نكرر العنوان: نخفي السطر إذا كان status يساوي عنوان العميل
                      if (status.toString().trim().isNotEmpty &&
                          status.toString().trim() != dropAddress.toString().trim()) ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey[700]),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                status,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: BlockButtonWidget(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              text: Text(
                                "Reject",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Colors.redAccent,
                              onPressed: () async {
                                _stopNotificationSound();
                                try {
                                  if (orderId.isNotEmpty) {
                                    await _con.rejectOrder(orderId);
                                  }
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/Pages',
                                    (Route<dynamic> route) => false,
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: BlockButtonWidget(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              text: Text(
                                "Accept",
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              color: Colors.white,
                              onPressed: () async {
                                _stopNotificationSound();
                                try {
                                  if (orderId.isNotEmpty) {
                                    await _con.acceptOrder(orderId);
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/Pages',
                                      (Route<dynamic> route) => false,
                                    );
                                    Navigator.of(context).pushNamed(
                                      '/OrderDetails',
                                      arguments: RouteArgument(id: orderId),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locationRow(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text.isNotEmpty ? text : 'Not provided',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  double? _calcDistanceKm(double? lat1, double? lon1, double? lat2, double? lon2) {
    if (lat1 == null || lon1 == null || lat2 == null || lon2 == null) return null;
    try {
      final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
      return meters / 1000;
    } catch (_) {
      return null;
    }
  }

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Widget _buildMiniMap(double? pickupLat, double? pickupLng, double? dropLat, double? dropLng) {
    if (pickupLat == null || pickupLng == null || dropLat == null || dropLng == null) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Map not available (missing coordinates)',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    final pickup = LatLng(pickupLat, pickupLng);
    final drop = LatLng(dropLat, dropLng);
    final bounds = LatLngBounds(
      southwest: LatLng(
        pickup.latitude < drop.latitude ? pickup.latitude : drop.latitude,
        pickup.longitude < drop.longitude ? pickup.longitude : drop.longitude,
      ),
      northeast: LatLng(
        pickup.latitude > drop.latitude ? pickup.latitude : drop.latitude,
        pickup.longitude > drop.longitude ? pickup.longitude : drop.longitude,
      ),
    );

    final markers = {
      Marker(
        markerId: MarkerId('pickup'),
        position: pickup,
        infoWindow: InfoWindow(title: 'Pickup'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: MarkerId('drop'),
        position: drop,
        infoWindow: InfoWindow(title: 'Drop-off'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };

    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(target: pickup, zoom: 12),
        markers: markers,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        liteModeEnabled: true,
        onMapCreated: (controller) {
          controller.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 40),
          );
        },
      ),
    );
  }

  Widget _buildHeaderMap(double? pickupLat, double? pickupLng, double? dropLat, double? dropLng) {
    if (pickupLat == null || pickupLng == null || dropLat == null || dropLng == null) {
      return Container(
        color: Colors.blue.shade500,
        child: Center(
          child: Text(
            'Map not available (missing coordinates)',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final pickup = LatLng(pickupLat, pickupLng);
    final drop = LatLng(dropLat, dropLng);
    final bounds = LatLngBounds(
      southwest: LatLng(
        pickup.latitude < drop.latitude ? pickup.latitude : drop.latitude,
        pickup.longitude < drop.longitude ? pickup.longitude : drop.longitude,
      ),
      northeast: LatLng(
        pickup.latitude > drop.latitude ? pickup.latitude : drop.latitude,
        pickup.longitude > drop.longitude ? pickup.longitude : drop.longitude,
      ),
    );

    final markers = {
      Marker(
        markerId: MarkerId('pickup'),
        position: pickup,
        infoWindow: InfoWindow(title: 'Pickup'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: MarkerId('drop'),
        position: drop,
        infoWindow: InfoWindow(title: 'Drop-off'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: pickup, zoom: 12),
      markers: markers,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      liteModeEnabled: true,
      onMapCreated: (controller) {
        controller.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 40),
        );
      },
    );
  }
}
