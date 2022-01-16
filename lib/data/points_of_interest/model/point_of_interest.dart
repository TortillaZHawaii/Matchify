import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/model/sports.dart';

enum Busyness {
  free,
  moderate,
  busy,
}

class PointOfInterest {
  final String id;
  final String name;
  final LatLng latLng;
  final Sports sport;
  final String? address;
  Busyness? busyiness;

  PointOfInterest(
      {required this.id,
      required this.name,
      required this.latLng,
      required this.sport,
      this.busyiness,
      this.address});

  PointOfInterest.fromJson(String id, Map<String, Object?> json)
      : this(
          id: id,
          name: json['name']! as String,
          latLng: _getLatLngFromGeoPoint(json['latLng']! as GeoPoint),
          sport: SportsFactory.getSports(json['sport']! as String),
          busyiness: _getBusyness(
              json['busyness'] != null ? json['busyness']! as String : null),
          address: json['address'] as String?,
        );

  static Busyness? _getBusyness(String? s) {
    switch (s) {
      case 'free':
        return Busyness.free;
      case 'moderate':
        return Busyness.moderate;
      case 'busy':
        return Busyness.busy;
      default:
        return null;
    }
  }

  static LatLng _getLatLngFromGeoPoint(GeoPoint point) {
    return LatLng(point.latitude, point.longitude);
  }

  Map<String, Object?> toJson() {
    return {
      'latLng': GeoPoint(latLng.latitude, latLng.longitude),
      'sport': sport.name,
      'name': name,
      if (address != null) 'address': address,
    };
  }
}
