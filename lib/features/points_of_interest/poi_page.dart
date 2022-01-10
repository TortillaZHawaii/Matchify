import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/location_source.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/data/points_of_interest/model/sports.dart';
import 'package:matchify/features/auth/auth_cubit.dart';
import 'package:matchify/features/points_of_interest/poi_details.dart';
import 'package:matchify/features/points_of_interest/poi_filters.dart';
import 'package:matchify/features/points_of_interest/poi_item_tile.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';

class PoiPage extends StatefulWidget {
  const PoiPage({Key? key}) : super(key: key);

  @override
  State<PoiPage> createState() => _PoiPageState();
}

class _PoiPageState extends State<PoiPage> {
  GoogleMapController? _controller;
  CameraPosition _cameraPosition = const CameraPosition(target: LatLng(0, 0));

  bool _isMapToBeDisplayed = false;
  PointOfInterest? _selectedPoi;
  PointOfInterest _oldSelectedPoi = PointOfInterest(
      id: '', name: 'Dummy', latLng: const LatLng(0, 0), sport: Sports.other);

  bool _needsRefreshing = true;
  var _pois = <PointOfInterest>[];

  var _mapMarkers = <Marker>{};

  final double _zoom = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matchify'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Matchify'),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                BlocProvider.of<AuthCubit>(context).signOut();
              },
            )
          ],
        ),
      ),
      body: _isMapToBeDisplayed
          ? Stack(
              children: [
                _getMapWidget(),
                _getUpperWidget(),
                _getLowerWidget(),
              ],
            )
          : _getListWidget(),
      // bottomSheet: PoiDetails(
      //   poi: _selectedPoi ?? _oldSelectedPoi,
      // ),
    );
  }

  Scaffold _getListWidget() {
    return Scaffold(
      body: ListView.separated(
        itemBuilder: (context, index) {
          final poi = _pois[index];
          return InkWell(
            onTap: () => setState(() {
              _isMapToBeDisplayed = true;
              _selectedPoi = poi;
              _setMapToLocation(poi.latLng);
            }),
            child: PoiItemTile(poi: poi),
          );
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: _pois.length,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMapView,
        label: const Text('View map'),
        icon: const Icon(Icons.map),
      ),
    );
  }

  Align _getLowerWidget() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FloatingActionButton(
                onPressed: () => _setMapToCurrentLocation(),
                child: const Icon(
                  Icons.my_location,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton.extended(
                onPressed: _goToListView,
                label: const Text('View list'),
                icon: const Icon(Icons.list),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _selectedPoi == null ? 0 : 180,
                child: _poiDetailsWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _getUpperWidget() {
    return Column(
      children: [
        PoiFilters(
          argument: PoiLocationArgument(latLng: _cameraPosition.target),
        ),
        if (_needsRefreshing)
          Align(
            alignment: Alignment.topCenter,
            child: InkWell(
              child: const Chip(
                label: Text('Refresh'),
              ),
              onTap: _updatePois,
            ),
          ),
      ],
    );
  }

  GoogleMap _getMapWidget() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _cameraPosition,
      compassEnabled: true,
      trafficEnabled: false,
      buildingsEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      markers: _mapMarkers,
      onTap: (_) {
        setState(() {
          _selectedPoi = null;
        });
      },
      onMapCreated: (controller) {
        if (_controller != controller && _controller != null) {
          _controller?.dispose();
        }
        _controller = controller;
      },
      onCameraMove: (position) => _cameraPosition = position,
    );
  }

  SingleChildScrollView _poiDetailsWidget() {
    // to avoid displaying nothing when _selectedPoi is null
    _oldSelectedPoi = _selectedPoi ?? _oldSelectedPoi;

    return SingleChildScrollView(
      child: PoiDetails(poi: _oldSelectedPoi),
    );
  }

  void _goToMapView() {
    setState(() {
      _isMapToBeDisplayed = true;
    });
  }

  void _goToListView() {
    setState(() {
      _controller?.dispose();
      _controller = null;
      _isMapToBeDisplayed = false;
    });
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

  void _updatePois() async {
    setState(() {
      _needsRefreshing = false;
      Future.delayed(const Duration(seconds: 15), () {
        setState(() {
          _needsRefreshing = true;
        });
      });
    });
    _pois = await getPois();
    _updateMarkersFromPois(_pois);
  }

  void _updateMarkersFromPois(Iterable<PointOfInterest> pois) {
    final newMarkers = <Marker>{};

    for (final poi in pois) {
      final generatedMarker =
          PoiMarker(poi: poi, poiFunction: _selectAndGoToPoi);
      newMarkers.add(generatedMarker);
    }

    setState(() {
      _mapMarkers = newMarkers;
    });
  }

  void _selectAndGoToPoi(PointOfInterest poi) async {
    setState(() {
      _selectedPoi = poi;
      _setMapToLocation(poi.latLng);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _controller = null;
  }

  Future<List<PointOfInterest>> getPois() async {
    final dataSource = PoiSourceFirebase();
    final argument = PoiLocationArgument(latLng: _cameraPosition.target);
    return await dataSource.getPointsOfInterest(argument);
  }
}

class PoiMarker extends Marker {
  PoiMarker(
      {required PointOfInterest poi,
      void Function(PointOfInterest)? poiFunction})
      : super(
          markerId: MarkerId(poi.latLng.toString()),
          position: poi.latLng,
          infoWindow: InfoWindow(title: poi.name),
          onTap: () => poiFunction?.call(poi),
        );
}
