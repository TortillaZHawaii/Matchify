import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';
import 'package:matchify/features/points_of_interest/poi_cubit.dart';
import 'package:matchify/features/points_of_interest/list/poi_list.dart';
import 'package:matchify/features/points_of_interest/map/poi_map.dart';

class PoiEntry extends StatefulWidget {
  const PoiEntry({Key? key}) : super(key: key);

  @override
  State<PoiEntry> createState() => _PoiEntryState();
}

class _PoiEntryState extends State<PoiEntry> {
  bool _isListView = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PoiCubit(
        dataSource: PoiSourceFirebase(),
      ),
      child: BlocBuilder<PoiCubit, PoiState>(
        builder: (context, state) {
          if (state is InitialState) {
            BlocProvider.of<PoiCubit>(context).firstLoad();
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final selectedPoi = state is SelectedPoiState ? state.selected : null;
          final pois = state.pois;
          if (selectedPoi != null) {
            _isListView = false;
          }

          final initialLocation = state is PoiStateWithArgument
              ? state.argument.latLng
              : const LatLng(0, 0);

          return Navigator(
            pages: [
              MaterialPage(
                child: PoiMap(
                  initialLocation: initialLocation,
                  pois: pois,
                  selectedPoi: selectedPoi,
                  swap: _swapView,
                ),
                key: const ValueKey('map'),
              ),
              if (_isListView && selectedPoi == null)
                MaterialPage(
                  child: PoiList(
                    pois: pois,
                    swap: _swapView,
                  ),
                  key: const ValueKey('list'),
                ),
            ],
            onPopPage: (route, result) {
              if (!route.didPop(result)) {
                return false;
              }
              return true;
            },
          );
        },
      ),
    );
  }

  void _swapView() {
    setState(() {
      _isListView = !_isListView;
    });
  }
}
