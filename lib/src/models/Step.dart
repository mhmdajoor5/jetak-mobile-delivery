import 'package:google_maps_flutter/google_maps_flutter.dart';

class Step {
  final LatLng startLatLng;
  final LatLng endLatLng;

  Step({
    required this.startLatLng,
    required this.endLatLng,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      startLatLng: LatLng(
        json['start_location']?['lat'] ?? 0.0,
        json['start_location']?['lng'] ?? 0.0,
      ),
      endLatLng: LatLng(
        json['end_location']?['lat'] ?? 0.0,
        json['end_location']?['lng'] ?? 0.0,
      ),
    );
  }

  @override
  String toString() => 'Step(start: $startLatLng, end: $endLatLng)';
}
