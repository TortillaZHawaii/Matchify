import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/location_source.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/features/points_of_interest/map/poi_marker.dart';
import 'package:matchify/features/points_of_interest/common/poi_app_bar.dart';
import 'package:matchify/features/points_of_interest/map/bottom_sheets/poi_create_card.dart';
import 'package:matchify/features/points_of_interest/poi_cubit.dart';
import 'package:matchify/features/points_of_interest/map/bottom_sheets/poi_details.dart';
import 'package:matchify/features/points_of_interest/common/poi_filters.dart';

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

  bool _isSatelliteView = false;
  LatLng? _creatingPoiPosition;

  final double _zoom = 15;

  @override
  Widget build(BuildContext context) {
    if (widget.selectedPoi != null) {
      _setMapToPoi(widget.selectedPoi!);
    }

    final poiCubit = BlocProvider.of<PoiCubit>(context);

    return Scaffold(
      appBar: PoiAppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () => setState(() {
              _isSatelliteView = !_isSatelliteView;
            }),
          )
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: _isSatelliteView ? MapType.hybrid : MapType.normal,
            initialCameraPosition: _cameraPosition,
            compassEnabled: true,
            trafficEnabled: false,
            buildingsEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            markers: _generateMarkersFromPois(widget.pois),
            onTap: (_) => _unselectPoiAndCreated(),
            onLongPress: (latLng) => _createPoi(latLng),
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
              PoiFilters(
                argument: (poiCubit.state as PoiStateWithArgument).argument,
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
      floatingActionButton:
          widget.selectedPoi != null || _creatingPoiPosition != null
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
                          Icons.location_searching,
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
      bottomSheet: _creatingPoiPosition != null
          ? PoiCreateCard(
              position: _creatingPoiPosition!,
              onCancel: () {
                setState(() {
                  _creatingPoiPosition = null;
                });
              },
            )
          : (widget.selectedPoi != null
              ? Hero(
                  tag: widget.selectedPoi!.id,
                  child: PoiDetails(poi: widget.selectedPoi!),
                )
              : null),
    );
  }

  void _createPoi(LatLng position) {
    setState(() {
      _creatingPoiPosition = position;
      BlocProvider.of<PoiCubit>(context).unselectPoi();
    });
    _setMapToLocationWithoutZoom(position);
  }

  void _unselectPoiAndCreated() {
    setState(() {
      _creatingPoiPosition = null;
    });
    BlocProvider.of<PoiCubit>(context).unselectPoi();
  }

  void _goToListView() {
    _unselectPoiAndCreated();
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

  void _setMapToLocationWithoutZoom(LatLng location) {
    setState(() {
      _cameraPosition = CameraPosition(
        target: location,
        zoom: _cameraPosition.zoom,
        bearing: _cameraPosition.bearing,
        tilt: _cameraPosition.tilt,
      );
    });
    _controller?.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
  }

  void _setMapToCurrentLocation() async {
    final locationSource = LocationSource();
    try {
      // start animation
      final newPosition = await locationSource.getCurrentPosition();
      // stop animation
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

    if (_creatingPoiPosition != null) {
      final newMarker = Marker(
        markerId: const MarkerId('newPoi'),
        position: _creatingPoiPosition!,
        draggable: true,
        onDragEnd: (position) => setState(() {
          _creatingPoiPosition = position;
        }),
      );
      newMarkers.add(newMarker);
    }

    return newMarkers;
  }

  void _selectAndGoToPoi(PointOfInterest poi) async {
    BlocProvider.of<PoiCubit>(context).selectPoi(poi);
    setState(() {
      _creatingPoiPosition = null;
      _setMapToPoi(poi);
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }
}
