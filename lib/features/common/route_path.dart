import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';
import 'package:matchify/features/auth/auth_cubit.dart';
import 'package:matchify/features/auth/unauthorized_page.dart';
import 'package:matchify/features/common/pages/error_page.dart';
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
  final PoiSource poiSource;

  String? error;
  bool displayList = false;
  PointOfInterest? selectedPoi;

  MatchifyRouterDelegate({required this.poiSource})
      : navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (_, authState) => BlocBuilder<PoiCubit, PoiState>(
        builder: (context, poiState) {
          final isSignedIn = authState is SignedInState;

          final pois = poiState.pois;

          if (isSignedIn && poiState is InitialState) {
            BlocProvider.of<PoiCubit>(context).firstLoad();
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

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
                  maintainState: true,
                  child: PoiMap(
                    key: const Key('map'),
                    initialLocation: poiState is PoiStateWithArgument
                        ? poiState.argument.latLng
                        : const LatLng(0, 0),
                    pois: pois,
                    selectedPoi: selectedPoi,
                    selectPoi: _selectPoi,
                    swap: _swapView,
                  ),
                  key: const ValueKey('map'),
                ),
              if (isSignedIn && displayList && selectedPoi == null)
                MaterialPage(
                  child: PoiList(
                    selectPoi: _selectPoi,
                    pois: pois,
                    swap: _swapView,
                  ),
                  key: const ValueKey('list'),
                ),
              if (error != null)
                MaterialPage(
                  child: ErrorPage(errorMessage: error),
                  key: const ValueKey('error'),
                ),
            ],
            onPopPage: (route, result) {
              if (!route.didPop(result)) {
                return false;
              }

              if (displayList) {
                displayList = false;
              }

              if (selectedPoi != null) {
                selectedPoi = null;
              }
              notifyListeners();

              return true;
            },
          );
        },
      ),
    );
  }

  void _selectPoi(PointOfInterest? poi) {
    selectedPoi = poi;
    if (poi != null) {
      displayList = false;
    }
    notifyListeners();
  }

  void _swapView() async {
    displayList = !displayList;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(RoutePath configuration) async {
    if (configuration.isError) {
      error = configuration.error;
      return;
    }

    if (configuration.isUnauthorized) {
      return;
    }

    if (configuration.isPoi) {
      displayList = false;
      selectedPoi = await poiSource.getPointOfInterest(configuration.poiId!);
      return;
    }

    if (configuration.isHome) {
      selectedPoi = null;
      displayList = false;
      return;
    }

    if (configuration.isList) {
      selectedPoi = null;
      displayList = true;
      return;
    }
  }
}

class MatchifyRouteInformationParser extends RouteInformationParser<RoutePath> {
  @override
  Future<RoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    if (routeInformation.location == null) {
      return RoutePath.error(error: 'No location provided');
    }

    final uri = Uri.parse(routeInformation.location!);

    // home
    if (uri.pathSegments.isEmpty) {
      return RoutePath.home();
    }

    if (uri.pathSegments.length == 1) {
      // list
      if (uri.pathSegments[0] == 'list') {
        return RoutePath.list();
      }

      // map
      if (uri.pathSegments[0] == 'map') {
        return RoutePath.home();
      }

      if (uri.pathSegments[0] == 'signin') {
        return RoutePath.unauthorized();
      }
    }

    // map selected
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] == 'map') {
        final poiId = uri.pathSegments[1];
        return RoutePath.poi(poiId: poiId);
      }
    }

    return RoutePath.error(error: 'Unknown route');
  }

  @override
  RouteInformation? restoreRouteInformation(RoutePath configuration) {
    if (configuration.isHome) {
      return const RouteInformation(
        location: '',
      );
    }

    if (configuration.isList) {
      return const RouteInformation(
        location: 'list',
      );
    }

    if (configuration.isPoi) {
      return RouteInformation(
        location: 'map/${configuration.poiId}',
      );
    }

    if (configuration.isUnauthorized) {
      return const RouteInformation(
        location: 'signin',
      );
    }

    return null;
  }
}
