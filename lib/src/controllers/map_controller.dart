import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import '../helpers/maps_util.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';
import '../repository/settings_repository.dart' as sett;

class MapController extends ControllerMVC {
  Order? currentOrder;
  List<Order> orders = <Order>[];
  List<Marker> allMarkers = <Marker>[];
  Address? currentAddress;
  Set<Polyline> polylines = {};
  CameraPosition? cameraPosition;
  MapsUtil mapsUtil = MapsUtil();
  double taxAmount = 0.0;
  double subTotal = 0.0;
  double deliveryFee = 0.0;
  double total = 0.0;
  Completer<GoogleMapController> mapController = Completer();

  void listenForNearOrders(Address myAddress, Address areaAddress) async {
    print('listenForOrders');
    final Stream<Order> stream = await getNearOrders(myAddress, areaAddress);
    stream.listen(
        (Order order) {
          setState(() {
            orders.add(order);
          });
          if (!order.deliveryAddress!.isUnknown()) {
            Helper.getOrderMarker(order.deliveryAddress?.toMap() as Map<String, dynamic>).then((marker) {
              setState(() {
                allMarkers.add(marker);
              });
            });
          }
        },
        onError: (a) {},
        onDone: () {
          calculateSubtotal();
        });
  }

  void getCurrentLocation() async {
    try {
      currentAddress = sett.myAddress.value;
      setState(() {
        if (currentAddress!.isUnknown()) {
          cameraPosition = CameraPosition(
            target: LatLng(40, 3),
            zoom: 4,
          );
        } else {
          cameraPosition = CameraPosition(
            target: LatLng(currentAddress!.latitude!, currentAddress!.longitude!),
            zoom: 14.4746,
          );
        }
      });
      if (!currentAddress!.isUnknown() ) {
        Helper.getMyPositionMarker(currentAddress!.latitude!, currentAddress!.longitude!).then((marker) {
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

  void getOrderLocation() async {
    try {
      currentAddress = sett.myAddress.value;
      setState(() {
        cameraPosition = CameraPosition(
          target: LatLng(currentOrder!.deliveryAddress!.latitude!, currentOrder!.deliveryAddress!.longitude!),
          zoom: 14.4746,
        );
      });
      if (!currentAddress!.isUnknown()) {
        Helper.getMyPositionMarker(currentAddress!.latitude!, currentAddress!.longitude!).then((marker) {
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

  Future<void> goCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;

    sett.setCurrentLocation().then((currentAddress) {
      setState(() {
        sett.myAddress.value = currentAddress;
        currentAddress = currentAddress;
      });
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(currentAddress.latitude!, currentAddress.longitude!),
        zoom: 14.4746,
      )));
    });
  }

  void getOrdersOfArea() async {
    setState(() {
      orders = <Order>[];
      Address areaAddress = Address.fromJSON({"latitude": cameraPosition!.target.latitude, "longitude": cameraPosition!.target.longitude});
      if (cameraPosition != null) {
        listenForNearOrders(currentAddress!, areaAddress);
      } else {
        listenForNearOrders(currentAddress!, currentAddress!);
      }
    });
  }

  void getDirectionSteps() async {
    currentAddress = sett.myAddress.value;
    mapsUtil
        .get("origin=${currentAddress!.latitude},${currentAddress!.longitude}&destination=${currentOrder!.deliveryAddress!.longitude},${currentOrder!.deliveryAddress!.longitude}&key=${sett.setting.value.googleMapsKey}")
        .then((dynamic res) {
      if (res != null) {
        List<LatLng> latLng = res as List<LatLng>;
        latLng.insert(0, LatLng(currentAddress!.latitude!, currentAddress!.longitude!));
        setState(() {
          polylines.add(Polyline(
              visible: true, polylineId: PolylineId(currentAddress.hashCode.toString()), points: latLng, color: config.Colors().mainColor(0.8), width: 6));
        });
      }
    });
  }

  void calculateSubtotal() async {
    subTotal = 0;
    currentOrder!.foodOrders?.forEach((food) {
      subTotal += food.quantity! * food.price!;
    });
    deliveryFee = currentOrder!.foodOrders?.elementAt(0).food?.restaurant?.deliveryFee ?? 0;
    taxAmount = (subTotal + deliveryFee) * currentOrder!.tax! / 100;
    total = subTotal + taxAmount + deliveryFee;

    taxAmount = subTotal * currentOrder!.tax! / 100;
    total = subTotal + taxAmount;
    setState(() {});
  }

  Future refreshMap() async {
    setState(() {
      orders = <Order>[];
    });
    listenForNearOrders(currentAddress!, currentAddress!);
  }
}
