import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class Favorite {
  String? id;
  Food? food;
  List<Extra>? extras;
  String? userId;

  Favorite();

  Favorite.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id']?.toString();
      food = jsonMap['food'] != null ? Food.fromJSON(jsonMap['food']) : Food();
      extras = jsonMap['extras'] != null ? List.from(jsonMap['extras']).map((element) => Extra.fromJSON(element)).toList() : null;
    } catch (e) {
      id = '';
      food = Food();
      extras = [];
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Map toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["food_id"] = food?.id;
    map["user_id"] = userId;
    map["extras"] = extras?.map((element) => element.id).toList();
    return map;
  }
}
