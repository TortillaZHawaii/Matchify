import 'package:flutter/material.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/features/points_of_interest/poi_item_tile.dart';

class PoiList extends StatelessWidget {
  final List<PointOfInterest> pois;

  const PoiList({Key? key, required this.pois}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemBuilder: (context, index) {
          final poi = pois[index];
          return PoiItemTile(
            onTap: () => _selectPoi(poi),
            poi: poi,
          );
        },
        separatorBuilder: (context, index) => const Divider(),
        itemCount: pois.length,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMapView,
        label: const Text('View map'),
        icon: const Icon(Icons.map),
      ),
    );
  }

  void _goToMapView() {}
  void _selectPoi(PointOfInterest poi) {}
}
