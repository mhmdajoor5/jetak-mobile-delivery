import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class Cart {
  String? id;
  Food? food;
  double? quantity;
  List<Extra>? extras;
  String? userId;

  Cart();

  Cart.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      quantity = jsonMap['quantity'] != null ? jsonMap['quantity'].toDouble() : 0.0;
      food = jsonMap['food'] != null ? Food.fromJson(jsonMap['food']) : Food();
      extras = jsonMap['extras'] != null ? List.from(jsonMap['extras']).map((element) => Extra.fromJSON(element)).toList() : [];
      food!.copyWith(price: () => getFoodPrice());
    } catch (e) {
      id = '';
      quantity = 0.0;
      food = Food();
      extras = [];
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Map toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["quantity"] = quantity;
    map["food_id"] = food?.id;
    map["user_id"] = userId;
    map["extras"] = extras?.map((element) => element.id).toList();
    return map;
  }

  double getFoodPrice() {
    double result = food!.price!;
    if (extras?.isNotEmpty ?? false) {
      for (var extra in extras!) {
        result += extra.price != null ? extra.price! : 0;
      }
    }
    return result;
  }

  bool isSame(Cart cart) {
    bool same = true;
    same &= food == cart.food;
    same &= extras?.length == cart.extras?.length;
    if (same) {
      extras?.forEach((Extra extra) {
        same &= cart.extras!.contains(extra);
      });
    }
    return same;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == id;
  }

}
