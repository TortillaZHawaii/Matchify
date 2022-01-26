import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationSource {
  Future<LatLng> getCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      final output = LatLng(position.latitude, position.longitude);

      return output;
    } catch (e) {
      rethrow;
    }
  }

  Future<LocationPermission> requestPermission() async {
    return Geolocator.requestPermission();
  }

  Future<LatLng> getCurrentPositionWithHandling(BuildContext context) async {
    try {
      final position = await getCurrentPosition();
      return position;
    } on PermissionDeniedException {
      final permissions = await requestPermission();

      if (permissions == LocationPermission.denied ||
          permissions == LocationPermission.deniedForever) {
      } else {
        return await getCurrentPosition();
      }
    } on TimeoutException {
      return const LatLng(54.107941, 22.929369);
    }

    return const LatLng(54.107941, 22.929369);
  }
}
