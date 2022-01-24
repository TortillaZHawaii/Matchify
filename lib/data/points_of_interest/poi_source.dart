import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'model/point_of_interest.dart';
import 'model/sports.dart';

abstract class PoiSource {
  Future<List<PointOfInterest>> getPointsOfInterest(
      PoiLocationArgument argument);

  Future<PointOfInterest?> getPointOfInterest(String id);

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
      PoiLocationArgument argument,
      {LatLng? currentLocation}) async {
    //
    // Firebase rant:
    //
    // There can only be one whereIn in the query which blocks the ability to
    // filter by sport and busyness at the same time.
    // https://stackoverflow.com/questions/62968079/can-you-use-the-wherein-condition-twice-in-a-compound-query
    //
    // GeoPoint is a wrapper around a latitude and longitude only.
    // There aren't any operators for GeoPoint, like sorting by distance or
    // querying points within a radius.
    // https://stackoverflow.com/questions/47365000/sort-array-by-distance-near-user-location-from-firebase
    //
    // I leave the capabilites in UI, although they don't work with Firebase.
    // This could be done with MongoDB. But since this subject is oriented
    // around mobile, I don't want to implement it now.
    //

    // on the server

    final sports = argument.sports.asNameMap().keys.toList();
    //final busyness = argument.busyness.asNameMap().keys.toList();

    var query =
        _poisRef.where('sport', whereIn: sports.isNotEmpty ? sports : null);
    //.where('busyness', whereIn: busyness);

    if (argument.order == PoiOrder.name) {
      query = query.orderBy('name', descending: argument.isDescending);
    }

    final docs = await query.get().then((snapshot) => snapshot.docs);

    final list = <PointOfInterest>[];
    for (final doc in docs) {
      list.add(doc.data());
    }

    // on the client,

    if (argument.order == PoiOrder.distance && currentLocation != null) {
      list.sort((PointOfInterest a, PointOfInterest b) {
        final distanceA = cartesianDistanceSqrd(currentLocation, a.latLng);
        final distanceB = cartesianDistanceSqrd(currentLocation, b.latLng);

        if (argument.isDescending) {
          return distanceA.compareTo(distanceB);
        } else {
          return distanceB.compareTo(distanceA);
        }
      });
    }

    list.removeWhere(
        (element) => !argument.busyness.contains(element.busyiness));

    return list;
  }

  static double cartesianDistanceSqrd(LatLng a, LatLng b) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;
    return dx * dx + dy * dy;
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

  @override
  Future<PointOfInterest?> getPointOfInterest(String id) {
    return _poisRef.doc(id).get().then((snapshot) => snapshot.data());
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

  final Set<Busyness> busyness;

  PoiLocationArgument({
    required this.latLng,
    this.searchText,
    Set<Sports>? sports,
    double? radius,
    PoiOrder? order,
    bool? isDescending,
    Set<Busyness>? busyness,
  })  : sports = sports ?? {},
        busyness = busyness ?? Busyness.values.toSet(),
        radius = radius ?? 0.4,
        order = order ?? PoiOrder.distance,
        isDescending = isDescending ?? true;

  factory PoiLocationArgument.copyWith(
      {required PoiLocationArgument arg,
      Set<Busyness>? busyness,
      LatLng? latLng,
      String? searchText,
      Set<Sports>? sports,
      double? radius,
      PoiOrder? order,
      bool? isDescending}) {
    return arg.copyWith(
      busyness: busyness,
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
      Set<Busyness>? busyness,
      double? radius,
      PoiOrder? order,
      bool? isDescending}) {
    return PoiLocationArgument(
      latLng: latLng ?? this.latLng,
      searchText: searchText ?? this.searchText,
      sports: sports ?? this.sports,
      busyness: busyness ?? this.busyness,
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
