import 'package:flutter/material.dart';
import 'package:matchify/data/points_of_interest/model/point_of_interest.dart';
import 'package:matchify/features/common/string_extensions.dart';

import '../common/sports_icon_factory.dart';

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
      subtitle: poi.busyiness != Busyness.unknown
          ? PoiItemTileSubtitle(busyness: poi.busyiness)
          : null,
    );
  }
}

class PoiItemTileSubtitle extends StatelessWidget {
  final Busyness busyness;

  const PoiItemTileSubtitle({Key? key, required this.busyness})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      busyness.name.capitalize(),
    );
  }
}
