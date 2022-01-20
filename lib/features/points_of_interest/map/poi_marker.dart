import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';

class PoiMarker extends Marker {
  PoiMarker(
      {required PointOfInterest poi,
      void Function(PointOfInterest)? poiFunction})
      : super(
          markerId: MarkerId(poi.id),
          position: poi.latLng,
          infoWindow: InfoWindow(
            title: poi.name,
          ),
          onTap: () => poiFunction?.call(poi),
        );
}
