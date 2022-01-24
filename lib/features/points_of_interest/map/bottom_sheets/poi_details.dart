import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matchify/data/points_of_interest/maps_launcher.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/features/points_of_interest/poi_cubit.dart';
import 'package:matchify/features/points_of_interest/list/poi_item_tile.dart';
import 'package:share_plus/share_plus.dart';

class PoiDetails extends StatelessWidget {
  final PointOfInterest poi;

  const PoiDetails({Key? key, required this.poi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Card(
          child: Column(
            children: [
              PoiItemTile(
                poi: poi,
              ),
              const Divider(
                indent: 16,
                endIndent: 16,
              ),
              PoiBusyness(
                poi: poi,
                key: Key(poi.latLng.toString()),
              ),
              const Divider(
                indent: 16,
                endIndent: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _launchGoogleMapsForPoi(poi),
                      icon: const Icon(Icons.directions),
                      label: const Text('Directions'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton(
                      onPressed: () => _sharePoi(poi),
                      child: const Text('SHARE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sharePoi(PointOfInterest poi) async {
    var url = 'http://matchify.com/map/${poi.id}';
    var text = 'Join me on ${poi.name} at $url';
    Share.share(text);
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
                onPressed: () => _selectBusyness(Busyness.free, context),
                child: const Text('Empty'),
              ),
              TextButton(
                onPressed: () => _selectBusyness(Busyness.moderate, context),
                child: const Text('Moderate'),
              ),
              TextButton(
                onPressed: () => _selectBusyness(Busyness.busy, context),
                child: const Text('Busy'),
              ),
            ],
          ),
        ],
      );
    }
  }

  void _selectBusyness(Busyness busyness, BuildContext context) {
    final poiCubit = BlocProvider.of<PoiCubit>(context);

    setState(() {
      _isAlreadySelected = true;
      poiCubit.setBusyness(widget.poi, busyness);
    });
  }
}
