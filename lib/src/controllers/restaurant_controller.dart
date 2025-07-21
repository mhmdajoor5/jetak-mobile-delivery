import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/food.dart';
import '../models/gallery.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../repository/food_repository.dart';
import '../repository/gallery_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';

class RestaurantController extends ControllerMVC {
 late Restaurant restaurant;
  List<Gallery> galleries = <Gallery>[];
  List<Food> foods = <Food>[];
  List<Food> trendingFoods = <Food>[];
  List<Food> featuredFoods = <Food>[];
  List<Review> reviews = <Review>[];
  late GlobalKey<ScaffoldState> scaffoldKey;

  RestaurantController() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  void listenForRestaurant({String? id, String? message}) async {
    final Stream<Restaurant> stream = await getRestaurant(id!, myAddress.value);
    stream.listen((Restaurant restaurant) {
      setState(() => restaurant = restaurant);
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
        content: Text(S.of(state!.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForGalleries(String idRestaurant) async {
    final Stream<Gallery> stream = await getGalleries(idRestaurant);
    stream.listen((Gallery gallery) {
      setState(() => galleries.add(gallery));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForRestaurantReviews({String? id, String? message}) async {
    final Stream<Review> stream = await getRestaurantReviews(id!);
    stream.listen((Review review) {
      setState(() => reviews.add(review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForFoods(String idRestaurant) async {
    final Stream<Food> stream = await getFoodsOfRestaurant(idRestaurant);
    stream.listen((Food food) {
      setState(() => foods.add(food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForTrendingFoods(String idRestaurant) async {
    final Stream<Food> stream = await getTrendingFoodsOfRestaurant(idRestaurant);
    stream.listen((Food food) {
      setState(() => trendingFoods.add(food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForFeaturedFoods(String idRestaurant) async {
    final Stream<Food> stream = await getFeaturedFoodsOfRestaurant(idRestaurant);
    stream.listen((Food food) {
      setState(() => featuredFoods.add(food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> refreshRestaurant() async {
    var id = restaurant.id;
    restaurant = Restaurant();
    galleries.clear();
    reviews.clear();
    featuredFoods.clear();
    listenForRestaurant(id: id ??"", message: S.of(state!.context).restaurant_refreshed_successfuly);
    listenForRestaurantReviews(id: id??"");
    listenForGalleries(id??"");
    listenForFeaturedFoods(id??"");
  }
}
