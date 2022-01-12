import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/location_source.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/features/auth/auth_cubit.dart';
import 'package:matchify/features/points_of_interest/poi_cubit.dart';
import 'package:matchify/features/points_of_interest/poi_details.dart';
import 'package:matchify/features/points_of_interest/poi_filters.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';

class PoiMap extends StatefulWidget {
  final PointOfInterest? selectedPoi;
  final List<PointOfInterest> pois;
  final Function()? swap;

  const PoiMap({Key? key, this.selectedPoi, required this.pois, this.swap})
      : super(key: key);

  @override
  State<PoiMap> createState() => _PoiMapState();
}

class _PoiMapState extends State<PoiMap> {
  GoogleMapController? _controller;
  CameraPosition _cameraPosition = const CameraPosition(target: LatLng(0, 0));

  final double _zoom = 15;

  @override
  Widget build(BuildContext context) {
    if (widget.selectedPoi != null) {
      _setMapToPoi(widget.selectedPoi!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matchify'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                BlocProvider.of<AuthCubit>(context).signOut();
              },
            )
          ],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _cameraPosition,
            compassEnabled: true,
            trafficEnabled: false,
            buildingsEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: _generateMarkersFromPois(widget.pois),
            onTap: (_) => _unselectPoi(),
            onMapCreated: (controller) {
              if (_controller != controller) {
                _controller?.dispose();
              }
              _controller = controller;
            },
            onCameraMove: (position) => _cameraPosition = position,
          ),
          Column(
            children: [
              Hero(
                tag: 'poi-filters',
                child: PoiFilters(
                  argument: PoiLocationArgument(latLng: _cameraPosition.target),
                ),
              ),
              // if (_needsRefreshing)
              //   Align(
              //     alignment: Alignment.topCenter,
              //     child: InkWell(
              //       child: const Chip(
              //         label: Text('Refresh'),
              //       ),
              //       onTap: _updatePois,
              //     ),
              //   ),
            ],
          ),
        ],
      ),
      floatingActionButton: widget.selectedPoi != null
          ? FloatingActionButton(
              onPressed: _goToListView,
              child: const Icon(Icons.list),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: FloatingActionButton(
                    onPressed: () => _setMapToCurrentLocation(),
                    child: Icon(
                      Icons.my_location,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
                FloatingActionButton.extended(
                  onPressed: _goToListView,
                  label: const Text('View list'),
                  icon: const Icon(Icons.list),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomSheet: widget.selectedPoi != null
          ? Hero(
              tag: widget.selectedPoi!.id,
              child: PoiDetails(poi: widget.selectedPoi!),
            )
          : null,
    );
  }

  void _unselectPoi() {
    BlocProvider.of<PoiCubit>(context).unselectPoi();
  }

  void _goToListView() {
    _unselectPoi();
    widget.swap?.call();
  }

  void _setMapToPoi(PointOfInterest poi) {
    _setMapToLocation(poi.latLng);
    _controller?.showMarkerInfoWindow(MarkerId(poi.id));
  }

  void _setMapToLocation(LatLng location) {
    setState(() {
      _cameraPosition = CameraPosition(
        target: location,
        zoom: _zoom,
      );
    });
    _controller?.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  void _setMapToCurrentLocation() async {
    final locationSource = LocationSource();
    try {
      final newPosition = await locationSource.getCurrentPosition();
      _setMapToLocation(newPosition);
    } on PermissionDeniedException {
      final permissions = await locationSource.requestPermission();

      if (permissions == LocationPermission.denied ||
          permissions == LocationPermission.deniedForever) {
        showDialog(
          context: context,
          builder: (context) => const AlertDialog(
            title: Text('Location services disabled'),
            content: Text('Please enable location services in settings'),
          ),
        );
      }
    }
  }

  Set<Marker> _generateMarkersFromPois(Iterable<PointOfInterest> pois) {
    final newMarkers = <Marker>{};

    for (final poi in pois) {
      final generatedMarker =
          PoiMarker(poi: poi, poiFunction: _selectAndGoToPoi);
      newMarkers.add(generatedMarker);
    }

    return newMarkers;
  }

  void _selectAndGoToPoi(PointOfInterest poi) async {
    BlocProvider.of<PoiCubit>(context).selectPoi(poi);
    _setMapToPoi(poi);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }
}

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
