import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../Objects/busStop.dart';
import 'favoriteStopModel.dart';

class BusStopModel extends ChangeNotifier {
  // Bus stops and their related information
  final List<BusStop> _stops = [];
  final List<BusStop> _favoriteStops = [];
  final List<int> _remainingTime = [];
  final List<int> _favoriteRemainingTime = [];
  BusStop? _selectedStop;
  bool _isRequestInProgress = false;
  bool _isNetworkError = false;
  bool _isLoaded = false;

  // Predefined list of bus stop IDs.
  final List<String> stopId =
  [
    "1:hobart_apartment",
    "1:medical_science_precinct",
    "1:the_hedberg",
    "1:creative_arts_precinct",
    "1:imas",
    "1:magnet_court",
    "1:stanley_burbury_theatre",
    "1:accommodation",
    "1:the_metz",
    "1:st_davids_park",
    "1:swisherr"
  ];

  // Public getters
  bool get isLoaded => _isLoaded;
  bool get isNetworkError => _isNetworkError;
  bool get isRequestInProgress => _isRequestInProgress;
  List<BusStop> get stops => _stops;
  List<BusStop> get favoriteStops => _favoriteStops;
  List<int> get remainingTime => _remainingTime;
  List<int> get favoriteRemainingTime => _favoriteRemainingTime;
  BusStop? get selectedStop => _selectedStop;

  // Setter to update the loaded state and notify listeners.
  set isLoaded(bool value) {
    _isLoaded = value;
    notifyListeners();
  }

  // Fetches information for each bus stop.
  Future<void> getBusStopInfo() async {
    //print("progress is $isRequestInProgress");
    if (isRequestInProgress) return;
    _isRequestInProgress = true;
    _isNetworkError = false;

    _stops.clear();
    _remainingTime.clear();

    try {
      List<Map<String, dynamic>> stopInfoData = await fetchStopInfo().catchError((e) {
        print(e);
        _isNetworkError = true;
        notifyListeners();
      });

      if (_isNetworkError) return;

      var now = DateTime.now();
      var nowSeconds = now.hour * 3600 + now.minute * 60 + now.second;
      //var nowSeconds = 62400;

      for (final id in stopId) {
        final Map<String, dynamic> stopInfo = stopInfoData.firstWhere(
                (element) => element['id'] == id,
            orElse: () => <String, dynamic>{}
        );

        //print("stopInfoData는 $stopInfoData");

        if (stopInfo.isNotEmpty) {
          List<Map<String, dynamic>> stopTimesData = await fetchStopTimes(id).catchError((e) {
            print(e);
            _isNetworkError = true;
            notifyListeners();
          });
          if (_isNetworkError) return;

          BusStop stop = await processStopInfo(
              stopInfo['id'],
              stopInfo['name'],
              stopInfo['lat'],
              stopInfo['lon'],
              stopTimesData,
              nowSeconds,
              _remainingTime
          );
          _stops.add(stop);
        } else {
          //print("Stop $id not found!");
          continue;
        }
      }

      if (_isNetworkError) return;

    } catch (e) {
      _isNetworkError = true;
      notifyListeners();
    }
    _isRequestInProgress = false;
    notifyListeners();
  }

  // Fetches information for favorite bus stops.
  Future<void> getFavoriteStopsInfo(BuildContext context) async {
    //if (_isLoaded) return;

    var now = DateTime.now();
    var nowSeconds = now.hour * 3600 + now.minute * 60 + now.second;
    //var nowSeconds = 64800;
    final favouriteModel = context.read<FavouriteStopsModel>();
    List<String> flId = favouriteModel.favouriteStopsID;

    if (isRequestInProgress) return;
    _isRequestInProgress = true;
    _isNetworkError = false;

    _favoriteStops.clear();
    _favoriteRemainingTime.clear();

    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');

    for(int i = 0 ; i < flId.length; i++){
      try {

        Map<String, dynamic> stopInfo = await fetchDataFromUrl('https://bearkim117.com/otp/routers/default/index/stops/${flId[i]}/token/$token');
        if (stopInfo.isEmpty) {
          //print("No data found for the stop id ${flId[i]}");
          continue;
        }

        List<Map<String, dynamic>> stopTimesData = await fetchStopTimes(flId[i]).catchError((e){
          //print(e);
          _isNetworkError = true;
        });


        if (_isNetworkError) return;

        BusStop stop = await processStopInfo(
            stopInfo['id'],
            stopInfo['name'],
            stopInfo['lat'],
            stopInfo['lon'],
            stopTimesData,
            nowSeconds,
            _favoriteRemainingTime
        );

        _favoriteStops.add(stop);

      } catch(e) {
        print(e);
        _isNetworkError = true;
      }
    }
    _isRequestInProgress = false;
    //_isLoaded = true;
    notifyListeners();
  }

  // Converts seconds to a time string in HH:MM format.
  String convertSecondsToTime(int? totalSeconds) {
    if (totalSeconds == null) {
      return "";
    }

    Duration duration = Duration(seconds: totalSeconds);

    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);

    String time = [
      if(hours < 10) "0$hours" else "$hours",
      if(minutes < 10) "0$minutes" else "$minutes"
    ].join(':');

    return time;
  }

  // Returns a widget displaying the scheduled time for a bus stop.
  Widget getScheduledTimeText(BusStop bstop, double screenWidth){
    BusStop stop = bstop;
    int? remainingBusTime = stop.remaining;
    int remainingHours = remainingBusTime! ~/ 3600;
    int remainingMinutes = (remainingBusTime % 3600) ~/ 60;
    int remainingSeconds = remainingBusTime % 60;
    String arriveTime = convertSecondsToTime(stop.getScheduledArrival);

    String remainingTimeStr = (remainingHours > 0 ? '$remainingHours hour ' : '') +
        (remainingMinutes > 0 ? '$remainingMinutes minute ' : '');

    if ((stop.scheduledArrival == 99999 && stop.scheduledDeparture == 99999) || remainingBusTime == 99999) {
      return Text(
        'No scheduled',
        style: GoogleFonts.getFont(
          'Poppins',
          textStyle: TextStyle(color: Colors.black26, letterSpacing: .5, fontSize: screenWidth * 0.035),
        ),
      );
    }else if (remainingHours == 0 && remainingMinutes == 0) {
      if (remainingSeconds > 10 && remainingSeconds <= 60) {
        return Text(
          'Bus is about to arrive',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: Colors.orange,
              letterSpacing: .5,
              fontSize: screenWidth * 0.035,
            ),
          ),
        );
      } else if (remainingSeconds <= 10) {
        return Text(
          'Now',
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: Colors.green,
              letterSpacing: .5,
              fontSize: screenWidth * 0.035,
            ),
          ),
        );
      }
    } else {
      return RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: remainingTimeStr,
              style: GoogleFonts.roboto(
                textStyle: TextStyle(color: Colors.red, letterSpacing: .5, fontSize: screenWidth * 0.035),
              ),
            ),
            TextSpan(
              text: ' | $arriveTime',
              style: GoogleFonts.roboto(
                textStyle: TextStyle(color: Colors.grey[400], letterSpacing: .5, fontSize: screenWidth * 0.035),
              ),
            ),
          ],
        ),
      );
    }
    return Text("");
  }

  // Selects a bus stop and notifies listeners.
  void selectStop(BusStop stop){
    _selectedStop = stop;
    notifyListeners();
  }

  // Processes information for a single bus stop.
  Future<BusStop> processStopInfo(String id, String name, double lat, double lon, List<Map<String, dynamic>> stopTimesData, int nowSeconds,List<int> remainingTimeList) async {
    int? minScheduledArrival = 99999;
    int? minScheduledDepart = 99999;
    String? headsign = "";
    int? remaining = 99999;
    String remainingStr = "";
    List busTimes = [];
    String busType = "";

    for (final item in stopTimesData) {
      final times = List<Map<String, dynamic>>.from(item['times']);
      for (final time in times) {
        final scheduledArrival = time['scheduledArrival'];
        if (scheduledArrival > nowSeconds) {
          busTimes.add(time);
        }
      }
    }
    //print("List of bus times is $busTimes");

    busTimes.sort((a, b) => a['scheduledArrival'].compareTo(b['scheduledArrival']));

    //print("busTime is $busTimes, nowseconds: $nowSeconds");

    if (busTimes.isNotEmpty) {
      final minScheduledBusData = busTimes.first;
      minScheduledArrival = minScheduledBusData['scheduledArrival'];
      minScheduledDepart = minScheduledBusData['scheduledDeparture'];
      headsign = minScheduledBusData['headsign'];
      remaining = minScheduledArrival! - nowSeconds;
      int remainingHours = remaining ~/ 3600;
      int remainingMinutes = (remaining % 3600) ~/ 60;
      remainingStr = (remainingHours > 0 ? '$remainingHours hour ' : '') +
          (remainingMinutes > 0 ? '$remainingMinutes minute ' : '');
      remainingTimeList.add(remaining);
      busType = minScheduledBusData['tripId'].contains('ut1') ? 'noWheel' : 'Wheel';
    }else{
      remainingTimeList.add(99999);
    }
    //print("processStopInfo is in the function, arrival time of $name is $minScheduledArrival, remaining is $remaining");

    return BusStop(
        name: name,
        id: id,
        lat: lat,
        lon: lon,
        scheduledArrival: minScheduledArrival,
        scheduledDeparture: minScheduledDepart,
        headsign: headsign,
        remaining: remaining,
        remainingStr: remainingStr,
        busType: busType
    );
  }

  // Removes a bus stop from favorites.
  void removeFavoriteStop(BusStop stop) {
    int index = favoriteStops.indexOf(stop);
    if (index != -1) {
      favoriteStops.removeAt(index);
      favoriteRemainingTime.removeAt(index);
      notifyListeners();
    }
  }

  // Adds a new bus stop to the list.
  void add(BusStop stop){
    _stops.add(stop);
    notifyListeners();
  }

  // Removes a bus stop from the list.
  void remove(BusStop stop){
    _stops.remove(stop);
    notifyListeners();
  }

  // Fetches data from a given URL.
  Future<Map<String, dynamic>> fetchDataFromUrl(String url) async {
    try {
      final response = await Dio().get(url);
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception("Failed to fetch data from $url");
      }
    } catch (e) {
      throw Exception("Failed to fetch data from $url: $e");
    }
  }

  // Fetches stop information from an API.
  Future<List<Map<String, dynamic>>> fetchStopInfo() async {
    try {
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'auth_token');
      final response = await Dio().get('https://bearkim117.com/otp/routers/default/index/stops/token/$token/');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        return Future.error("Failed to fetch stop info");
      }
    } catch (e) {
      return Future.error("Failed to fetch stop info: $e");
    }
  }

  // Fetches stop times for a specific bus stop.
  Future<List<Map<String, dynamic>>> fetchStopTimes(String id) async {
    try {
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'auth_token');
      final response = await Dio().get("https://bearkim117.com/otp/routers/default/index/stops/$id/token/$token/stoptimes?timeRange=7200");
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        return Future.error("Failed to fetch stop times for stop $id");
      }
    } catch (e) {
      return Future.error("Failed to fetch stop times for stop $id: $e");
    }
  }
}
