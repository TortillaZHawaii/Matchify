enum Sports {
  football,
  basketball,
  other,
}

class SportsFactory {
  static String getSportsName(Sports sport) {
    switch (sport) {
      case Sports.football:
        return "Football";
      case Sports.basketball:
        return "Basketball";
      case Sports.other:
      default:
        return "Other";
    }
  }

  static Sports getSports(String sportName) {
    switch (sportName.toLowerCase()) {
      case "football":
        return Sports.football;
      case "basketball":
        return Sports.basketball;
      case "other":
      default:
        return Sports.other;
    }
  }
}
