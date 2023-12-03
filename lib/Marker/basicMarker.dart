import 'package:maplibre_gl/mapbox_gl.dart';

// Defines a marker for representing bus stops on a map.
// Each marker includes an image, name, and geographic location.
class MapMarker {
  // Path to the icon image for the bus stop marker.
  late final String image;
  // Name or title of the bus stop.
  late final String name;
  // Geographic coordinates of the bus stop.
  late final LatLng location;
  // Path to the default icon for the marker, can be overridden.
  String iconPath;
  // Optional Mapbox symbol representing the marker on the map.
  Symbol? symbol;

  // Constructor for creating a MapMarker instance for a bus stop.
  MapMarker({
    required this.image,
    required this.name,
    required this.location,
    this.iconPath = "assets/markers.png"
  });
}

// List of predefined MapMarker instances, each representing a different bus stop location.
final mapMarkers = [
  MapMarker(
    image: 'assets/stop0.png',
    name: 'Hobart Apartment',
    location: LatLng(-42.8791674, 147.3239583),
  ),
  MapMarker(
    image: 'assets/stop1.png',
    name: 'Medical Science Precinct',
    location: LatLng(-42.8787208, 147.3294792),
  ),
  MapMarker(
    image: 'assets/stop2.png',
    name: 'The Hedberg',
    location: LatLng(-42.8797206, 147.3318629),
  ),
  MapMarker(
      image: 'assets/stop3.png',
      name: 'Creative Arts Precinct"',
      location: LatLng(-42.8821518, 147.3370613)
  ),
  MapMarker(
    image: 'assets/stop4.png',
    name: 'IMAS',
    location: LatLng(-42.8861755, 147.3349016),
  ),
  MapMarker(
    image: 'assets/stop5.png',
    name: 'Magnet Court',
    location: LatLng(-42.89535, 147.32783),
  ),
  MapMarker(
    image: 'assets/stop6.png',
    name: 'Stanley Burbury Theatre',
    location: LatLng(-42.9043615, 147.3259334),
  ),
  MapMarker(
    image: 'assets/stop7.png',
    name: 'Accomodation',
    location: LatLng(-42.905169, 147.3198948),
  ),
  MapMarker(
    image: 'assets/stop8.png',
    name: 'The Metz',
    location: LatLng(-42.8953669, 147.3275943),
  ),
  MapMarker(
    image: 'assets/stop9.png',
    name: "St David's Park",
    location: LatLng(-42.8868591, 147.3282366),
  ),
  MapMarker(
    image: 'assets/stop10.png',
    name: 'Swisherr',
    location: LatLng(-42.8820171, 147.3218744),
  ),
];

