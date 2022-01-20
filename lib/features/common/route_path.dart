import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';
import 'package:matchify/features/auth/auth_cubit.dart';
import 'package:matchify/features/auth/unauthorized_page.dart';
import 'package:matchify/features/common/pages/loading.dart';
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

  bool displayList = false;

  MatchifyRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (_, authState) => BlocBuilder<PoiCubit, PoiState>(
        builder: (context, poiState) {
          final isSignedIn = authState is SignedInState;

          final selectedPoi =
              poiState is SelectedPoiState ? poiState.selected : null;

          if (selectedPoi != null) {
            displayList = false;
          }

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
              MaterialPage(
                maintainState: true,
                child: PoiMap(
                  key: const Key('map'),
                  initialLocation: poiState is PoiStateWithArgument
                      ? poiState.argument.latLng
                      : const LatLng(0, 0),
                  pois: pois,
                  selectedPoi: selectedPoi,
                  swap: _swapView,
                ),
                key: const ValueKey('map'),
              ),
              if (!isSignedIn)
                const MaterialPage(
                  key: ValueKey('signin'),
                  child: UnauthorizedPage(),
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

              BlocProvider.of<PoiCubit>(context).unselectPoi();
              notifyListeners();

              return true;
            },
          );
        },
      ),
    );
  }

  void _swapView() async {
    displayList = !displayList;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(RoutePath configuration) async {}
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
