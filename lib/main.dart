import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:unihopper_timetable/Pages/HomePage.dart';
import 'package:unihopper_timetable/Pages/loginPage.dart';
import 'Model/AuthService.dart';
import 'Model/busStopModel.dart';
import 'Model/favoriteStopModel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Pages/adminPage.dart';
import 'Pages/favoritePage.dart';
import 'Pages/mapPage.dart';


Future<void> main() async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) {
    runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => FavouriteStopsModel(),
            ),
            ChangeNotifierProvider(
              create: (context) => BusStopModel(),
            ),
            ChangeNotifierProvider(
              create: (context) => AuthService(),
            ),
          ],
          child: const MyApp(),
        )
    );
  });
}

Future initialization(BuildContext? context) async {
  await Future.delayed(Duration(seconds: 3));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context);
    authService.updateIsAdmin();
    FirebaseInAppMessaging.instance.triggerEvent('your_event_name');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: Colors.white),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: authService.firebaseAuthInstance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // 로그인된 유저가 있음
            if (snapshot.data != null && snapshot.data!.emailVerified) {
              return MainPage();
            }
            // 로그인된 유저가 없음 (로그아웃 또는 계정이 삭제/중지됨)
            else {
              return LoginPage();
            }
          }
          // 로그인 상태가 아직 결정되지 않음
          else {
            return LoginPage();
          }
        },
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2;
  LatLng? _selectedLatLng;

  void onTileClicked(LatLng latLng) {
    setState(() {
      _selectedLatLng = latLng;
      _selectedIndex = 2; // Move to the map page
    });
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Provider.of<AuthService>(context);
    authService.updateIsAdmin();
    bool isAdmin = authService.isAdmin;
    //print("IsAdmin = $isAdmin");
    return Consumer<AuthService>(
      builder: (context, authService, child){
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: <Widget>[
              HomePage(onTileClicked: onTileClicked),
              FavoritePage(onTileClicked: onTileClicked),
              MapPage(selectedLocation: _selectedLatLng ?? const LatLng(-42.8791674, 147.3239583)),
               if (isAdmin) const AdminPage(),
              AdminPage(),
            ],
          ),
          bottomNavigationBar: Container(
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
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  duration: Duration(milliseconds: 300),
                  tabBackgroundColor: Colors.grey[100]!,
                  color: Colors.black,
                  tabs: [
                    const GButton(
                      icon: LineIcons.home,
                      text: 'Home',
                    ),
                    const GButton(
                      icon: LineIcons.star,
                      text: 'Likes',
                    ),
                    const GButton(
                      icon: LineIcons.map,
                      text: 'Map',
                    ),
                     if (isAdmin)
                      const GButton(
                        icon: LineIcons.alternateList,
                        text: "admin",
                      ),
                  ],
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    if (_selectedIndex != index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}






