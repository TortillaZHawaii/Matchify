import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/point_of_interest.dart';
import 'model/sports.dart';

abstract class PoiSource {
  Future<List<PointOfInterest>> getPointsOfInterest(
      PoiLocationArgument argument);
}

class PoiSourceFirebase extends PoiSource {
  final _poisRef = FirebaseFirestore.instance
      .collection('locations')
      .withConverter<PointOfInterest>(
          fromFirestore: (snapshot, _) =>
              PointOfInterest.fromJson(snapshot.id, snapshot.data()!),
          toFirestore: (poi, _) => poi.toJson());

  PoiSourceFirebase();

  @override
  Future<List<PointOfInterest>> getPointsOfInterest(
      PoiLocationArgument argument) async {
    final docs = await _poisRef.get().then((snapshot) => snapshot.docs);

    final list = <PointOfInterest>[];
    for (final doc in docs) {
      list.add(doc.data());
    }

    return list;
  }

  Future<void> addPointOfInterest(PointOfInterest poi) async {
    _poisRef.add(poi);
  }

  Future<void> setBusyness(PointOfInterest poi, Busyness busyness) async {
    _poisRef.doc(poi.id).update({'busyness': busyness.name});
  }
}

class PoiLocationArgument {
  /// Set of sports used to filter the results.
  /// If empty, all sports are used.
  final Set<Sports> sports;

  /// Centre of scanning area.
  final LatLng latLng;

  /// Radius of scanning area in degrees.
  final double radius;

  /// Search text used to filter the results.
  /// If null all results are returned.
  final String? searchText;

  /// Sorting order of the results.
  final PoiOrder order; // = PoiOrder.distance;

  /// Order of sorting.
  final bool isDescending; // = true;

  PoiLocationArgument(
      {required this.latLng,
      this.searchText,
      Set<Sports>? sports,
      double? radius,
      PoiOrder? order,
      bool? isDescending})
      : sports = sports ?? {},
        radius = radius ?? 0.4,
        order = order ?? PoiOrder.distance,
        isDescending = isDescending ?? true;
}

enum PoiOrder {
  /// Order by distance from the centre.
  distance,

  /// Order by name.
  name,
}
