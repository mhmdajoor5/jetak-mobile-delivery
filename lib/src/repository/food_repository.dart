import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/favorite.dart';
import '../models/food.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Food>> getTrendingFoods() async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}foods?with=restaurant&limit=6';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
    return Food.fromJson(data);
  });
}

Future<Stream<Food>> getFood(String foodId) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}foods/$foodId?with=nutrition;restaurant;category;extras;foodReviews;foodReviews.user';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).map((data) {
    print(Food.fromJson(data).restaurant!.toJson());
    return Food.fromJson(data);
  });
}

Future<Stream<Food>> getFoodsByCategory(categoryId) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}foods?with=restaurant&search=category_id:$categoryId&searchFields=category_id:=';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
    return Food.fromJson(data);
  });
}

Future<Stream<Favorite>> isFavoriteFood(String foodId) async {
  User user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return Stream.value(Favorite());
  }
  final String apiToken = 'api_token=${user.apiToken}&';
  final String url = '${GlobalConfiguration().getString('api_base_url')}favorites/exist?${apiToken}food_id=$foodId&user_id=${user.id}';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getObjectData(data as Map<String,dynamic>)).map((data) => Favorite.fromJSON(data));
}

Future<Stream<Favorite>> getFavorites() async {
  User user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return Stream.value(Favorite());
  }
  final String apiToken = 'api_token=${user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}favorites?${apiToken}with=food;user;extras&search=user_id:${user.id}&searchFields=user_id:=';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data as Map<String,dynamic>))
      .expand((data) => (data as List))
      .map((data) => Favorite.fromJSON(data));
}

Future<Favorite> addFavorite(Favorite favorite) async {
  User user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return Favorite();
  }
  final String apiToken = 'api_token=${user.apiToken}';
  favorite.userId = user.id;
  final String url = '${GlobalConfiguration().getString('api_base_url')}favorites?$apiToken';
  final client = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(favorite.toMap()),
  );
  return Favorite.fromJSON(json.decode(response.body)['data']);
}

Future<Favorite> removeFavorite(Favorite favorite) async {
  User user = userRepo.currentUser.value;
  if (user.apiToken == null) {
    return Favorite();
  }
  final String apiToken = 'api_token=${user.apiToken}';
  final String url = '${GlobalConfiguration().getString('api_base_url')}favorites/${favorite.id}?$apiToken';
  final client = http.Client();
  final response = await client.delete(
    Uri.parse(url),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  return Favorite.fromJSON(json.decode(response.body)['data']);
}

Future<Stream<Food>> getFoodsOfRestaurant(String restaurantId) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}foods?with=restaurant&search=restaurant.id:$restaurantId&searchFields=restaurant.id:=';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
    return Food.fromJson(data);
  });
}

Future<Stream<Food>> getTrendingFoodsOfRestaurant(String restaurantId) async {
  // TODO Trending foods only
  final String url = '${GlobalConfiguration().getString('api_base_url')}foods?with=restaurant&search=restaurant.id:$restaurantId&searchFields=restaurant.id:=';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
    return Food.fromJson(data);
  });
}

Future<Stream<Food>> getFeaturedFoodsOfRestaurant(String restaurantId) async {
  // TODO Featured foods only
  final String url = '${GlobalConfiguration().getValue<String>('api_base_url')}foods?with=restaurant&search=restaurant_id:$restaurantId&searchFields=restaurant_id:=';

  final client = http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
    return Food.fromJson(data);
  });
}
