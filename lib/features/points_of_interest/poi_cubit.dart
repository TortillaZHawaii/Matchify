import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';

class PoiCubit extends Cubit<PoiState> {
  PoiCubit({required PoiSource dataSource})
      : _dataSource = dataSource,
        super(const LoadingState(oldPois: <PointOfInterest>[]));

  final PoiSource _dataSource;

  Future<void> reloadPois(PoiLocationArgument argument) async {
    emit(LoadingState(oldPois: state.pois));
    final newPois = await _dataSource.getPointsOfInterest(argument);
    emit(FreshDataState(pois: newPois));
  }
}

abstract class PoiState {
  const PoiState({required this.pois});

  final List<PointOfInterest> pois;
  //final PoiLocationArgument argument;
}

// we are showing oldPois to not to break the experience
class LoadingState extends PoiState {
  const LoadingState({required List<PointOfInterest> oldPois})
      : super(pois: oldPois);
}

class FreshDataState extends PoiState {
  const FreshDataState({required List<PointOfInterest> pois})
      : super(pois: pois);
}

// class PoiSelectedState extends FreshDataState {
//   const PoiSelectedState(
//       {required this.poi, required List<PointOfInterest> pois})
//       : super(pois: pois);

//   final PointOfInterest poi;
// }
