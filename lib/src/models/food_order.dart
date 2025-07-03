// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class FoodOrder {
  String? id;
  double? price;
  double? quantity;
  List<Extra>? extras;
  Food? food;
  DateTime? dateTime;
  FoodOrder();

  FoodOrder.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id']?.toString() ?? '';
      price = jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
      quantity =
          jsonMap['quantity'] != null ? jsonMap['quantity'].toDouble() : 0.0;
      food =
          (jsonMap['food'] != null ? Food.fromJSON(jsonMap['food']) : Food())
              as Food?;
      dateTime =
          jsonMap['updated_at'] != null
              ? DateTime.parse(jsonMap['updated_at'])
              : DateTime.now();
      extras =
          jsonMap['extras'] != null
              ? List.from(
                jsonMap['extras'],
              ).map((element) => Extra.fromJSON(element)).toList()
              : <Extra>[];
    } catch (e) {
      id = '';
      price = 0.0;
      quantity = 0.0;
      food = Food();
      dateTime = DateTime.now();
      extras = <Extra>[];
      print(CustomTrace(StackTrace.current, message: e.toString()));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["price"] = price;
    map["quantity"] = quantity;
    map["food_id"] = food?.id;
    map["extras"] = extras?.map((element) => element.id).toList();
    return map;
  }

  @override
  String toString() {
    return 'FoodOrder(id: $id, price: $price, quantity: $quantity, extras: $extras, food: $food, dateTime: $dateTime)';
  }
}
