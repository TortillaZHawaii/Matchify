import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/data/points_of_interest/model/sports.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';
import 'package:matchify/features/points_of_interest/poi_cubit.dart';
import 'package:matchify/features/points_of_interest/poi_item_tile.dart';
import 'package:matchify/features/utils/string_extensions.dart';

class PoiFilters extends StatelessWidget {
  final PoiLocationArgument argument;

  const PoiFilters({Key? key, required this.argument}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final poiCubit = BlocProvider.of<PoiCubit>(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SportChip(
              sport: Sports.football,
              selectedSports: argument.sports,
              onSelected: (_) => _toggleSportInCubit(Sports.football, poiCubit),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SportChip(
              sport: Sports.basketball,
              selectedSports: argument.sports,
              onSelected: (_) =>
                  _toggleSportInCubit(Sports.basketball, poiCubit),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OrderChip(
              argument: argument,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: BusyChip(
              argument: argument,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSportInCubit(Sports sport, PoiCubit poiCubit) {
    final set = argument.sports;

    if (set.contains(sport)) {
      set.remove(sport);
    } else {
      set.add(sport);
    }

    poiCubit.changeArgument(argument.copyWith(sports: set));
  }
}

class BusyChip extends StatelessWidget {
  final PoiLocationArgument argument;

  const BusyChip({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final poiCubit = BlocProvider.of<PoiCubit>(context);

    return PopupMenuButton(
      child: Chip(
        label: Row(
          children: const [
            Text('Busyness'),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (ctx) => <PopupMenuEntry>[
        for (final busyness in Busyness.values)
          PopupMenuItem(
            onTap: () {
              _toggleBusyInCubit(busyness, poiCubit);
            },
            child: SelectableTile(
              isSelected: argument.busyness.contains(busyness),
              title: busyness.name.capitalize(),
            ),
          ),
        // PopupMenuItem(
        //   onTap: () {
        //     _toggleBusyInCubit(Busyness.busy, poiCubit);
        //   },
        //   child: SelectableTile(
        //     isSelected: argument.busyness.contains(Busyness.busy),
        //     title: 'Busy',
        //   ),
        // ),
        // PopupMenuItem(
        //   onTap: () {
        //     _toggleBusyInCubit(Busyness.moderate, poiCubit);
        //   },
        //   child: SelectableTile(
        //     isSelected: argument.busyness.contains(Busyness.moderate),
        //     title: 'Moderate',
        //   ),
        // ),
        // PopupMenuItem(
        //   onTap: () {
        //     _toggleBusyInCubit(Busyness.free, poiCubit);
        //   },
        //   child: SelectableTile(
        //     isSelected: argument.busyness.contains(Busyness.free),
        //     title: 'Empty',
        //   ),
        // ),
      ],
    );
  }

  void _toggleBusyInCubit(Busyness busy, PoiCubit poiCubit) {
    final set = argument.busyness;

    if (set.contains(busy)) {
      set.remove(busy);
    } else {
      set.add(busy);
    }

    poiCubit.changeArgument(argument.copyWith(busyness: set));
  }
}

class OrderChip extends StatelessWidget {
  final PoiLocationArgument argument;

  const OrderChip({
    Key? key,
    required this.argument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final poiCubit = BlocProvider.of<PoiCubit>(context);

    return PopupMenuButton(
      child: Chip(
        label: Row(
          children: [
            Text(argument.order.name.capitalize()),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) => <PopupMenuEntry>[
        PopupMenuItem(
          onTap: () => poiCubit.changeArgument(
            argument.copyWith(order: PoiOrder.distance),
          ),
          child: SelectableTile(
            title: 'Distance',
            isSelected: argument.order == PoiOrder.distance,
          ),
        ),
        PopupMenuItem(
          onTap: () => poiCubit.changeArgument(
            argument.copyWith(order: PoiOrder.name),
          ),
          child: SelectableTile(
            title: 'Name',
            isSelected: argument.order == PoiOrder.name,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () => poiCubit.changeArgument(
            argument.copyWith(isDescending: false),
          ),
          child: SelectableTile(
            title: 'Ascending',
            isSelected: !argument.isDescending,
          ),
        ),
        PopupMenuItem(
          onTap: () => poiCubit.changeArgument(
            argument.copyWith(isDescending: true),
          ),
          child: SelectableTile(
            title: 'Descending',
            isSelected: argument.isDescending,
          ),
        ),
      ],
    );
  }
}

class SelectableTile extends StatelessWidget {
  final String title;
  final bool isSelected;

  const SelectableTile({
    Key? key,
    required this.title,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: IsSelectedIcon(
        isSelected: isSelected,
      ),
      title: Text(title),
    );
  }
}

class IsSelectedIcon extends StatelessWidget {
  final bool isSelected;

  const IsSelectedIcon({Key? key, required this.isSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSelected ? Icons.check : null,
    );
  }
}

class SportChip extends FilterChip {
  SportChip({
    Key? key,
    required Sports sport,
    required Set<Sports> selectedSports,
    required Function(bool)? onSelected,
  }) : super(
            key: key,
            label: Text(SportsFactory.getSportsName(sport)),
            avatar: Icon(SportsIconFactory.getIconData(sport)),
            selected: selectedSports.contains(sport),
            onSelected: onSelected);
}
