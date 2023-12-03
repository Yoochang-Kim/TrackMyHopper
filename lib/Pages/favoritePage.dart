import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import '../Animation/rotation.dart';
import '../Model/busStopModel.dart';
import '../Model/favoriteStopModel.dart';
import '../Objects/busStop.dart';
import 'package:line_icons/line_icons.dart';

class FavoritePage extends StatefulWidget {
  final ValueChanged<LatLng>? onTileClicked;
  const FavoritePage({ Key? key, this.onTileClicked }) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> with SingleTickerProviderStateMixin {
  late RotationAnimation rotationAnimation;

  @override
  void initState() {
    super.initState();
    rotationAnimation = RotationAnimation(this);
    context.read<BusStopModel>().getFavoriteStopsInfo(context);
  }

  @override
  void dispose() {
    rotationAnimation.rotationController.dispose();
    super.dispose();
  }

  String convertSecondsToTime(int? totalSeconds) {
    if (totalSeconds == null) {
      return "";
    }
    //print("Test");
    Duration duration = Duration(seconds: totalSeconds);
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    String time = [
      if(hours < 10) "0$hours" else "$hours",
      if(minutes < 10) "0$minutes" else "$minutes"
    ].join(':');

    return time;
  }

  @override
  Widget build(BuildContext context) {
    context.read<BusStopModel>().getFavoriteStopsInfo(context);
    rotationAnimation.rotationController.repeat();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: Center(child: LineIcon.star()),
      ),
      body: Consumer<BusStopModel>(
        builder: (context, busStopModel, child) {
          return Consumer<FavouriteStopsModel>(
              builder: (context, favourites, child) {
                return Stack(
                  children: [
                    favourites.getNumberOfStops() > 0
                        ? ListView.separated(
                      itemBuilder: (BuildContext context, int index) {
                        double screenWidth = MediaQuery.of(context).size.width;
                        BusStop stop = busStopModel.favoriteStops[index];
                        Widget? subtitleWidget;
                        subtitleWidget = busStopModel.getScheduledTimeText(stop, screenWidth);

                        Color iconColor = Colors.blue;

                        return Dismissible(
                          key: Key(stop.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            var dismissedStop = stop;
                            favourites.removeStop(dismissedStop);
                            busStopModel.removeFavoriteStop(dismissedStop);

                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${dismissedStop.getName} removed from favourites"))
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(LineIcons.trash, color: Colors.white),
                                    Text(" Delete", style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(LineIcons.bus, color: iconColor,),
                            title: Text(stop.getName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: subtitleWidget,
                            onTap: () {
                              LatLng selectedLocation = LatLng(stop.lat, stop.lon);
                              if (widget.onTileClicked != null) {
                                widget.onTileClicked!(selectedLocation);
                              }
                            },
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.grey.withOpacity(0.1)),
                      itemCount: busStopModel.favoriteStops.length,
                    )
                        : const Center(
                      child: Text(
                        "No data available, please select a favorite stop",
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                        right: 30.0,
                        bottom: 50.0,
                        child: Consumer<BusStopModel>(
                            builder: (context, busStopModel, child) {
                              return FloatingActionButton(
                                heroTag: "FavoriteFreshButton",
                                onPressed: busStopModel.isRequestInProgress ? null : () {
                                  rotationAnimation.rotationController.repeat();
                                  busStopModel.getFavoriteStopsInfo(context).then((_){
                                    rotationAnimation.rotationController.stop();
                                  });
                                },
                                backgroundColor: Colors.white,
                                shape: const CircleBorder(),
                                child: busStopModel.isRequestInProgress
                                    ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.blue)
                                )
                                    : AnimatedBuilder(
                                    animation: rotationAnimation.rotationAnimation,
                                    builder: (_, __) {
                                      return Transform.rotate(
                                          angle: rotationAnimation.rotationAnimation.value,
                                          child: const Icon(Icons.refresh, color: Colors.blue)
                                      );
                                    }
                                ),
                              );
                            }
                        )
                    )
                  ],
                );
              }
          );
        },
      ),
    );
  }
}
