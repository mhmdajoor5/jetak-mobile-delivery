import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/filter.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../repository/user_repository.dart';

Future<Stream<Restaurant>> getNearRestaurants(Address myLocation, Address areaLocation) async {
  Uri uri = Helper.getUri('api/restaurants');
  Map<String, dynamic> queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  queryParams['limit'] = '6';
  if (!myLocation.isUnknown() && !areaLocation.isUnknown()) {
    queryParams['myLon'] = myLocation.longitude.toString();
    queryParams['myLat'] = myLocation.latitude.toString();
    queryParams['areaLon'] = areaLocation.longitude.toString();
    queryParams['areaLat'] = areaLocation.latitude.toString();
  }
  queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: queryParams);
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
      return Restaurant.fromJson(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return Stream.value(Restaurant.fromJson({}));
  }
}

Future<Stream<Restaurant>> getPopularRestaurants(Address myLocation) async {
  Uri uri = Helper.getUri('api/restaurants');
  Map<String, dynamic> queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  queryParams['limit'] = '6';
  queryParams['popular'] = 'all';
  if (!myLocation.isUnknown()) {
    queryParams['myLon'] = myLocation.longitude.toString();
    queryParams['myLat'] = myLocation.latitude.toString();
  }
  queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: queryParams);
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
      return Restaurant.fromJson(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return Stream.value(Restaurant.fromJson({}));
  }
}

Future<Stream<Restaurant>> searchRestaurants(String search, Address address) async {
  Uri uri = Helper.getUri('api/restaurants');
  Map<String, dynamic> queryParams = {};
  queryParams['search'] = 'name:$search;description:$search';
  queryParams['searchFields'] = 'name:like;description:like';
  queryParams['limit'] = '5';
  if (!address.isUnknown()) {
    queryParams['myLon'] = address.longitude.toString();
    queryParams['myLat'] = address.latitude.toString();
    queryParams['areaLon'] = address.longitude.toString();
    queryParams['areaLat'] = address.latitude.toString();
  }
  uri = uri.replace(queryParameters: queryParams);
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
      return Restaurant.fromJson(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return Stream.value(Restaurant.fromJson({}));
  }
}

Future<Stream<Restaurant>> getRestaurant(String id, Address address) async {
  Uri uri = Helper.getUri('api/restaurants/$id');
  Map<String, dynamic> queryParams = {};
  if (!address.isUnknown()) {
    queryParams['myLon'] = address.longitude.toString();
    queryParams['myLat'] = address.latitude.toString();
    queryParams['areaLon'] = address.longitude.toString();
    queryParams['areaLat'] = address.latitude.toString();
  }
  uri = uri.replace(queryParameters: queryParams);
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).map((data) => Restaurant.fromJson(data));
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return Stream.value(Restaurant.fromJson({}));
  }
}

Future<Stream<Review>> getRestaurantReviews(String id) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}restaurant_reviews?with=user&search=restaurant_id:$id';
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
      return Review.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Stream.value(Review.fromJSON({}));
  }
}

Future<Stream<Review>> getRecentReviews() async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}restaurant_reviews?orderBy=updated_at&sortedBy=desc&limit=3&with=user';
  try {
    final client = http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data as Map<String,dynamic>)).expand((data) => (data as List)).map((data) {
      return Review.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Stream.value(Review.fromJSON({}));
  }
}

Future<Review> addRestaurantReview(Review review, Restaurant restaurant) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}restaurant_reviews';
  final client = http.Client();
  review.user = currentUser.value;
  try {
    final response = await client.post(
      Uri.parse(url),
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(review.ofRestaurantToMap(restaurant)),
    );
    if (response.statusCode == 200) {
      return Review.fromJSON(json.decode(response.body)['data']);
    } else {
      print(CustomTrace(StackTrace.current, message: response.body).toString());
      return Review.fromJSON({});
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Review.fromJSON({});
  }
}
