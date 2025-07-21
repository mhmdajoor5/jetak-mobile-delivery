import '../helpers/custom_trace.dart';
import '../models/food.dart';
import '../models/restaurant.dart';
import '../models/user.dart';

class Review {
  String? id;
  String? review;
  String? rate;
  User? user;

  Review();
  Review.init(this.rate);

  Review.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      review = jsonMap['review'];
      rate = jsonMap['rate'].toString() ?? '0';
      user = jsonMap['user'] != null ? User.fromJSON(jsonMap['user']) : User();
    } catch (e) {
      id = '';
      review = '';
      rate = '0';
      user = User();
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Map toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["review"] = review;
    map["rate"] = rate;
    map["user_id"] = user?.id;
    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  Map ofRestaurantToMap(Restaurant restaurant) {
    var map = toMap();
    map["restaurant_id"] = restaurant.id;
    return map;
  }

  Map ofFoodToMap(Food food) {
    var map = toMap();
    map["food_id"] = food.id;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
