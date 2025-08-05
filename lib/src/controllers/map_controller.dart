import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart'; // For PlatformException

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/app_config.dart' as config;
import '../helpers/maps_util.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../models/pending_order_model.dart';
import '../repository/orders/pending_order_repo.dart';
import '../repository/settings_repository.dart' as sett;
import '../repository/user_repository.dart' as userRepo;

class EnhancedMapController extends ControllerMVC {
  PendingOrderModel? currentOrder;
  List<PendingOrderModel> orders = <PendingOrderModel>[];
  List<Marker> allMarkers = <Marker>[];
  Address? currentAddress = sett.myAddress.value;
  Set<Polyline> polylines = {};
  CameraPosition? cameraPosition;
  MapsUtil mapsUtil = MapsUtil();
  
  
  // Navigation specific properties
  double routeDistance = 0.0;
  int estimatedTime = 0;
  List<LatLng> routePoints = [];
  bool isNavigating = false;
  Timer? navigationTimer;
  
  // Financial calculations
  double taxAmount = 0.0;
  double subTotal = 0.0;
  double deliveryFee = 0.0;
  double total = 0.0;
  
  Completer<GoogleMapController> mapController = Completer();

  // Initialize repositories
  EnhancedMapController() {
  }
  
  // Update driver's current location
  Future<void> updateDriverLocation(double latitude, double longitude) async {
    try {
      // Update the current address with new coordinates
      if (currentAddress != null) {
        currentAddress!.latitude = latitude;
        currentAddress!.longitude = longitude;
        
        // You can add additional logic here if needed, like saving to preferences
        // or notifying other parts of the app about the location update
        
        setState(() {
          // Trigger UI update if needed
        });
      }
    } catch (e) {
      debugPrint('Error updating driver location: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    navigationTimer?.cancel();
    super.dispose();
  }

  void listenForPendingOrders({String? message}) async {
    final currentUser = userRepo.currentUser.value;

    if (currentUser.apiToken == null || currentUser.apiToken!.isEmpty) {
      print('❌ CRITICAL: User has no API token!');
      // Handle authentication error - you might want to navigate to login
      return;
    }

   // Fetch pending orders
    try {
      final response = await getPendingOrders(driverId: currentUser.id.toString());

      // Parse response into PendingOrdersModel
      final parsedOrders = PendingOrdersModel.fromJson(response);
      
      
      // Clear existing orders and markers for pending orders
      setState(() {
        orders.clear();
        // Remove only order markers, keep current location marker
        allMarkers.removeWhere((marker) => 
          marker.markerId.value.startsWith('order_') || 
          marker.markerId.value == 'destination'
        );
      });

      // Process each pending order
      for (int i = 0; i < parsedOrders.orders.length; i++) {
        final pendingOrder = parsedOrders.orders[i];

        // Convert PendingOrder to Order model if needed
        // You might need to create a conversion method
        PendingOrderModel order = pendingOrder;
        
        setState(() {
          orders.add(order);
        });

        // Create marker for this order if it has valid coordinates
        if (order.deliveryAddress != null ) {
          _createOrderMarker(order).then((marker) {
            setState(() {
              allMarkers.add(marker);
            });
          });
        }
      }

      // If there's a current order, make sure it's properly set up
      if (currentOrder != null) {
        calculateSubtotal();
        getDirectionSteps();
      }

    } catch (err) {
      rethrow;
    }
  }


  Future<Marker> _createOrderMarker(PendingOrderModel order) async {
    return Marker(
      markerId: MarkerId('order_${order?.orderId??""}'),
      position: LatLng(
        order.deliveryAddress!.latitude,
        order.deliveryAddress!.longitude,
      ),
      icon: await _createCustomMarkerIcon(
        Icons.location_on,
        config.Colors().mainColor(1.0),
        size: 48,
      ),
      infoWindow: InfoWindow(
        title: 'Order #${order.orderId}',
        snippet: 'Tap for details',
      ),
    );
  }

  Future<BitmapDescriptor> _createCustomMarkerIcon(
    IconData icon,
    Color color, {
    double size = 48,
  }) async {
    // This would create a custom marker icon - implement based on your needs
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }

  void getCurrentLocation() async {
    try {
      currentAddress = sett.myAddress.value;
      setState(() {
        if (currentAddress!.isUnknown()) {
          cameraPosition = CameraPosition(
            target: LatLng(31.111, 31.1111),
            zoom: 4,
            tilt: 0,
            bearing: 0,
          );
        } else {
          cameraPosition = CameraPosition(
            target: LatLng(currentAddress!.latitude!, currentAddress!.longitude!),
            zoom: 16,
            tilt: 45, // 3D view
            bearing: 0,
          );
        }
      });
      
      if (!currentAddress!.isUnknown()) {
        _createMyLocationMarker().then((marker) {
          setState(() {
            allMarkers.add(marker);
          });
        });
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  Future<Marker> _createMyLocationMarker() async {
    return Marker(
      markerId: const MarkerId('my_location'),
      position: LatLng(currentAddress!.latitude!, currentAddress!.longitude!),
      icon: await _createCustomMarkerIcon(
        Icons.my_location,
        Colors.blue,
        size: 36,
      ),
      infoWindow: const InfoWindow(
        title: 'My Location',
        snippet: 'Current position',
      ),
    );
  }

  void getOrderLocation() async {
    try {
      currentAddress = sett.myAddress.value;
      
      if (currentOrder?.deliveryAddress != null) {
        if(currentAddress?.latitude==null || currentAddress?.longitude==null){
         currentAddress = Address.fromJSON({
          "id": "",
          "description": "",
          "address": "",
          "latitude": currentOrder!.deliveryAddress!.latitude,
          "longitude": currentOrder!.deliveryAddress!.longitude,
          "isDefault": false,
          "userId": ""
         }); 
        }
        // Calculate center point between current location and destination
        double centerLat = (currentAddress!.latitude! + currentOrder!.deliveryAddress!.latitude!) / 2;
        double centerLng = (currentAddress!.longitude! + currentOrder!.deliveryAddress!.longitude!) / 2;
        
        // Calculate zoom level based on distance
        double distance = _calculateDistance(
          currentAddress!.latitude!,
          currentAddress!.longitude!,
          currentOrder!.deliveryAddress!.latitude!,
          currentOrder!.deliveryAddress!.longitude!,
        );
        
        double zoom = _getZoomLevelForDistance(distance);
        
        setState(() {
          cameraPosition = CameraPosition(
            target: LatLng(centerLat, centerLng),
            zoom: zoom,
            tilt: 45, // 3D view
            bearing: _calculateBearing(
              currentAddress!.latitude!,
              currentAddress!.longitude!,
              currentOrder!.deliveryAddress!.latitude!,
              currentOrder!.deliveryAddress!.longitude!,
            ),
          );
        });
        
        // Add markers for both locations
        _addNavigationMarkers();
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  void _addNavigationMarkers() async {
    allMarkers.clear();
    
    // Add current location marker
    if (!currentAddress!.isUnknown()) {
      allMarkers.add(await _createMyLocationMarker());
    }
    
    // Add destination marker
    if (currentOrder?.deliveryAddress != null) {
      allMarkers.add(Marker(
        markerId: const MarkerId('destination'),
        position: LatLng(
          currentOrder!.deliveryAddress!.latitude,
          currentOrder!.deliveryAddress!.longitude,
        ),
        icon: await _createCustomMarkerIcon(
          Icons.flag,
          Colors.green,
          size: 48,
        ),
        infoWindow: InfoWindow(
          title: 'Delivery Address',
          snippet: currentOrder!.deliveryAddress!.address ?? 'Destination',
        ),
      ));
    }
    orders.forEach((order) async {
      allMarkers.add(Marker(
        markerId: MarkerId(order.orderId.toString()),
        position: LatLng(
          order.deliveryAddress!.latitude,
          order.deliveryAddress!.longitude,
        ),
        icon: await _createCustomMarkerIcon(
          Icons.flag,
          Colors.grey,
          size: 48,
        ),
        infoWindow: InfoWindow(
          title: 'Order #${order.orderId}',
          snippet: order.customerName,
        ),
      ));
    }); 
    setState(() {});
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    double dLon = _toRadians(lon2 - lon1);
    double lat1Rad = _toRadians(lat1);
    double lat2Rad = _toRadians(lat2);
    
    double y = math.sin(dLon) * math.cos(lat2Rad);
    double x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);
    
    double bearing = math.atan2(y, x);
    return (bearing * 180 / math.pi + 360) % 360;
  }

  double _getZoomLevelForDistance(double distance) {
    if (distance < 1) return 16;
    if (distance < 2) return 15;
    if (distance < 5) return 14;
    if (distance < 10) return 13;
    if (distance < 20) return 12;
    return 11;
  }

  Future<void> goCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;

    sett.setCurrentLocation().then((currentAddress) {
      setState(() {
        sett.myAddress.value = currentAddress;
        this.currentAddress = currentAddress;
      });
      
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentAddress.latitude!, currentAddress.longitude!),
            zoom: 16,
            tilt: 45,
            bearing: 0,
          ),
        ),
      );
    });
  }

  void getOrdersOfArea() async {
    // Instead of listening for orders in a specific area,
    // we'll fetch all pending orders for this driver
     listenForPendingOrders();
  }

  Future<void> getDirectionSteps() async {
    try {
      print('🔍 getDirectionSteps called');
      if (currentAddress == null) {
        print('❌ currentAddress is null');
        return;
      }
      if (currentOrder?.deliveryAddress == null) {
        print('❌ currentOrder or deliveryAddress is null');
        return;
      }
      
      currentAddress = sett.myAddress.value;
      
      // Calculate route distance and time
      routeDistance = _calculateDistance(
        currentAddress!.latitude ?? 0,
        currentAddress!.longitude ?? 0,
        currentOrder!.deliveryAddress!.latitude ?? 0,
        currentOrder!.deliveryAddress!.longitude ?? 0,
      );
      
      // Estimate time (assuming average speed of 30 km/h in city)
      estimatedTime = ((routeDistance / 30) * 60).round(); // minutes
      
      // Get directions using the new getDirections method
      final origin = LatLng(
        currentAddress!.latitude ?? 0,
        currentAddress!.longitude ?? 0,
      );
      final destination = LatLng(
        currentOrder!.deliveryAddress!.latitude ?? 0,
        currentOrder!.deliveryAddress!.longitude ?? 0,
      );
      
      print('🌐 Requesting directions from (${origin.latitude},${origin.longitude}) to (${destination.latitude},${destination.longitude})');
      final routePoints = await mapsUtil.getDirections(
        origin: origin,
        destination: destination,
      );
      
      print('📌 Received ${routePoints.length} route points');
      if (routePoints.isNotEmpty) {
        // Add the start point to ensure the route is complete
        final completeRoute = [origin, ...routePoints];
        
        setState(() {
          this.routePoints = completeRoute;
          polylines.clear();
          
          // Create animated route polyline
          polylines.add(Polyline(
            visible: true,
            polylineId: const PolylineId('route'),
            points: completeRoute,
            color: config.Colors().mainColor(0.9),
            width: 6,
            patterns: <PatternItem>[PatternItem.dot, PatternItem.gap(10)],
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ));
          
          // Add direction arrows
          _addDirectionArrows(completeRoute);
        });
        
        // Auto-fit camera to show entire route
        _fitCameraToRoute(completeRoute);
      }
    } catch (e) {
      debugPrint('Error getting directions: $e');
      // Optionally show an error message to the user
      if (Get.context != null && Get.context!.mounted) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          const SnackBar(
            content: Text('Could not load directions. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addDirectionArrows(List<LatLng> routePoints) {
    // Add direction indicators along the route
    for (int i = 0; i < routePoints.length - 1; i += 5) {
      if (i + 1 < routePoints.length) {
        double bearing = _calculateBearing(
          routePoints[i].latitude??0,
          routePoints[i].longitude??0,
          routePoints[i + 1].latitude??0,
          routePoints[i + 1].longitude??0,
        );
        
        polylines.add(Polyline(
          polylineId: PolylineId('arrow_$i'),
          points: [routePoints[i]],
          color: config.Colors().mainColor(0.7),
          width: 3,
          patterns: [PatternItem.dot],
        ));
      }
    }
  }

  Future<void> _fitCameraToRoute(List<LatLng> routePoints) async {
    if (routePoints.isEmpty) return;
    
    final GoogleMapController controller = await mapController.future;
    
    double minLat = routePoints.first.latitude;
    double maxLat = routePoints.first.latitude;
    double minLng = routePoints.first.longitude;
    double maxLng = routePoints.first.longitude;
    
    for (LatLng point in routePoints) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }
    
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  void startNavigation() {
    if (routePoints.isEmpty) {
      getDirectionSteps();
      return;
    }
    
    isNavigating = true;
    setState(() {});
    
    // Start navigation simulation (replace with real navigation logic)
    navigationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateNavigationProgress();
    });
  }

  void stopNavigation() {
    isNavigating = false;
    navigationTimer?.cancel();
    navigationTimer = null;
    setState(() {});
  }

  void _updateNavigationProgress() {
    // Simulate navigation progress
    // In real implementation, update current position and recalculate route
    if (routePoints.isNotEmpty && estimatedTime > 0) {
      estimatedTime = math.max(0, estimatedTime - 1);
      setState(() {});
      
      if (estimatedTime <= 0) {
        stopNavigation();
        _onDestinationReached();
      }
    }
  }

  void _onDestinationReached() {
    // Handle destination reached
    print('Destination reached!');
    // You can add completion logic here
  }

  Future<void> animateToDestination() async {
    if (currentOrder?.deliveryAddress == null) return;
    
    final GoogleMapController controller = await mapController.future;
    
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            currentOrder!.deliveryAddress!.latitude!,
            currentOrder!.deliveryAddress!.longitude!,
          ),
          zoom: 18,
          tilt: 60,
          bearing: 0,
        ),
      ),
    );
  }

  Future<void> animateToCurrentLocation() async {
    if (currentAddress == null) return;
    
    final GoogleMapController controller = await mapController.future;
    
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentAddress!.latitude!, currentAddress!.longitude!),
          zoom: 18,
          tilt: 60,
          bearing: 0,
        ),
      ),
    );
  }

  void calculateSubtotal() async {
    if (currentOrder?.foodOrders == null) return;
    
    subTotal = 0;
    currentOrder!.foodOrders?.forEach((food) {
      subTotal += food.quantity! * food.price!;
    });
    
    deliveryFee = currentOrder!.deliveryFee ?? 0;
    taxAmount = (subTotal + deliveryFee) * currentOrder!.tax! / 100;
    total = subTotal + taxAmount + deliveryFee;

    setState(() {});
  }

  Future<void> refreshMap() async {
    setState(() {
      orders = <PendingOrderModel>[];
      allMarkers.clear();
      polylines.clear();
    });
    
    // Refresh pending orders
    listenForPendingOrders(message: "Orders refreshed");
    
    if (currentOrder != null) {
      getDirectionSteps();
      _addNavigationMarkers();
    }
  }

  // Method to accept an order
  Future<bool> acceptOrder(String orderId) async {
    try {
      print('🔍 Attempting to accept order: $orderId');
      
      final currentUser = userRepo.currentUser.value;
      if (currentUser.apiToken == null || currentUser.apiToken!.isEmpty) {
        print('❌ Cannot accept order: No authentication token');
        return false;
      }
      
      // Call your order acceptance API
      // Replace this with your actual acceptance API call
      final response = await acceptOrder(
       orderId,
       
      );

      if (response == true) {
        print('✅ Order $orderId accepted successfully');
        
        // Find and set the accepted order as current order
        final acceptedOrder = orders.firstWhere(
          (order) => order.orderId == orderId,
        
        );
        
        if (acceptedOrder.orderId != null) {
          setState(() {
            currentOrder = acceptedOrder;
          });
          
          // Remove the order from pending list
          orders.removeWhere((order) => order.orderId == orderId);
          
          // Update UI for accepted order
          getDirectionSteps();
          calculateSubtotal();
          
          // Save the accepted order ID to SharedPreferences
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('last_order_id', int.tryParse(orderId) ?? 0);
            print('✅ Saved last_order_id: $orderId to SharedPreferences');
          } catch (e) {
            print('❌ Error saving last_order_id to SharedPreferences: $e');
          }
          
          return true;
        }
      }
      
      // print('❌ Failed to accept order: ${response['message']}');
      return false;
      
    } catch (error) {
      print('❌ Error accepting order: $error');
      return false;
    }
  }

  // Method to decline an order
  Future<bool> declineOrder(String orderId) async {
    try {
      print('🔍 Attempting to decline order: $orderId');
      
      final currentUser = userRepo.currentUser.value;
      if (currentUser.apiToken == null || currentUser.apiToken!.isEmpty) {
        print('❌ Cannot decline order: No authentication token');
        return false;
      }

      // Call your order decline API
      final response = await declineOrder(
        orderId,
        
      );

      if (response == true) {
        print('✅ Order $orderId declined successfully');
        
        // Remove the order from the list
        setState(() {
          orders.removeWhere((order) => order.orderId == orderId);
          allMarkers.removeWhere((marker) => 
            marker.markerId.value == 'order_$orderId'
          );
        });
        
        return true;
      }
      
      // print('❌ Failed to decline order: ${response['message']}');
      return false;
      
    } catch (error) {
      print('❌ Error declining order: $error');
      return false;
    }
  }

  // Method to get available pending orders for selection
  List<PendingOrderModel> getAvailablePendingOrders() {
    return orders.where((order) => order.orderId != currentOrder?.orderId).toList();
  }


  // Helper method to toggle map style for better 3D visualization
  Future<void> toggleMapStyle(bool isDarkMode) async {
    final GoogleMapController controller = await mapController.future;
    
    String mapStyle = isDarkMode ? '''
      [
        {
          "elementType": "geometry",
          "stylers": [{"color": "#212121"}]
        },
        {
          "elementType": "labels.icon",
          "stylers": [{"visibility": "off"}]
        },
        {
          "elementType": "labels.text.fill",
          "stylers": [{"color": "#757575"}]
        },
        {
          "elementType": "labels.text.stroke",
          "stylers": [{"color": "#212121"}]
        }
      ]
    ''' : '''
      [
        {
          "featureType": "all",
          "elementType": "geometry",
          "stylers": [{"color": "#f5f5f5"}]
        },
        {
          "featureType": "poi",
          "elementType": "geometry",
          "stylers": [{"color": "#eeeeee"}]
        }
      ]
    ''';
    
    controller.setMapStyle(mapStyle);
  }
}