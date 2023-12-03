import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Objects/busStop.dart';

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