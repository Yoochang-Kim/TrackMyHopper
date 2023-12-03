import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Objects/busStop.dart';

class FavouriteStopsModel extends ChangeNotifier {
  // List to store the IDs of favorite bus stops.
  List<String> _favouriteStopsID = [];

  // Loads favorite stops from SharedPreferences.
  Future<void> loadFavourites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _favouriteStopsID = prefs.getStringList('favouriteStops') ?? [];
    notifyListeners(); // Notifies listeners about data changes.
  }

  // Getter for the list of favorite stop IDs.
  List<String> get favouriteStopsID => _favouriteStopsID;

  // Adds a bus stop to favorites and updates SharedPreferences.
  void addStop(BusStop stop) async {
    _favouriteStopsID.add(stop.id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favouriteStops', _favouriteStopsID);
    notifyListeners();
  }

  // Removes a bus stop from favorites and updates SharedPreferences.
  void removeStop(BusStop stop) async {
    _favouriteStopsID.remove(stop.id);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favouriteStops', _favouriteStopsID);
    notifyListeners();
  }

  // Checks if a bus stop is in the favorites list.
  bool isFavourite(BusStop stop) {
    return _favouriteStopsID.contains(stop.id);
  }

  // Returns the number of favorite stops.
  int getNumberOfStops() {
    return favouriteStopsID.length;
  }

  // Prints all favorite stop IDs to the console for debugging.
  void printStops() {
    for (var stop in favouriteStopsID) {
      print('Stop ID: $stop');
    }
  }
}
