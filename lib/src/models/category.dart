import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Category {
  String? id;
  String? name;
  Media? image;

  Category();

  Category.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).isNotEmpty ? Media.fromJSON(jsonMap['media'][0]) : Media();
    } catch (e) {
      id = '';
      name = '';
      image = Media();
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }
}
