import 'package:flutter/material.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/data/points_of_interest/model/sports.dart';

class PoiItemTile extends StatelessWidget {
  final PointOfInterest poi;
  final Function()? onTap;
  final Function()? onLongPress;

  const PoiItemTile({Key? key, required this.poi, this.onTap, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Icon(
        SportsIconFactory.getIconData(poi.sport),
        color: Theme.of(context).iconTheme.color,
        size: 30,
      ),
      title: Text(
        poi.name,
        style: Theme.of(context).textTheme.headline6,
      ),
      subtitle: poi.address != null ? Text(poi.address!) : null,
    );
  }
}

class PoiSmallTile extends StatelessWidget {
  final PointOfInterest poi;

  const PoiSmallTile({Key? key, required this.poi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SportsIconFactory {
  static IconData getIconData(Sports sport) {
    switch (sport) {
      case Sports.football:
        return Icons.sports_soccer;
      case Sports.basketball:
        return Icons.sports_basketball;
      case Sports.other:
      default:
        return Icons.sports;
    }
  }
}
