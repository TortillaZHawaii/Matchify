import 'package:flutter/material.dart';
import 'package:matchify/data/points_of_interest/model/sports.dart';

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
