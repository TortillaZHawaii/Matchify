import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';
import 'package:matchify/features/points_of_interest/poi_cubit.dart';
import 'package:matchify/features/points_of_interest/poi_filters.dart';
import 'package:matchify/features/points_of_interest/poi_item_tile.dart';

import 'poi_filter_page.dart';

class PoiList extends StatelessWidget {
  final List<PointOfInterest> pois;
  final Function()? swap;

  const PoiList({Key? key, required this.pois, this.swap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
        //  Scaffold(
        //     body: SafeArea(
        //         child: PoiFilter(
        //             argument: PoiLocationArgument(latLng: LatLng(0, 0)))));
        Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PoiFilters(
                argument: PoiLocationArgument(latLng: const LatLng(0, 0))),
            Expanded(
              flex: 1,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final poi = pois[index];
                  return Hero(
                    tag: poi.id,
                    child: PoiItemTile(
                      onTap: () => _selectPoi(poi, context),
                      poi: poi,
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: pois.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goToMapView(context),
        label: const Text('View map'),
        icon: const Icon(Icons.map),
      ),
    );
  }

  void _goToMapView(BuildContext context) {
    swap?.call();
  }

  void _selectPoi(PointOfInterest poi, BuildContext context) {
    BlocProvider.of<PoiCubit>(context).selectPoi(poi);
  }
}
