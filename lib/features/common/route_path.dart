import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';
import 'package:matchify/features/auth/auth_cubit.dart';
import 'package:matchify/features/auth/unauthorized_page.dart';
import 'package:matchify/features/points_of_interest/list/poi_list.dart';
import 'package:matchify/features/points_of_interest/map/poi_map.dart';
import 'package:matchify/features/points_of_interest/poi_cubit.dart';

class RoutePath {
  final bool isSignedIn;
  final String? poiId;
  final bool displayList;
  final String? error;

  RoutePath.unauthorized()
      : isSignedIn = false,
        poiId = null,
        displayList = false,
        error = null;

  RoutePath.home()
      : isSignedIn = true,
        poiId = null,
        displayList = false,
        error = null;

  RoutePath.poi({required this.poiId})
      : assert(poiId != null),
        isSignedIn = true,
        displayList = false,
        error = null;

  RoutePath.list()
      : isSignedIn = true,
        poiId = null,
        displayList = true,
        error = null;

  RoutePath.error({required this.error})
      : isSignedIn = false,
        poiId = null,
        displayList = false;

  bool get isHome => isSignedIn && !displayList;
  bool get isList => isSignedIn && displayList;
  bool get isPoi => isSignedIn && poiId != null;
  bool get isAuthorized => isSignedIn;
  bool get isUnauthorized => !isAuthorized;
  bool get isError => error != null;
}

class MatchifyRouterDelegate extends RouterDelegate<RoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RoutePath> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  final PoiCubit poiCubit;
  final AuthCubit authCubit;

  bool displayList = false;

  MatchifyRouterDelegate({
    required this.authCubit,
    required this.poiCubit,
  }) : navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final isSignedIn = authCubit.state is SignedInState;

    final poiCubitState = poiCubit.state;
    final selectedPoi =
        poiCubitState is SelectedPoiState ? poiCubitState.selected : null;

    final pois = poiCubitState.pois;

    return Navigator(
      key: navigatorKey,
      pages: [
        if (!isSignedIn)
          const MaterialPage(
            key: ValueKey('signin'),
            child: UnauthorizedPage(),
          ),
        if (isSignedIn)
          MaterialPage(
            child: PoiMap(
              initialLocation: poiCubitState is PoiStateWithArgument
                  ? poiCubitState.argument.latLng
                  : const LatLng(0, 0),
              pois: pois,
              selectedPoi: selectedPoi,
              swap: _swapView,
            ),
            key:
                ValueKey(selectedPoi != null ? 'map-${selectedPoi.id}' : 'map'),
          ),
        if (isSignedIn && displayList && selectedPoi == null)
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

        poiCubit.unselectPoi();
        notifyListeners();

        return true;
      },
    );
  }

  void _swapView() {
    displayList = !displayList;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(RoutePath configuration) async {}
}
