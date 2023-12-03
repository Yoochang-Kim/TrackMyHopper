import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:unihopper_timetable/Pages/HomePage.dart';

import '../Pages/favoritePage.dart';
import '../Pages/mapPage.dart';

enum Pages {
  HomePage,
  FavoritePage,
  MapPage,
}

class BottomNavBar extends StatefulWidget {
  final Function onTabChange;
  final Pages currentPage;
  final int selectedIndex;

  BottomNavBar({required this.onTabChange, required this.currentPage,required this.selectedIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 10,
            activeColor: Colors.black,
            iconSize: 24,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            duration: Duration(milliseconds: 300),
            tabBackgroundColor: Colors.grey[100]!,
            color: Colors.black,
            tabs: [
              GButton(
                icon: LineIcons.bus,
                text: 'Home',
                onPressed: () {
                  if (widget.currentPage != Pages.HomePage) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return HomePage();
                        },
                      ),
                    );
                  }
                },
              ),
              GButton(
                icon: LineIcons.star,
                text: 'Likes',
                onPressed: () {
                  if (widget.currentPage != Pages.FavoritePage) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return FavoritePage();
                        },
                      ),
                    );
                  }
                },
              ),
              GButton(
                icon: LineIcons.mapAlt,
                text: 'Map',
                onPressed: () {
                  if (widget.currentPage != Pages.MapPage) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return const MapPage(selectedLocation: LatLng(-42.87989,147.32472),);
                        },
                      ),
                    );
                  }
                },
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              widget.onTabChange(index);
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}

