import 'dart:async';
import 'dart:convert';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinch_zoom_release_unzoom/pinch_zoom_release_unzoom.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:unihopper_timetable/Model/favoriteStopModel.dart';
import 'package:unihopper_timetable/Objects/busStop.dart';
import '../Model/busStopModel.dart';
import '../Marker/basicMarker.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../auth_token.dart';

class MapPage extends StatefulWidget {
  final LatLng? selectedLocation;
  const MapPage({Key? key, required this.selectedLocation}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();

}
class _MapPageState extends State<MapPage> with TickerProviderStateMixin{
  // Current slider index
  int _current = 0;
  // Previous map marker index
  int previousIndex = 0;
  List<LatLng> coordinates = [];
  bool _myLocationEnabled = false;
  bool _isPressed = false;
  String styleString = "https://mapapi.bearkim117.com/styles/osm-liberty/style.json?token=$authToken";

  // Controllers
  final pageController = PageController();
  CarouselController pageCarouselController = CarouselController();
  late MaplibreMapController mapController;
  ScrollController scrollController = ScrollController();

  // Toggles user's location visibility on the map.
  void _toggleLocation() {
    setState(() {
      _myLocationEnabled = !_myLocationEnabled;
    });
  }

  // Changes the state of a button when pressed.
  void _onHighlightChanged(bool isPressed) {
    setState(() {
      _isPressed = isPressed;
    });
  }

  // Initializes the map and adds markers and lines on map creation.
  void _onMapCreated(MaplibreMapController controller) async{
    mapController = controller;
    mapController.onSymbolTapped.add(_onSymbolTapped);

    // Loading and setting up the map with custom data.
    if (widget.selectedLocation != null) {
      String jsonString = await rootBundle.loadString('assets/uni-line.json');
      Map<String, dynamic> uniLine = json.decode(jsonString);
      await mapController.addGeoJsonSource("uhL", uniLine);
      await mapController.addLineLayer(
        "uhL",
        "unihopper_line",
        const LineLayerProperties(
          lineColor: '#539165',
          lineWidth: 3,
        ),
      );

      for (var marker in mapMarkers) {
        marker.symbol = await mapController.addSymbol(
            SymbolOptions(
                geometry: marker.location,
              iconImage: marker.iconPath,
              iconSize: 0.3,
              //draggable: true
            ),
        );
      }
      await changeMarkerIcon(0, 'assets/bus-stop.png').then((result){
        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(widget.selectedLocation!, 16),
        );
      });
    }
  }

  // Handles the event when a map symbol (marker) is tapped.
  void _onSymbolTapped(Symbol symbol) {
    // Iterates through the marker list to find the tapped symbol's marker.
    for (var i = 0; i < mapMarkers.length; i++) {
      if (mapMarkers[i].symbol == symbol) {
        // If the tapped symbol's marker is found, changes its image.
        changeMarkerIcon(i, 'assets/bus-stop.png').then((result){
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(mapMarkers[i].location, 16),
          );
          pageCarouselController.jumpToPage(
            i,
          );
        });
      } else {
        // Changes the images of all other markers to marker.png.
        changeMarkerIcon(i, 'assets/markers.png');
      }
    }
  }

  // Initial setup for map markers and model fetching.
  @override
  void initState() {
    super.initState();
    context.read<BusStopModel>().getBusStopInfo();
    mapMarkers.forEach((marker) {
      marker.iconPath = 'assets/markers.png';
    });
  }

  // Dispose controllers when the widget is removed.
  @override
  void dispose() {
    pageController.dispose();
    mapController?.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // Change the icon of a map marker.
  Future<void> changeMarkerIcon(int index, String newPath) async {
    MapMarker marker = mapMarkers[index];

    // Delete the existing symbol.
    if(marker.symbol != null){
      await mapController.removeSymbol(marker.symbol!);
    }

    // Add a new symbol with the updated icon.
    marker.symbol = await mapController.addSymbol(

      SymbolOptions(
        geometry: marker.location,
        iconImage: newPath,
        iconSize: 0.34,
      )
    );

    setState(() {
      mapMarkers[index].iconPath = newPath;

    });
  }

  // Update the slider + camera.
  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    int selecetedLocationIndex = 0;
    if (widget.selectedLocation != oldWidget.selectedLocation) {
        for(int i = 0; i < mapMarkers.length; i++){
          if(mapMarkers[i].location.latitude.toStringAsFixed(6) == widget.selectedLocation!.latitude.toStringAsFixed(6) &&
              mapMarkers[i].location.longitude.toStringAsFixed(6) == widget.selectedLocation!.longitude.toStringAsFixed(6)){
            selecetedLocationIndex = i;
            break;
          }
      }
        int markerIndex = selecetedLocationIndex;

        changeMarkerIcon(previousIndex, 'assets/markers.png');

        // Once the maker icon has changed, camera animation are changed
        changeMarkerIcon(markerIndex, 'assets/bus-stop.png').then((result){
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(widget.selectedLocation!, 15),
          );

          // Moves the page controller to the respective page
          pageCarouselController.jumpToPage(
            markerIndex,
          );
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<BusStopModel>(
        builder: (context, busStopModel, child){
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;
          return Consumer <FavouriteStopsModel>(
              builder: (context, favourite, child){
                return Stack(
                  children: [
                    LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          return SizedBox(
                            height: constraints.maxHeight * 0.89,
                            child: MaplibreMap(
                              styleString: styleString,
                              initialCameraPosition: CameraPosition(
                                  target: widget.selectedLocation ?? LatLng(-42.87989,147.32472),
                                  zoom:17
                              ),
                              myLocationEnabled: _myLocationEnabled,
                              minMaxZoomPreference: MinMaxZoomPreference(1,18),
                              onMapCreated: _onMapCreated,
                            ),
                          );
                        }),
                    Positioned(
                      bottom: 130,
                      right: 20,
                      child: InkWell(
                        onTap: _toggleLocation,
                        onHighlightChanged: _onHighlightChanged,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _isPressed
                                    ? Colors.grey.withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.5),
                                spreadRadius: _isPressed ? 0 : 2,
                                blurRadius: _isPressed ? 0 : 5,
                                offset: Offset(0, _isPressed ? 0 : 3),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.my_location,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize:0.13,
                      minChildSize: 0.13,
                      maxChildSize: 0.5,
                      snap: true,
                      snapSizes: [0.13, 0.5],
                      builder: (BuildContext context, ScrollController scrollController) {
                        return busStopModel.stops.isNotEmpty
                            ? SingleChildScrollView(
                          controller: scrollController,
                          child: Container(
                            color: Colors.white,
                            child:CarouselSlider.builder(
                              carouselController: pageCarouselController,
                              itemCount: busStopModel.stops.length,
                              itemBuilder: (context, index, realIdx) {
                                BusStop stop = busStopModel.stops[index];
                                return Container(
                                  color: Colors.white,
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Image.asset(
                                          'assets/minus.png',
                                          width: screenWidth * 0.2,
                                          height: screenHeight * 0.03,
                                          fit: BoxFit.contain,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text("Stop ${index+1}, ${mapMarkers[index].name}", style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: busStopModel.getScheduledTimeText(stop, screenWidth),
                                      ),
                                      Divider(
                                          color: Colors.grey[200]
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(
                                          favourite.isFavourite(stop)
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: favourite.isFavourite(stop) ? Colors.yellow : null,
                                        ),
                                        iconSize: screenWidth * 0.06,
                                        onPressed: () {
                                          if (favourite.isFavourite(stop)) {
                                            favourite.removeStop(stop);
                                          } else {
                                            favourite.addStop(stop);
                                          }
                                          favourite.printStops();
                                          },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: GestureDetector(
                                          onTap: () {
                                            context.pushTransparentRoute(ImageShowPage(index));
                                            },
                                          child: Hero(
                                            tag: 'imageHero$index',
                                            child: PinchZoomReleaseUnzoomWidget(
                                              child: Image.asset(
                                                mapMarkers[index].image,
                                                width: screenWidth * 1,
                                                height: screenHeight * 0.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                },
                              options: CarouselOptions(
                                height: screenHeight * 0.5,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                initialPage: 0,
                                autoPlay: false,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _current = index;
                                    mapController.animateCamera(
                                      CameraUpdate.newLatLngZoom( mapMarkers[_current].location as LatLng, 17),
                                      duration: Duration(milliseconds: 300),
                                    );
                                    changeMarkerIcon(previousIndex, 'assets/markers.png');
                                    changeMarkerIcon(index, 'assets/bus-stop.png');
                                    previousIndex = index;
                                  });
                                  },
                              ),
                            ),
                          ),
                        ): const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),),);
                        },
                    ),
                  ],
                );
              });
          },
      ),
    );
  }
}

class ImageShowPage extends StatelessWidget{
  int index;
  ImageShowPage(this.index);

  Widget build(BuildContext context) {
    return DismissiblePage(
      onDismissed: () {
        Navigator.of(context).pop();
      },
      // Note that scrollable widget inside DismissiblePage might limit the functionality
      // If scroll direction matches DismissiblePage direction
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: false,
      child: Hero(
        tag: 'imageHero$index',
        child: PinchZoomReleaseUnzoomWidget(
          child: Image.asset(mapMarkers[index].image),
        ),
      ),
    );
  }
}
