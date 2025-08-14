import '../helpers/helper.dart';
import '../models/media.dart';

enum UserState { available, away, busy }

class User {
  String? id;
  String? name;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  String? languagesSpoken;
  String? dateOfBirth;
  String? country;
  String? vehicleType;
  String? referralCode;
  String? deliveryCity;
  String? apiToken;
  String? deviceToken;
  String? languagesSpokenCode;
  String? phone;
  bool? verifiedPhone;
  String? verificationId;
  String? address;
  String? bio;
  Media? image;
  String? document1;
  String? document2;
  String? document3;
  String? document4;
  String? document5;

  // used for indicate if client logged in or not
  bool? auth;
  bool? available;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id']?.toString() ?? '';
      document1 = jsonMap['document1']?.toString() ?? '';
      document2 = jsonMap['document2']?.toString() ?? '';
      document3 = jsonMap['document3']?.toString() ?? '';
      document4 = jsonMap['document4']?.toString() ?? '';
      document5 = jsonMap['document5']?.toString() ?? '';
      available = jsonMap['available'];
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      firstName = jsonMap['firstName'] != null ? jsonMap['firstName'] : '';
      lastName = jsonMap['lastName'] != null ? jsonMap['lastName'] : '';
      languagesSpoken = jsonMap['languagesSpoken'] != null ? jsonMap['languagesSpoken'] : '';
      dateOfBirth = jsonMap['dateOfBirth'] != null ? jsonMap['dateOfBirth'] : '';
      country = jsonMap['country'] != null ? jsonMap['country'] : '';
      deliveryCity = jsonMap['deliveryCity'] != null ? jsonMap['deliveryCity'] : '';
      languagesSpokenCode = jsonMap['languagesSpokenCode']?.toString() ?? '';
      vehicleType = jsonMap['vehicleType'] != null ? jsonMap['vehicleType'] : '';
      referralCode = jsonMap['referralCode'] != null ? jsonMap['referralCode'] : '';
      apiToken = jsonMap['api_token'];
      deviceToken = jsonMap['device_token'];
      try {
        phone = jsonMap['custom_fields']['phone']['view'];
      } catch (e) {
        phone = "";
      }
      try {
        verifiedPhone = jsonMap['custom_fields']['verifiedPhone']['view'] == '1'
            ? true
            : false;
      } catch (e) {
        verifiedPhone = false;
      }
      try {
        address = jsonMap['custom_fields']['address']['view'];
      } catch (e) {
        address = "";
      }
      try {
        bio = jsonMap['custom_fields']['bio']['view'];
      } catch (e) {
        bio = "";
      }
      image = jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty
          ? Media.fromJSON(jsonMap['media'][0])
          : Media();
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["document1"] = document1;
    map["document2"] = document2;
    map["document3"] = document3;
    map["document4"] = document4;
    map["document5"] = document5;
    map["available"] = available;
    map["email"] = email;
    map["name"] = name;
    map["password"] = password;
    map["firstName"] = firstName;
    map["lastName"] = lastName;
    map["languagesSpoken"] = languagesSpoken;
    map["dateOfBirth"] = dateOfBirth;
    map["country"] = country;
    map["deliveryCity"] = deliveryCity;
    map["languagesSpokenCode"] = languagesSpokenCode;
    map["vehicleType"] = vehicleType;
    map["referralCode"] = referralCode;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["phone"] = phone;
    map["verifiedPhone"] = verifiedPhone;
    map["address"] = address;
    map["bio"] = bio;
    map["media"] = image?.toMap();
    if (image != null && image?.id != null && Helper.isUuid(image!.id!)) {
      map['avatar'] = image?.id;
    }
    return map;
  }

  Map<String, dynamic> toRestrictMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["document1"] = document1;
    map["document2"] = document2;
    map["document3"] = document3;
    map["document4"] = document4;
    map["document5"] = document5;
    map["available"] = available;
    map["email"] = email;
    map["name"] = name;
    map["thumb"] = image?.thumb;
    map["device_token"] = deviceToken;
    return map;
  }

  @override
  String toString() {
    var map = toMap();
    map["auth"] = auth;
    return map.toString();
  }

  bool profileCompleted() {
    return address != null &&
        address != '' &&
        phone != null &&
        phone != '' &&
        verifiedPhone != null &&
        verifiedPhone!;
  }
}
