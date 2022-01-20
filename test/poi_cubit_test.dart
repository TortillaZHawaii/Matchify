// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/data/points_of_interest/model/sports.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';
import 'package:matchify/features/points_of_interest/poi_cubit.dart';
import 'package:mocktail/mocktail.dart';

class PoiSourceMock extends Mock implements PoiSource {}

void main() {
  group('PoiCubit initial', () {
    late PoiSourceMock poiSource;
    late PoiCubit poiCubit;

    setUp(() {
      poiSource = PoiSourceMock();
      poiCubit = PoiCubit(dataSource: poiSource);
    });

    test('Initial state is correct', () {
      expect(poiCubit.state, isA<InitialState>());
    });

    test('Initial state contains empty list of pois', () {
      expect(poiCubit.state.pois, isEmpty);
    });
  });

  group('PoiCubit non emiting functionality', () {
    late PoiSourceMock poiSource;
    late PoiCubit poiCubit;
    late PointOfInterest poi;

    setUp(() {
      poiSource = PoiSourceMock();
      poiCubit = PoiCubit(dataSource: poiSource);
      poi = PointOfInterest(
        id: '1',
        name: 'Test 1',
        latLng: const LatLng(12, 34),
        sport: Sports.football,
      );
    });

    blocTest(
      'Add poi doesn\'t emit new state and poi source is called once',
      build: () {
        when(() => poiSource.addPointOfInterest(poi)).thenAnswer(
          (_) => Future.value(),
        );

        return poiCubit;
      },
      act: (PoiCubit cubit) => cubit.addPoi(poi),
      expect: () => [],
      verify: (_) {
        verify(() => poiSource.addPointOfInterest(poi)).called(1);
      },
    );

    blocTest(
      'Set busyness doesn\'t emit new state and poi source is called once',
      build: () {
        when(() => poiSource.setBusyness(poi, Busyness.busy)).thenAnswer(
          (_) => Future.value(),
        );

        return poiCubit;
      },
      act: (PoiCubit cubit) => cubit.setBusyness(poi, Busyness.busy),
      expect: () => [],
      verify: (_) {
        verify(() => poiSource.setBusyness(poi, Busyness.busy)).called(1);
      },
    );
  });

  group('PoiCubit loading', () {
    late PoiSourceMock poiSource;
    late PoiCubit poiCubit;

    late PoiLocationArgument argument1;
    late List<PointOfInterest> freshPois;

    setUp(() {
      argument1 = PoiLocationArgument(
        latLng: const LatLng(21, 37),
      );

      poiSource = PoiSourceMock();
      poiCubit = PoiCubit(dataSource: poiSource);

      freshPois = [
        PointOfInterest(
          id: '1',
          name: 'Test 1',
          latLng: const LatLng(12, 34),
          sport: Sports.football,
        ),
        PointOfInterest(
          id: '2',
          name: 'Test 2',
          latLng: const LatLng(-12, -34),
          sport: Sports.basketball,
        ),
      ];
    });

    blocTest(
      'Reload pois emits LoadingState and then FreshDataState with new pois',
      build: () {
        when(() => poiSource.getPointsOfInterest(argument1)).thenAnswer(
          (_) => Future.value(freshPois),
        );

        return poiCubit;
      },
      act: (PoiCubit cubit) => cubit.reloadPois(argument1),
      expect: () => [
        isA<LoadingState>()
            .having(
              (state) => state.pois,
              'empty pois',
              isEmpty,
            )
            .having(
              (state) => state.argument,
              'new argument',
              argument1,
            ),
        isA<FreshDataState>()
            .having(
              (state) => state.pois,
              'fresh pois',
              containsAll(freshPois),
            )
            .having(
              (state) => state.argument,
              'new argument',
              argument1,
            ),
      ],
    );

    blocTest(
      'Change argument',
      build: () {
        when(() => poiSource.getPointsOfInterest(argument1)).thenAnswer(
          (_) => Future.value(freshPois),
        );

        return poiCubit;
      },
      act: (PoiCubit cubit) => cubit.changeArgumentAndReload(argument1),
      expect: () => [
        isA<ChangedArgumentState>().having(
          (state) => state.argument,
          'new argument',
          argument1,
        ),
        isA<LoadingState>()
            .having(
              (state) => state.pois,
              'empty pois',
              isEmpty,
            )
            .having(
              (state) => state.argument,
              'new argument',
              argument1,
            ),
        isA<FreshDataState>()
            .having(
              (state) => state.pois,
              'fresh pois',
              containsAll(freshPois),
            )
            .having(
              (state) => state.argument,
              'new argument',
              argument1,
            ),
      ],
    );
  });
}
