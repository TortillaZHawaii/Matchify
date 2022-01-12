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
          PopupMenuButton(
            child: Chip(
              label: Row(
                children: [
                  Text(argument.order.name),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: ListTile(
                  leading: IsSelectedIcon(
                    isSelected: argument.order == PoiOrder.distance,
                  ),
                  title: const Text('Distance'),
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: IsSelectedIcon(
                    isSelected: argument.order == PoiOrder.name,
                  ),
                  title: const Text('Name'),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: ListTile(
                  leading: IsSelectedIcon(
                    isSelected: !argument.isDescending,
                  ),
                  title: const Text('Ascending'),
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: IsSelectedIcon(
                    isSelected: argument.isDescending,
                  ),
                  title: const Text('Descending'),
                ),
              ),
            ],
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
