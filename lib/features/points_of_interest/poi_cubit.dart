import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';

class PoiCubit extends Cubit<PoiState> {
  PoiCubit({required PoiSource dataSource})
      : _dataSource = dataSource,
        super(const InitialState());

  final PoiSource _dataSource;

  Future<void> firstLoad(Future<LatLng> firstPosition) async {
    final pos = await firstPosition;
    reloadPois(PoiLocationArgument(latLng: pos));
  }

  Future<void> reloadAll() async {
    if (state is! PoiStateWithArgument) {
      return;
    }

    final arg = (state as PoiStateWithArgument).argument;

    await reloadPois(arg);
  }

  Future<void> reloadPois(PoiLocationArgument argument) async {
    emit(LoadingState(oldPois: state.pois, argument: argument));
    final newPois = await _dataSource.getPointsOfInterest(argument);
    emit(FreshDataState(pois: newPois, argument: argument));
  }

  Future<void> changeArgumentAndReload(PoiLocationArgument argument) async {
    emit(ChangedArgumentState(pois: state.pois, argument: argument));
    reloadPois(argument);
  }

  Future<void> changeLatLng(LatLng newPosition) async {
    if (state is PoiStateWithArgument) {
      final arg = (state as PoiStateWithArgument).argument;
      emit(ChangedArgumentState(
        pois: state.pois,
        argument: arg.copyWith(latLng: newPosition),
      ));
    }
  }

  Future<void> addPoi(PointOfInterest poi) async {
    await _dataSource.addPointOfInterest(poi);
  }

  Future<void> setBusyness(PointOfInterest poi, Busyness busyness) async {
    await _dataSource.setBusyness(poi, busyness);
  }
}

abstract class PoiState {
  final List<PointOfInterest> pois;

  const PoiState({required this.pois});
}

class InitialState extends PoiState {
  const InitialState() : super(pois: const <PointOfInterest>[]);
}

abstract class PoiStateWithArgument extends PoiState {
  final PoiLocationArgument argument;
  const PoiStateWithArgument(
      {required List<PointOfInterest> pois, required this.argument})
      : super(pois: pois);
}

// we are showing oldPois to not to break the experience
class LoadingState extends PoiStateWithArgument {
  const LoadingState(
      {required List<PointOfInterest> oldPois,
      required PoiLocationArgument argument})
      : super(pois: oldPois, argument: argument);
}

class FreshDataState extends PoiStateWithArgument {
  const FreshDataState(
      {required List<PointOfInterest> pois,
      required PoiLocationArgument argument})
      : super(pois: pois, argument: argument);
}

class ChangedArgumentState extends PoiStateWithArgument {
  const ChangedArgumentState(
      {required List<PointOfInterest> pois,
      required PoiLocationArgument argument})
      : super(pois: pois, argument: argument);
}

class UnselectedPoiState extends PoiStateWithArgument {
  const UnselectedPoiState(
      {required List<PointOfInterest> pois,
      required PoiLocationArgument argument})
      : super(pois: pois, argument: argument);
}

class SelectedPoiState extends PoiStateWithArgument {
  const SelectedPoiState(
      {required this.selected,
      required List<PointOfInterest> pois,
      required PoiLocationArgument argument})
      : super(pois: pois, argument: argument);

  final PointOfInterest selected;
}
