import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationSource {
  Future<LatLng> getCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);

      final output = LatLng(position.latitude, position.longitude);

      return output;
    } catch (e) {
      rethrow;
    }
  }

  Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }
}
