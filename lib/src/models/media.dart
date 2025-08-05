// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';

class Media {
  String? id;
  String? name;
  String? url;
  String? thumb;
  String? icon;
  String? size;
  String? modelType;
  int? modelId;
  String? collectionName;
  String? fileName;
  String? mimeType;
  String? disk;
  int? orderColumn;
  DateTime? createdAt;
  DateTime? updatedAt;

  Media() {
    url = Helper.fixImageUrl("images/image_default.png");
    thumb = Helper.fixImageUrl("images/image_default.png");
    icon = Helper.fixImageUrl("images/image_default.png");
  }

  Media.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id']?.toString();
      name = jsonMap['name'];
      url = Helper.fixImageUrl(jsonMap['url']);
      thumb = Helper.fixImageUrl(jsonMap['thumb']);
      icon = Helper.fixImageUrl(jsonMap['icon']);
      size = jsonMap['formated_size'];
      
      // New fields from the extended JSON
      modelType = jsonMap['model_type'];
      modelId = jsonMap['model_id'];
      collectionName = jsonMap['collection_name'];
      fileName = jsonMap['file_name'];
      mimeType = jsonMap['mime_type'];
      disk = jsonMap['disk'];
      orderColumn = jsonMap['order_column'];
      createdAt = jsonMap['created_at'] != null ? DateTime.parse(jsonMap['created_at']) : null;
      updatedAt = jsonMap['updated_at'] != null ? DateTime.parse(jsonMap['updated_at']) : null;
      
    } catch (e, s) {
      url = Helper.fixImageUrl("images/image_default.png");
      thumb = Helper.fixImageUrl("images/image_default.png");
      icon = Helper.fixImageUrl("images/image_default.png");
      print(CustomTrace(s, message: e.toString()));
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["name"] = name;
    map["url"] = url;
    map["thumb"] = thumb;
    map["icon"] = icon;
    map["formated_size"] = size;

    // Adding new fields to the map
    map['model_type'] = modelType;
    map['model_id'] = modelId;
    map['collection_name'] = collectionName;
    map['file_name'] = fileName;
    map['mime_type'] = mimeType;
    map['disk'] = disk;
    map['order_column'] = orderColumn;
    map['created_at'] = createdAt?.toIso8601String();
    map['updated_at'] = updatedAt?.toIso8601String();

    return map;
  }

  @override
  String toString() {
    return 'Media(id: $id, name: $name, url: $url, thumb: $thumb, icon: $icon, size: $size, modelType: $modelType)';
  }
}