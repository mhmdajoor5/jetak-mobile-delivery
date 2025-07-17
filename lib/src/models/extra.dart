// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Extra {
  String? id;
  String? extraGroupId;
  String? name;
  double? price;
  Media? image;
  String? description;
  bool? checked;

  Extra();

  Extra.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id']?.toString() ?? '';
      extraGroupId =
          jsonMap['extra_group_id'] != null
              ? jsonMap['extra_group_id'].toString()
              : '0';
      name = jsonMap['name'].toString();
      price = jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0;
      description = jsonMap['description'];
      checked = false;
      image =
          jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty
              ? Media.fromJSON(jsonMap['media'][0])
              : Media();
    } catch (e) {
      id = '';
      extraGroupId = '0';
      name = '';
      price = 0.0;
      description = '';
      checked = false;
      image = Media();
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Map toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    map["description"] = description;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Extra(id: $id, extraGroupId: $extraGroupId, name: $name, price: $price, image: $image, description: $description, checked: $checked)';
  }
}
