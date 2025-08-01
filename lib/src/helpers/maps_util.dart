import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/step.dart';

class MapsUtil {
  static final MapsUtil _instance = MapsUtil._internal();
  final JsonDecoder _decoder = const JsonDecoder();
  
  // API Configuration
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  final String _apiKey;
  
  factory MapsUtil() => _instance;
  
  MapsUtil._internal() : _apiKey = 'AIzaSyC6GK6c5IMopZIMo_F1btLZgYY4HTIuPLg';

  

  /// Fetches route directions between two points
  /// 
  /// [origin] The starting point latitude and longitude as LatLng
  /// [destination] The destination point latitude and longitude as LatLng
  /// [waypoints] Optional list of waypoints to include in the route
  /// [travelMode] The travel mode (driving, walking, bicycling, transit)
  /// [avoid] Features to avoid (tolls, highways, ferries, indoor)
  Future<List<LatLng>> getDirections({
    required LatLng origin,
    required LatLng destination,
    List<LatLng> waypoints = const [],
    String travelMode = 'driving',
    List<String>? avoid,
  }) async {
    print('🗺️ MapsUtil.getDirections called');
    print('   - Origin: (${origin.latitude}, ${origin.longitude})');
    print('   - Destination: (${destination.latitude}, ${destination.longitude})');
    try {
      // Build the request URL
      final params = <String, dynamic>{
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': travelMode,
        'key': _apiKey,
      };

      // Add waypoints if provided
      if (waypoints.isNotEmpty) {
        final waypointsStr = waypoints
            .map((point) => '${point.latitude},${point.longitude}')
            .join('|');
        params.addAll({
          'waypoints': 'optimize:true|$waypointsStr',
        });
      }

      // Add avoid parameters if provided
      if (avoid != null && avoid.isNotEmpty) {
        params['avoid'] = avoid.join('|');
      }

      // Create and validate the URI
      final uri = Uri.parse(_baseUrl).replace(queryParameters: params);
      
      if (kDebugMode) {
        developer.log('MapsUtil - Requesting directions: ${uri.toString().replaceAll(_apiKey!, '***')}');
      }

      // Make the HTTP request
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timed out'),
      );

      // Handle the response
      return _handleDirectionsResponse(response);
    } on TimeoutException catch (e) {
      throw Exception('Request timed out: $e');
    } on FormatException catch (e) {
      throw Exception('Invalid response format: $e');
    } on Exception catch (e) {
      throw Exception('Failed to get directions: $e');
    }
  }

  /// Handles the directions API response
  Future<List<LatLng>> _handleDirectionsResponse(http.Response response) async {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    if (statusCode != 200) {
      throw Exception(
        'Failed to load directions. Status code: $statusCode',
      );
    }

    try {
      final decoded = _decoder.convert(responseBody);
      
      print('🌍 Directions API response status: ${decoded['status']}');
      if (kDebugMode) {
        developer.log('MapsUtil - Directions API response: ${decoded.toString()}');
      }
      
      if (decoded['status'] != 'OK') {
        print('❌ Directions API error: ${decoded['error_message'] ?? 'No error message'}');
        return [];
      }

      // Check for API errors
      final status = decoded['status'] as String;
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        throw Exception('Directions API error: ${decoded['error_message'] ?? status}');
      }

      // Parse the route
      final routes = decoded['routes'] as List;
      if (routes.isEmpty) {
        return [];
      }

      final legs = routes[0]['legs'] as List;
      if (legs.isEmpty) {
        return [];
      }

      final steps = legs[0]['steps'] as List;
      return _parseSteps(steps);
    } catch (e) {
      throw Exception('Failed to parse directions: $e');
    }
  }

  /// Parses the steps from the directions response
  List<LatLng> _parseSteps(List<dynamic> stepsData) {
    try {
      final steps = stepsData.map<Step>((json) => Step.fromJson(json)).toList();
      final points = <LatLng>[];
      
      // Add the start point of each step
      for (final step in steps) {
        points.add(step.startLatLng);
      }
      
      // Add the end point of the last step
      if (steps.isNotEmpty) {
        points.add(steps.last.startLatLng);
      }
      
      return points;
    } catch (e) {
      throw Exception('Failed to parse steps: $e');
    }
  }
}
