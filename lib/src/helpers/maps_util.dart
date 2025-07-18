import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/Step.dart';

class MapsUtil {
  static const BASE_URL = "https://maps.googleapis.com/maps/api/directions/json?";

  static MapsUtil _instance = new MapsUtil.internal();

  MapsUtil.internal();

  factory MapsUtil() => _instance;
  final JsonDecoder _decoder = new JsonDecoder();
  Future<List<LatLng>> get(String url) async {
    final response = await http.get(Uri.parse(BASE_URL + url));
    final String res = response.body;
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400) {
      final error = {
        "status": statusCode,
        "message": "error",
        "response": res
      };
      throw Exception(jsonEncode(error));
    }

    try {
      final decoded = _decoder.convert(res);
      final stepsData = decoded["routes"][0]["legs"][0]["steps"];
      final steps = parseSteps(stepsData);
      return steps;
    } catch (e) {
      throw Exception("Failed to parse steps: $e");
    }
  }

//   Future<dynamic> get(String url) {
//     return http.get(Uri.parse(BASE_URL + url)).then((http.Response response) {
//       String res = response.body;
//       int statusCode = response.statusCode;
// //      print("API Response: " + res);
//       if (statusCode < 200 || statusCode > 400 || json == null) {
//         res = "{\"status\":" + statusCode.toString() + ",\"message\":\"error\",\"response\":" + res + "}";
//         throw new Exception(res);
//       }
//
//       List<LatLng> steps;
//       try {
//         steps = parseSteps(_decoder.convert(res)["routes"][0]["legs"][0]["steps"]);
//       } catch (e) {
//         // throw new Exception(e);
//       }
//
//       return steps;
//     });
//   }

  List<LatLng> parseSteps(final responseBody) {
    List<Step> _steps = responseBody.map<Step>((json) {
      return new Step.fromJson(json);
    }).toList();
    List<LatLng> _latLang = _steps.map((Step step) => step.startLatLng).toList();
    return _latLang;
  }
}
