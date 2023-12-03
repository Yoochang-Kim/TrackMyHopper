import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_icons/line_icon.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:unihopper_timetable/Model/busStopModel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Animation/rotation.dart';
import '../Model/AuthService.dart';
import '../Model/favoriteStopModel.dart';
import '../Objects/busStop.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'loginPage.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<LatLng>? onTileClicked;
  const HomePage({Key? key,this.onTileClicked}) : super(key: key);

  @override
  State<HomePage> createState() =>  _HomePageState();
}

class  _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _advancedDrawerController = AdvancedDrawerController();
  late RotationAnimation rotationAnimation;
  bool isStarred = false;

  @override
  void initState() {
    super.initState();
    rotationAnimation = RotationAnimation(this);
    Provider.of<FavouriteStopsModel>(context, listen: false).loadFavourites();
    context.read<BusStopModel>().getBusStopInfo();
  }
  @override
  void dispose() {
    rotationAnimation.rotationController.dispose();
    super.dispose();
  }
  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  @override
  Widget build(BuildContext context) {
    rotationAnimation.rotationController.repeat();
    if(Provider.of<AuthService>(context, listen: false).user == null){
      Provider.of<AuthService>(context, listen: false).signOut();
    }
    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/bg-1.png',
          fit: BoxFit.cover,
        ),
      ),
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      controller: _advancedDrawerController,
      drawer: SafeArea(
        child: Center(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Padding(  // add this
              padding: const EdgeInsets.symmetric(vertical: 60.0),  // adjust as needed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,  // change this
                children: [
                  Spacer(),
                  ListTile(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Theme(
                                data: ThemeData(dialogBackgroundColor: Colors.white),
                                child: AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: const Text('Account Deletion',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),),
                                  content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text(
                                        'No',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text(
                                        'Yes',
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      onPressed: () async {
                                        // close the current dialog
                                        String? result = await Provider.of<AuthService>(context, listen: false).deleteUser();
                                        if (result == 'relogin') {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Please log out and log back in to delete your account.",style: TextStyle(fontSize: 18),),
                                            ),
                                          );
                                        } else if (result == 'Success') {
                                          Navigator.of(context).pop();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text("Your account has been deleted. We're sorry to see you go.",style: TextStyle(color: Colors.red,fontSize: 18),),
                                            ),
                                          );
                                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(result!,style: const TextStyle(color: Colors.red,fontSize: 18),),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                            );
                          },
                        );},
                      leading: LineIcon.trash(color: Colors.red,),
                      title: const Text(
                        'Delete Account',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ListTile(
                    onTap: () async {
                      final url = Uri.parse('https://bearkim117.com/faq');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    leading: LineIcon.questionCircle(),
                    title: const Text('FAQ'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () {
                        showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Theme(
                              data: ThemeData(dialogBackgroundColor: Colors.white),
                              child: AlertDialog(
                                backgroundColor: Colors.white,
                                title: const Text('Log out', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                content: const Text('Are you sure you want to log out?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text(
                                      'No',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Yes',
                                      style: TextStyle(color: Colors.green),
                                    ),
                                    onPressed: () async {
                                      String result = await Provider.of<AuthService>(context, listen: false).signOut();
                                      if(result == 'Success'){
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Successfully Log out",style: TextStyle(color: Colors.green,fontSize: 20),),
                                          ),
                                        );
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                                      }else{
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result,style: TextStyle(color: Colors.red,fontSize: 20),),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                          );
                        },
                      );},
                      leading: const Icon(Icons.logout_outlined),
                      title: const Text('Log out'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Center(
            child: LineIcon.bus(),
          ),
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Icons.clear : Icons.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () async {
                const url = 'https://online.flippingbook.com/view/905153252/';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: Hero(
                tag: 'showTimeSchedule',
                child: Image.asset('assets/t-2023-7-2.png'),
              ),
            ),
          ],
        ),
        body: Consumer<BusStopModel>(
            builder: (context, busStopModel, child){
              if (busStopModel.isNetworkError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('A network error occurred. Please try again.'),
                      TextButton(
                        onPressed: () => busStopModel.getBusStopInfo(),
                        style: TextButton.styleFrom(backgroundColor: Colors.blueAccent),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Stack(
                  children: <Widget> [
                    ListView.builder(
                      itemCount: busStopModel.stops.length,
                      itemBuilder: (BuildContext context, int index) {

                        double screenWidth = MediaQuery.of(context).size.width;
                        Widget? subtitleWidget;
                        //print("리스트 뷰 만드는중");
                        BusStop stop = busStopModel.stops[index];
                        subtitleWidget = busStopModel.getScheduledTimeText(stop, screenWidth);
                        //print("버스 이름: ${stop.name}의 버스타입은 ${stop.busType}이고 bus remaining은 ${stop.remaining}");

                        return InkWell(
                          highlightColor: Colors.red,
                          splashColor: const Color(0xFFFF6600),
                          splashFactory: InkRipple.splashFactory,
                          onTap: (){
                            LatLng selectedLocation = LatLng(busStopModel.stops[index].lat, busStopModel.stops[index].lon);
                            if (widget.onTileClicked != null) {
                              widget.onTileClicked!(selectedLocation);
                            }
                            //print(busStopModel.stops[index]);
                          },
                          child: Consumer<FavouriteStopsModel>(
                              builder: (context, favourites, child) {

                                return TimelineTile(
                                  alignment: TimelineAlign.manual,
                                  lineXY: 0.2,
                                  isFirst: index == 0,
                                  isLast: index == busStopModel.stops.length - 1,
                                  beforeLineStyle:  const LineStyle(
                                    color: Color(0xFF609966),
                                    thickness: 3.5,
                                  ),
                                  afterLineStyle:  const LineStyle(
                                    color: Color(0xFF609966),
                                    thickness: 3.5,
                                  ),
                                  indicatorStyle: IndicatorStyle(
                                    padding: const EdgeInsets.only(bottom: 0.1),
                                    width: 20,
                                    indicator: busStopModel.stops[index].remaining! < 300
                                        ? (busStopModel.stops[index].busType == 'Wheel' || busStopModel.stops[index].busType == 'noWheel'
                                        ? InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Theme(
                                                data: ThemeData(dialogBackgroundColor: Colors.white),
                                                child: AlertDialog(
                                                  title: const Text(
                                                    'Information',
                                                    style: TextStyle(fontWeight: FontWeight.bold), // Bold style
                                                  ),

                                                  backgroundColor: Colors.white,
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Row( // Row widget
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/yes-wheel.svg',
                                                            width: screenWidth * 0.06,
                                                          ),
                                                          SizedBox(width: 10), // Optional: To provide some spacing between the SVG and the text
                                                          Expanded(
                                                            child: Text('wheelchair available'.toUpperCase()),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 20.0),
                                                      Row( // Row widget
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/no-wh.svg',
                                                            width: screenWidth * 0.06,
                                                          ),
                                                          SizedBox(width: 10), // Optional: To provide some spacing between the SVG and the text
                                                          Expanded(
                                                            child: Text('wheelchair not available'.toUpperCase()),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text(
                                                        'Close',
                                                        style: TextStyle(color: Colors.red),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                            );
                                          },
                                        );
                                      },
                                      child: Image.asset(
                                        busStopModel.stops[index].busType == 'Wheel'
                                            ? 'assets/yes-wh.png'
                                            : 'assets/no-wh.png',
                                      ),
                                    )
                                        : Image.asset('assets/p2.png'))
                                        : Image.asset('assets/p2.png'),
                                  ),
                                  startChild: Padding(
                                    padding: const EdgeInsets.only(left: 3.0),
                                    child: Row(
                                      children: [
                                        if(stop.getName == 'Medical Science Precinct' ||
                                            stop.getName == 'Magnet Court' || stop.getName == "St David's Park")
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Theme(
                                                      data: ThemeData(dialogBackgroundColor: Colors.white),
                                                      child: AlertDialog(
                                                        title: const Text(
                                                          'Information',
                                                          style: TextStyle(fontWeight: FontWeight.bold), // Bold style
                                                        ),
                                                        backgroundColor: Colors.white,
                                                        content: Row( // Row widget
                                                          children: [
                                                            SvgPicture.asset(
                                                              'assets/no-wheel.svg',
                                                              width: screenWidth * 0.06,
                                                            ),
                                                            SizedBox(width: 10), // Optional: To provide some spacing between the SVG and the text
                                                            Expanded(
                                                              child: Text('Drop off/pick up not available'.toUpperCase()),
                                                            ),
                                                          ],
                                                        ),
                                                        actions: <Widget>[
                                                          TextButton(
                                                            child: const Text(
                                                              'Close',
                                                              style: TextStyle(color: Colors.red),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                  );
                                                },
                                              );
                                            },
                                            child: SvgPicture.asset(
                                              'assets/no-wheel.svg',
                                              width: screenWidth * 0.06,
                                            ),
                                          ),
                                        if(stop.getName == "St David's Park")
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Theme(
                                                    data: ThemeData(dialogBackgroundColor: Colors.white),
                                                    child: AlertDialog(
                                                      title: const Text(
                                                        'Information',
                                                        style: TextStyle(fontWeight: FontWeight.bold), // Bold style
                                                      ),
                                                      backgroundColor: Colors.white,
                                                      content: Row( // Row widget
                                                        children: [
                                                          SvgPicture.asset(
                                                            'assets/no-get-in.svg',
                                                            width: screenWidth * 0.08,
                                                          ),
                                                          const SizedBox(width: 10), // Optional: To provide some spacing between the SVG and the text
                                                          const Expanded(
                                                            child: Text('DROP OFF ONLY'),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: const Text(
                                                            'Close',
                                                            style: TextStyle(color: Colors.red),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: SvgPicture.asset(
                                              'assets/no-get-in.svg',
                                              width: screenWidth * 0.08,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  endChild: Padding(
                                      padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 10.0),
                                                        child: Text(
                                                            stop.getName,
                                                            style: GoogleFonts.getFont(
                                                                'Poppins',
                                                                textStyle:  TextStyle(
                                                                    fontSize: screenWidth * 0.04,
                                                                    fontWeight: FontWeight.w600
                                                                )
                                                            )
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 10.0),
                                                        child: subtitleWidget,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          favourites.isFavourite(stop)
                                                              ? Icons.star
                                                              : Icons.star_border,
                                                          color: favourites.isFavourite(stop) ? Colors.yellow : null,
                                                        ),
                                                        iconSize: screenWidth * 0.06,
                                                        onPressed: () {
                                                          if (favourites.isFavourite(stop)) {
                                                            favourites.removeStop(stop);
                                                          } else {
                                                            favourites.addStop(stop);
                                                          }
                                                          favourites.printStops();
                                                          //print("현재 리스트 안의 stop id 개수는 ${favourites.getNumberOfStops()}");
                                                        },
                                                      ),
                                                    ]
                                                )
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: Divider(
                                              color: Colors.grey[200],
                                              thickness: 0.5,
                                              height: 0.2,
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                );
                              }
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 30.0,
                      bottom: 50.0,
                      child: FloatingActionButton(
                        heroTag: "HomeFreshBotton",
                        onPressed: busStopModel.isRequestInProgress ? null : () {
                          rotationAnimation.rotationController.repeat();
                          busStopModel.getBusStopInfo().then((_){
                            rotationAnimation.rotationController.stop();
                          });
                        },
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        child: busStopModel.isRequestInProgress
                            ? const SizedBox(
                            width: 24,  // Adjust width as needed
                            height: 24, // Adjust height as needed
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
                      ),
                    )
                  ],
                );
              }
            }
        ),
      ),
    );
      
  }
}

