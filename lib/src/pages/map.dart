import 'package:deliveryboy/src/models/pending_order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:geolocator/geolocator.dart';

import '../controllers/map_controller.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/route_argument.dart';

class EnhancedMapWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  const EnhancedMapWidget({
    super.key,
    required this.routeArgument,
    required this.parentScaffoldKey,
  });

  @override
  _EnhancedMapWidgetState createState() => _EnhancedMapWidgetState();
}

class _EnhancedMapWidgetState extends StateMVC<EnhancedMapWidget> {
  late EnhancedMapController _con;
  bool _isLoading = true;
  bool _orderAccepted = false;
  String? _errorMessage;
  String _estimatedTime = "15 min";
  String _distance = "2.3 km";
  bool _isNavigating = false;

  _EnhancedMapWidgetState() : super(EnhancedMapController()) {
    _con = (controller as EnhancedMapController);
  }

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      setState(() => _isLoading = true);
      _con.currentOrder = widget.routeArgument.param["current_order"] as PendingOrderModel;
      _con.orders= (widget.routeArgument.param["pending_orders"] as List<PendingOrderModel>);
      // Check location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services disabled';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (_con.currentOrder?.deliveryAddress?.latitude != null) {
        _con.getOrderLocation();
        _con.getDirectionSteps();
      } else {
        _con.getCurrentLocation();
      }

      // Simulate route calculation
      await Future.delayed(const Duration(milliseconds: 1500));
      _calculateRouteInfo();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateRouteInfo() {
    // Simulate route calculation - replace with actual Google Directions API call
    setState(() {
      _estimatedTime = "${15 + (DateTime.now().millisecond % 20)} min";
      _distance = "${(2.0 + (DateTime.now().millisecond % 100) / 100).toStringAsFixed(1)} km";
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: _buildAppBar(theme, isDark),
      body: Stack(
        children: [
          _buildMap(),
          if (_isLoading) _buildLoadingOverlay(),
          if (_errorMessage != null) _buildErrorOverlay(theme),
          if (!_isLoading && _errorMessage == null) ...[
            _buildRouteInfo(theme:  theme,isDark:  isDark),
            _buildBottomSheet(theme:  theme,isDark: isDark),
          ],
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      
      leading: Container(
        margin: const EdgeInsets.only(left: 16, top: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: isDark ? Colors.white : Colors.black87,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.my_location_rounded, size: 20),
            color: theme.primaryColor,
            onPressed: _con.goCurrentLocation,
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      buildingsEnabled: true,
      trafficEnabled: true,
      mapType: MapType.normal,
      initialCameraPosition: _con.cameraPosition ??  CameraPosition(
        target: LatLng(_con.currentAddress!.latitude!, _con.currentAddress!.longitude!),
        zoom: 15,
        tilt: 60, // Add 3D tilt
        bearing: 0,
      ),
      markers: Set<Marker>.from(_con.allMarkers),
      style:'''
          [
            {
              "featureType": "all",
              "elementType": "geometry",
              "stylers": [
                {
                  // "color": "#f5f5f5"
                }
              ]
            }
          ]
        ''' ,
      onMapCreated: (GoogleMapController controller) {
        _con.mapController.complete(controller);
        // Enable 3D buildings
        
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: false,
      polylines: _con.polylines,
      onCameraIdle: _con.getOrdersOfArea,
      cameraTargetBounds: CameraTargetBounds.unbounded,
      minMaxZoomPreference: const MinMaxZoomPreference(10, 20),
      rotateGesturesEnabled: true,
      tiltGesturesEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading route...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(ThemeData theme) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeMap,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfo({required ThemeData theme, bool isDark=false}) {
    return Positioned(
      top: kToolbarHeight + MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? Colors.grey[900] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_rounded,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route to delivery',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _estimatedTime,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.straighten_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _distance,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_isNavigating)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Navigating',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet({required ThemeData theme, bool isDark =false}) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        decoration: BoxDecoration(
          color:  Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Order info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderHeader(theme),
                  const SizedBox(height: 16),
                  _buildOrderDetails(theme),
                  const SizedBox(height: 20),
                  _buildActionButtons(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.shadowColor.withOpacity(0.2),
                theme.shadowColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.shopping_bag_outlined,
            color: theme.shadowColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${_con.currentOrder?.orderId ?? 'N/A'}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ready for pickup',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          '${(_con.currentOrder?.deliveryFee??0)+ (_con.currentOrder?.tax??0) +((_con.currentOrder?.foodOrders??[]).fold(0, (previousValue, element) => previousValue + element.price))}\$',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_rounded, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_con.currentOrder?.foodOrders?.length ?? 0} items',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              // Text(
              //   _con.currentOrder?.?.method ?? 'Cash',
              //   style: theme.textTheme.bodyMedium?.copyWith(
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _con.currentOrder?.deliveryAddress?.address ?? 'Delivery address',
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        if (!_orderAccepted) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _orderAccepted = true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.shadowColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Accept Order',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Decline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() => _isNavigating = !_isNavigating);
                _startNavigation(); 
              },
              icon: Icon(_isNavigating ? Icons.stop_rounded : Icons.navigation_rounded),
              label: Text(_isNavigating ? 'Stop Navigation' : 'Start Navigation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isNavigating ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Call customer
                  },
                  icon: const Icon(Icons.phone_rounded, size: 20),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Message customer
                  },
                  icon: const Icon(Icons.message_rounded, size: 20),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _startNavigation() {
    if (_isNavigating) {
      final lat = _con.currentOrder?.deliveryAddress?.latitude;
      final lng = _con.currentOrder?.deliveryAddress?.longitude;
      if (lat != null && lng != null) {
        // Launch external maps app for navigation
        // Helper.launchMapsUrl(lat, lng);
      }
    }
  }
}