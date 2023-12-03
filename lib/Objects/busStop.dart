class BusStop {
  // Name of the bus stop.
  final String name;
  // Unique identifier for the bus stop.
  final String id;
  // Latitude coordinate of the bus stop.
  final double lat;
  // Longitude coordinate of the bus stop.
  final double lon;
  // Image associated with the bus stop (optional).
  late final String? image;
  // Scheduled arrival time in seconds since midnight (optional).
  final int? scheduledArrival;
  // Scheduled departure time in seconds since midnight (optional).
  final int? scheduledDeparture;
  // Head sign or direction of the bus (optional).
  final String? headsign;
  // Remaining time in seconds until the bus arrives (optional).
  final int? remaining;
  // Remaining hours until the bus arrives (optional).
  final int? remainingHour;
  // Remaining minutes until the bus arrives (optional).
  final int? remainingMinute;
  // Remaining seconds until the bus arrives (optional).
  final int? remainingSecond;
  // String representation of the remaining time (optional).
  final String? remainingStr;
  // Type of bus (e.g Unihopper 1 or Unihopper 2)
  final String busType;

  // Constructor for initializing a BusStop instance.
  BusStop({
    required this.name,
    required this.id,
    required this.lat,
    required this.lon,
    this.scheduledArrival = 0,
    this.scheduledDeparture = 0,
    this.headsign = "",
    this.remaining = 0,
    this.remainingHour = 0,
    this.remainingMinute = 0,
    this.remainingSecond = 0,
    this.remainingStr = "",
    this.busType = ""
  });

  // Getters for accessing bus stop properties.
  String get getName => name;
  String get getId => id;
  double get getLat => lat;
  double get getLon => lon;
  int? get getScheduledArrival => scheduledArrival;
  int? get getScheduledDeparture => scheduledDeparture;

  // Override toString method
  @override
  String toString() {
    return 'BusStop{name: $name, id: $id, lat: $lat, lon: $lon, scheduledArrival: $scheduledArrival, scheduledDeparture: $scheduledDeparture, headsign: $headsign}';
  }
}
