import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/cart.dart';
import '../models/extra.dart';
import '../models/favorite.dart';
import '../models/food.dart';
import '../repository/food_repository.dart';

class FoodController extends ControllerMVC {
  Food? food;
  double quantity = 1;
  double total = 0;
  Cart? cart;
  Favorite? favorite;
  bool loadCart = false;
  late GlobalKey<ScaffoldState> scaffoldKey;

  FoodController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void listenForFood({String? foodId, String? message}) async {
    final Stream<Food> stream = await getFood(foodId!);
    stream.listen(
      (Food food) {
        setState(() => food = food);
      },
      onError: (a) {
        print(a);
        // scaffoldKey.currentState?.showSnackBar(SnackBar(
        //   content: Text(S.of(state!.context).verify_your_internet_connection),
        // ));
      },
      onDone: () {
        calculateTotal();
        if (message != null) {
          // scaffoldKey.currentState?.showSnackBar(SnackBar(
          //   content: Text(message),
          // ));
        }
      },
    );
  }

  void listenForFavorite({String? foodId}) async {
    final Stream<Favorite> stream = await isFavoriteFood(foodId!);
    stream.listen(
      (Favorite favorite) {
        setState(() => favorite = favorite);
      },
      onError: (a) {
        print(a);
      },
    );
  }

  bool isSameRestaurants(Food food) {
    if (cart != null) {
      return cart!.food?.restaurant?.id == food.restaurant?.id;
    }
    return true;
  }

  void addToFavorite(Food food) async {
    var favorite = Favorite();
    favorite.food = food;
    favorite.extras =
        food.extras?.where((Extra extra) {
          return extra.checked!;
        }).toList();
    addFavorite(favorite).then((value) {
      setState(() {
        favorite = value;
      });
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('This food was added to favorite')),
      );
    });
  }

  void removeFromFavorite(Favorite favorite) async {
    removeFavorite(favorite).then((value) {
      setState(() {
        favorite = Favorite();
      });
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(
        SnackBar(content: Text('This food was removed from favorites')),
      );
    });
  }

  Future<void> refreshFood() async {
    var id = food!.id;
    food = Food();
    listenForFavorite(foodId: id);
    listenForFood(foodId: id, message: 'Food refreshed successfuly');
  }

  void calculateTotal() {
    total = food?.price ?? 0;
    food!.extras?.forEach((extra) {
      total += extra.checked! ? extra.price! : 0;
    });
    total *= quantity;
    setState(() {});
  }

  void incrementQuantity() {
    if (quantity <= 99) {
      ++quantity;
      calculateTotal();
    }
  }

  void decrementQuantity() {
    if (quantity > 1) {
      --quantity;
      calculateTotal();
    }
  }
}
