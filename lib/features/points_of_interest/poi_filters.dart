import 'package:flutter/material.dart';
import 'package:matchify/data/points_of_interest/model/sports.dart';
import 'package:matchify/data/points_of_interest/poi_source.dart';
import 'package:matchify/features/points_of_interest/poi_item_tile.dart';

class PoiFilters extends StatelessWidget {
  final PoiLocationArgument argument;

  const PoiFilters({Key? key, required this.argument}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SportChip(
              sport: Sports.football,
              selectedSports: argument.sports,
              onSelected: (_) {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SportChip(
              sport: Sports.basketball,
              selectedSports: argument.sports,
              onSelected: (_) {},
            ),
          ),
          // ActionChip(
          //   label: Text(argument.order.name),
          //   onPressed: () {},
          // ),
        ],
      ),
    );
  }
}

// class SortChip extends StatelessWidget {
//   final PoiSortArgument argument;

//   const SortChip({Key? key, required this.argument}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: ChoiceChip(
//         label: Text(argument.sort.toString()),
//         selected: argument.sort == PoiSort.distance,
//         onSelected: (selected) {
//           if (selected) {
//             argument.sort = PoiSort.distance;
//           }
//         },
//       ),
//     );
//   }
// }

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

class FloatingChip extends StatelessWidget {
  const FloatingChip({
    Key? key,
    required this.text,
    this.icon,
    this.onTap,
    required this.highlighted,
  }) : super(key: key);

  final String text;
  final Icon? icon;
  final GestureTapCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        backgroundColor: highlighted
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.surface,
        elevation: 1.0,
        avatar: icon,
        label: Text(text),
      ),
    );
  }
}
