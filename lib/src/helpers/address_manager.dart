import 'package:flutter/material.dart';
import 'package:location/location.dart';

import '../models/address.dart';
import 'app_preferences.dart';

/// Manages all address-related functionality for the app.
class AddressManager {
  static final AddressManager _instance = AddressManager._internal();
  factory AddressManager() => _instance;
  AddressManager._internal();

  final AppPreferences _appPreferences = AppPreferences();
  
  // Address ValueNotifiers
  final ValueNotifier<Address> deliveryAddress = ValueNotifier(Address());
  final ValueNotifier<Address> billingAddress = ValueNotifier(Address());
  final ValueNotifier<Address> pickupAddress = ValueNotifier(Address());
  final ValueNotifier<Address> currentLocation = ValueNotifier(Address());
  final ValueNotifier<Address> currentAddress = ValueNotifier(Address());

  /// Initializes address data from shared preferences.
  Future<void> init() async {
    try {
      // Load saved addresses from preferences
      final savedAddresses = await _appPreferences.getSavedAddresses();
      
      if (savedAddresses.isNotEmpty) {
        deliveryAddress.value = savedAddresses['delivery'] ?? Address();
        billingAddress.value = savedAddresses['billing'] ?? Address();
        pickupAddress.value = savedAddresses['pickup'] ?? Address();
        currentAddress.value = savedAddresses['current'] ?? Address();
        currentLocation.value = await _appPreferences.getCurrentLocation();
      }
    } catch (e) {
      debugPrint('❌ Error initializing addresses: $e');
    }
  }

  /// Updates the current location and saves it to preferences.
  Future<void> updateCurrentLocation(Address address) async {
    try {
      currentLocation.value = address;
      currentAddress.value = address; // Also update current address
      await _appPreferences.saveCurrentLocation(address);
    } catch (e) {
      debugPrint('❌ Error updating current location: $e');
      rethrow;
    }
  }

  /// Updates the delivery address and saves it to preferences.
  Future<void> updateDeliveryAddress(Address address) async {
    try {
      deliveryAddress.value = address;
      await _appPreferences.saveAddress('delivery', address);
    } catch (e) {
      debugPrint('❌ Error updating delivery address: $e');
      rethrow;
    }
  }

  /// Updates the billing address and saves it to preferences.
  Future<void> updateBillingAddress(Address address) async {
    try {
      billingAddress.value = address;
      await _appPreferences.saveAddress('billing', address);
    } catch (e) {
      debugPrint('❌ Error updating billing address: $e');
      rethrow;
    }
  }

  /// Updates the pickup address and saves it to preferences.
  Future<void> updatePickupAddress(Address address) async {
    try {
      pickupAddress.value = address;
      await _appPreferences.saveAddress('pickup', address);
    } catch (e) {
      debugPrint('❌ Error updating pickup address: $e');
      rethrow;
    }
  }

  /// Gets the current location from the device.
  Future<Address> getCurrentLocation() async {
    try {
      final location = Location();
      final hasPermission = await _checkLocationPermission(location);
      
      if (!hasPermission) {
        throw Exception('Location permission not granted');
      }

      final locationData = await location.getLocation();
      final address = Address()
        ..latitude = locationData.latitude
        ..longitude = locationData.longitude
        ..address = 'Current Location';
      
      await updateCurrentLocation(address);
      return address;
    } catch (e) {
      debugPrint('❌ Error getting current location: $e');
      rethrow;
    }
  }

  /// Checks and requests location permissions.
  Future<bool> _checkLocationPermission(Location location) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if location service is enabled
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    // Check location permission
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  /// Clears all saved addresses.
  Future<void> clearAddresses() async {
    try {
      await _appPreferences.clearAddresses();
      deliveryAddress.value = Address();
      billingAddress.value = Address();
      pickupAddress.value = Address();
      currentAddress.value = Address();
      currentLocation.value = Address();
    } catch (e) {
      debugPrint('❌ Error clearing addresses: $e');
      rethrow;
    }
  }
}
