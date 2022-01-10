import 'package:flutter/material.dart';
import 'package:matchify/data/points_of_interest/maps_launcher.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/features/points_of_interest/poi_item_tile.dart';

class PoiDetails extends StatelessWidget {
  final PointOfInterest poi;

  const PoiDetails({Key? key, required this.poi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
      child: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              PoiItemTile(
                poi: poi,
              ),
              PoiBusyness(
                poi: poi,
                key: Key(poi.latLng.toString()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _launchGoogleMapsForPoi(poi),
                    icon: const Icon(Icons.directions),
                    label: const Text('Directions'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _launchGoogleMapsForPoi(PointOfInterest poi) async {
    MapsLauncher.launchGoogleMaps(poi.latLng.latitude, poi.latLng.longitude);
  }
}

class PoiBusyness extends StatefulWidget {
  final PointOfInterest poi;

  const PoiBusyness({Key? key, required this.poi}) : super(key: key);

  @override
  State<PoiBusyness> createState() => _PoiBusynessState();
}

class _PoiBusynessState extends State<PoiBusyness> {
  bool _isAlreadySelected = false;

  @override
  Widget build(BuildContext context) {
    if (_isAlreadySelected) {
      return const Text('Thank you for your feedback!');
    } else {
      return Column(
        children: [
          const Text('How busy is it now?'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _selectBusyness(Busyness.free),
                child: const Text('Empty'),
              ),
              TextButton(
                onPressed: () => _selectBusyness(Busyness.moderate),
                child: const Text('Moderate'),
              ),
              TextButton(
                onPressed: () => _selectBusyness(Busyness.busy),
                child: const Text('Busy'),
              ),
            ],
          ),
        ],
      );
    }
  }

  void _selectBusyness(Busyness busyness) {
    setState(() {
      _isAlreadySelected = true;
    });
  }
}
