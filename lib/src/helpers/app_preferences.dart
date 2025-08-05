import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';
import '../models/setting.dart';

/// A utility class for managing SharedPreferences and API endpoints
class AppPreferences {
  static const String _keySettings = 'settings';
  static const String _keyMyAddress = 'my_address';
  static const String _keyDeliveryAddress = 'delivery_address';
  static const String _keyIsDark = 'isDark';
  static const String _keyLanguage = 'language';
  static const String _keyGoogleMessageId = 'google.message_id';
  
  // API Endpoints
  static const String endpointSettings = 'settings';
  
  static final AppPreferences _instance = AppPreferences._internal();
  late SharedPreferences _prefs;
  
  /// Private constructor
  AppPreferences._internal();
  
  /// Factory constructor to ensure a single instance
  factory AppPreferences() => _instance;
  
  /// Initialize the preferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // ========== Settings Management ==========
  
  /// Save app settings to SharedPreferences
  Future<bool> saveSettings(Setting settings) async {
    try {
      return await _prefs.setString(
        _keySettings, 
        json.encode(settings.toMap())
      );
    } catch (e) {
      debugPrint('❌ Error saving settings: $e');
      return false;
    }
  }
  
  /// Get saved settings from SharedPreferences
  Setting? getSettings() {
    try {
      final settingsJson = _prefs.getString(_keySettings);
      if (settingsJson != null) {
        return Setting.fromJSON(json.decode(settingsJson));
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting settings: $e');
      return null;
    }
  }
  
  /// Check if dark mode is enabled
  bool isDarkMode() {
    try {
      return _prefs.getBool(_keyIsDark) ?? false;
    } catch (e) {
      debugPrint('❌ Error getting dark mode preference: $e');
      return false;
    }
  }
  
  /// Toggle dark mode
  Future<bool> toggleDarkMode() async {
    try {
      final isDark = !(isDarkMode());
      return await _prefs.setBool(_keyIsDark, isDark);
    } catch (e) {
      debugPrint('❌ Error toggling dark mode: $e');
      return false;
    }
  }
  
  // ========== Address Management ==========
  
  /// Save an address with the given key
  Future<bool> saveAddress(String key, Address address) async {
    try {
      return await _prefs.setString(
        'address_$key',
        json.encode(address.toMap()),
      );
    } catch (e) {
      debugPrint('❌ Error saving address ($key): $e');
      return false;
    }
  }
  
  /// Get an address by key
  Address? getAddress(String key) {
    try {
      final addressJson = _prefs.getString('address_$key');
      if (addressJson != null) {
        return Address.fromJSON(json.decode(addressJson));
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting address ($key): $e');
      return null;
    }
  }
  
  /// Save the current location
  Future<bool> saveCurrentLocation(Address location) async {
    try {
      return await _prefs.setString(
        'current_location',
        json.encode(location.toMap()),
      );
    } catch (e) {
      debugPrint('❌ Error saving current location: $e');
      return false;
    }
  }
  
  /// Get the current location
  Future<Address> getCurrentLocation() async {
    try {
      final locationJson = _prefs.getString('current_location');
      if (locationJson != null) {
        return Address.fromJSON(json.decode(locationJson));
      }
      return Address();
    } catch (e) {
      debugPrint('❌ Error getting current location: $e');
      return Address();
    }
  }
  
  /// Get all saved addresses
  Future<Map<String, Address>> getSavedAddresses() async {
    try {
      final addresses = <String, Address>{};
      
      // Get all saved address keys
      final keys = _prefs.getKeys().where((key) => key.startsWith('address_')).toList();
      
      for (final key in keys) {
        final addressKey = key.replaceFirst('address_', '');
        final address = getAddress(addressKey);
        if (address != null) {
          addresses[addressKey] = address;
        }
      }
      
      return addresses;
    } catch (e) {
      debugPrint('❌ Error getting saved addresses: $e');
      return {};
    }
  }
  
  /// Clear all saved addresses
  Future<void> clearAddresses() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith('address_')).toList();
      for (final key in keys) {
        await _prefs.remove(key);
      }
      await _prefs.remove('current_location');
    } catch (e) {
      debugPrint('❌ Error clearing addresses: $e');
      rethrow;
    }
  }
  
  /// Clear all user-specific data (for logout)
  Future<void> clearUserData() async {
    try {
      // Clear all preferences except app settings
      final keysToKeep = [_keySettings, _keyIsDark, _keyLanguage];
      final keysToRemove = _prefs.getKeys().where((key) => !keysToKeep.contains(key));
      
      for (final key in keysToRemove) {
        await _prefs.remove(key);
      }
      
      debugPrint('✅ Cleared all user data');
    } catch (e) {
      debugPrint('❌ Error clearing user data: $e');
      rethrow;
    }
  }
  
  // ========== Settings Methods ==========
  
  /// Load app settings from SharedPreferences
  Setting? loadSettings() {
    try {
      final settingsJson = _prefs.getString(_keySettings);
      if (settingsJson != null) {
        return Setting.fromJSON(json.decode(settingsJson));
      }
    } catch (e) {
      debugPrint('❌ Error loading settings: $e');
    }
    return null;
  }
  
  // ========== Theme & Language Methods ==========
  
  /// Save theme preference (dark/light mode)
  Future<bool> saveThemePreference(Brightness brightness) {
    return _prefs.setBool(_keyIsDark, brightness == Brightness.dark);
  }
  
  /// Get current theme preference
  Brightness getThemePreference() {
    return _prefs.getBool(_keyIsDark) ?? false 
        ? Brightness.dark 
        : Brightness.light;
  }
  
  /// Save language preference
  Future<bool> saveLanguagePreference(Locale locale) {
    return _prefs.setString(_keyLanguage, locale.languageCode);
  }
  
  /// Get saved language preference
  Locale getLanguagePreference([String defaultLanguage = 'en']) {
    final languageCode = _prefs.getString(_keyLanguage) ?? defaultLanguage;
    return Locale(languageCode);
  }
  
  // ========== Address Methods ==========
  
  /// Save current location address
  Future<bool> saveMyAddress(Address address) async {
    try {
      return await _prefs.setString(
        _keyMyAddress, 
        json.encode(address.toMap())
      );
    } catch (e) {
      debugPrint('❌ Error saving address: $e');
      return false;
    }
  }
  
  /// Load saved current location
  Address? loadMyAddress() {
    try {
      final addressJson = _prefs.getString(_keyMyAddress);
      if (addressJson != null) {
        return Address.fromJSON(json.decode(addressJson));
      }
    } catch (e) {
      debugPrint('❌ Error loading address: $e');
    }
    return null;
  }
  
  /// Save delivery address
  Future<bool> saveDeliveryAddress(Address address) async {
    try {
      return await _prefs.setString(
        _keyDeliveryAddress, 
        json.encode(address.toMap())
      );
    } catch (e) {
      debugPrint('❌ Error saving delivery address: $e');
      return false;
    }
  }
  
  /// Load saved delivery address
  Address? loadDeliveryAddress() {
    try {
      final addressJson = _prefs.getString(_keyDeliveryAddress);
      if (addressJson != null) {
        return Address.fromJSON(json.decode(addressJson));
      }
    } catch (e) {
      debugPrint('❌ Error loading delivery address: $e');
    }
    return null;
  }
  
  // ========== Notification Methods ==========
  
  /// Save FCM message ID
  Future<bool> saveMessageId(String messageId) {
    return _prefs.setString(_keyGoogleMessageId, messageId);
  }
  
  /// Get saved FCM message ID
  String? getMessageId() {
    return _prefs.getString(_keyGoogleMessageId);
  }
  
  // ========== Helper Methods ==========
  
  /// Clear all preferences (for logout)
  Future<bool> clearAll() async {
    try {
      // Keep language and theme preferences on logout
      final language = _prefs.getString(_keyLanguage);
      final isDark = _prefs.getBool(_keyIsDark) ?? false;
      
      await _prefs.clear();
      
      // Restore preferences
      if (language != null) {
        await _prefs.setString(_keyLanguage, language);
      }
      await _prefs.setBool(_keyIsDark, isDark);
      
      return true;
    } catch (e) {
      debugPrint('❌ Error clearing preferences: $e');
      return false;
    }
  }
  
  /// Clear a specific key
  Future<bool> clearKey(String key) async {
    return await _prefs.remove(key);
  }
}

// Global instance of AppPreferences
final appPreferences = AppPreferences();
