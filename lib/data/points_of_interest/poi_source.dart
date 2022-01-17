import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/point_of_interest.dart';
import 'model/sports.dart';

abstract class PoiSource {
  Future<List<PointOfInterest>> getPointsOfInterest(
      PoiLocationArgument argument);

  Future<void> addPointOfInterest(PointOfInterest poi);

  Future<void> setBusyness(PointOfInterest poi, Busyness busyness);
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
    final sports = argument.sports.asNameMap().keys.toList();

    final docs = await _poisRef
        .where('sport', whereIn: sports.isNotEmpty ? sports : null)
        .get()
        .then((snapshot) => snapshot.docs);

    final list = <PointOfInterest>[];
    for (final doc in docs) {
      list.add(doc.data());
    }

    return list;
  }

  @override
  Future<void> addPointOfInterest(PointOfInterest poi) async {
    // toJson ignores the id
    _poisRef.add(poi);
  }

  @override
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

  factory PoiLocationArgument.copyWith(
      {required PoiLocationArgument arg,
      LatLng? latLng,
      String? searchText,
      Set<Sports>? sports,
      double? radius,
      PoiOrder? order,
      bool? isDescending}) {
    return arg.copyWith(
      latLng: latLng,
      searchText: searchText,
      sports: sports,
      radius: radius,
      order: order,
      isDescending: isDescending,
    );
  }

  PoiLocationArgument copyWith(
      {LatLng? latLng,
      String? searchText,
      Set<Sports>? sports,
      double? radius,
      PoiOrder? order,
      bool? isDescending}) {
    return PoiLocationArgument(
      latLng: latLng ?? this.latLng,
      searchText: searchText ?? this.searchText,
      sports: sports ?? this.sports,
      radius: radius ?? this.radius,
      order: order ?? this.order,
      isDescending: isDescending ?? this.isDescending,
    );
  }
}

enum PoiOrder {
  /// Order by distance from the centre.
  distance,

  /// Order by name.
  name,
}
