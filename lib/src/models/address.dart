import 'package:location/location.dart';

import '../helpers/custom_trace.dart';

class Address {
  String? id;
  String? description;
  String? address;
  double? latitude;
  double? longitude;
  bool? isDefault;
  String? userId;
  DateTime? createdAt; // New field
  DateTime? updatedAt; // New field
  List<dynamic>? customFields; // New field

  Address();

  Address.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id']?.toString() ?? '';
      description = jsonMap['description']?.toString();
      address = jsonMap['address'];
      latitude = jsonMap['latitude']?.toDouble();
      longitude = jsonMap['longitude']?.toDouble();
      isDefault = jsonMap['is_default'] ?? false;
      userId = jsonMap['user_id']?.toString(); // userId was missing from your fromJSON
      
      // New fields from the extended JSON
      createdAt = jsonMap['created_at'] != null ? DateTime.parse(jsonMap['created_at']) : null;
      updatedAt = jsonMap['updated_at'] != null ? DateTime.parse(jsonMap['updated_at']) : null;
      customFields = jsonMap['custom_fields'];
      
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  bool isUnknown() {
    return latitude == null || longitude == null;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["description"] = description;
    map["address"] = address;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["is_default"] = isDefault;
    map["user_id"] = userId;
    
    // Adding new fields to the map
    map['created_at'] = createdAt?.toIso8601String();
    map['updated_at'] = updatedAt?.toIso8601String();
    map['custom_fields'] = customFields;
    
    return map;
  }

  LocationData toLocationData() {
    return LocationData.fromMap({
      "latitude": latitude,
      "longitude": longitude,
    });
  }
}