import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          OrderChip(
            argument: argument,
          ),
          ActionChip(
            label: Text('Refresh'),
            onPressed: () => poiCubit.reloadAll(),
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

class OrderChip extends StatelessWidget {
  const OrderChip({
    Key? key,
    required this.argument,
  }) : super(key: key);

  final PoiLocationArgument argument;

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
          child: ListTile(
            leading: IsSelectedIcon(
              isSelected: argument.order == PoiOrder.distance,
            ),
            title: const Text('Distance'),
          ),
        ),
        PopupMenuItem(
          onTap: () => poiCubit.changeArgument(
            argument.copyWith(order: PoiOrder.name),
          ),
          child: ListTile(
            leading: IsSelectedIcon(
              isSelected: argument.order == PoiOrder.name,
            ),
            title: const Text('Name'),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () => poiCubit.changeArgument(
            argument.copyWith(isDescending: false),
          ),
          child: ListTile(
            leading: IsSelectedIcon(
              isSelected: !argument.isDescending,
            ),
            title: const Text('Ascending'),
          ),
        ),
        PopupMenuItem(
          onTap: () => poiCubit.changeArgument(
            argument.copyWith(isDescending: true),
          ),
          child: ListTile(
            leading: IsSelectedIcon(
              isSelected: argument.isDescending,
            ),
            title: const Text('Descending'),
          ),
        ),
      ],
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
