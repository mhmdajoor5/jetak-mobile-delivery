import 'package:global_configuration/global_configuration.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';

class Media {
  String? id;
  String? name;
  String? url;
  String? thumb;
  String? icon;
  String? size;

  Media() {
    url = Helper.fixImageUrl("images/image_default.png");
    thumb = Helper.fixImageUrl("images/image_default.png");
    icon = Helper.fixImageUrl("images/image_default.png");
  }

  Media.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      url = Helper.fixImageUrl(jsonMap['url']);
      thumb = Helper.fixImageUrl(jsonMap['thumb']);
      icon = Helper.fixImageUrl(jsonMap['icon']);
      size = jsonMap['formated_size'];
    } catch (e) {
      url = Helper.fixImageUrl("images/image_default.png");
      thumb = Helper.fixImageUrl("images/image_default.png");
      icon = Helper.fixImageUrl("images/image_default.png");
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["url"] = url;
    map["thumb"] = thumb;
    map["icon"] = icon;
    map["formated_size"] = size;
    return map;
  }

  @override
  String toString() {
    return this.toMap().toString();
  }
}
