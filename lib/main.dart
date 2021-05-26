import 'dart:ui';
import 'package:flutter_gradients/flutter_gradients.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:learn_flutter/animated_bottom_navigation_bar.dart';

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:learn_flutter/evenementDetail.dart';
import 'package:learn_flutter/groupe/groupeEvenementDetail.dart';
import 'package:learn_flutter/jury/connectJury.dart';
import 'package:learn_flutter/splash.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'addEvent.dart';
import 'constant/constant.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jury Pro',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Splash(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final autoSizeGroup = AutoSizeGroup();
  var _bottomNavIndex = 0; //default index of first screen

  AnimationController _animationController;
  Animation<double> animation;
  CurvedAnimation curve;

  final iconList = <IconData>[
    Icons.event,
    Icons.person,
    Icons.group,
    Icons.supervised_user_circle_rounded,
  ];
  final menuList = <String>["Evènements", "Candidat", "Résultats", "Votes"];

  List data;
  List evenements;
  bool _isLoading = false;

  Future<List> getAllEvenements() async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.get("${Constant.ip}/evenements");

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        data = json.decode(response.body);
      });
      // return json.decode(response.body);
    } else {
      throw Exception("Erreur de récupération des evenements");
    }
  }

  @override
  void initState() {
    super.initState();
    final systemTheme = SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: HexColor('#373A36'),
      systemNavigationBarIconBrightness: Brightness.light,
    );
    SystemChrome.setSystemUIOverlayStyle(systemTheme);

    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    curve = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.5,
        1.0,
        curve: Curves.fastOutSlowIn,
      ),
    );
    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(curve);

    getAllEvenements();

    Future.delayed(
      Duration(seconds: 1),
      () => _animationController.forward(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // drawer: Drawer(
      //   child: ListView(padding: EdgeInsets.zero, children: <Widget>[
      //     DrawerHeader(
      //       child: Text(
      //         'Menu Jury Pro',
      //         style: TextStyle(
      //             fontSize: 25,
      //             fontWeight: FontWeight.bold,
      //             color: Colors.white),
      //       ),
      //       decoration: BoxDecoration(
      //           shape: BoxShape.rectangle,
      //           gradient: FlutterGradient.angelCare()),
      //     ),
      //     ListTile(
      //       leading: Icon(Icons.event),
      //       title:
      //           Text('Evenements', style: TextStyle(color: Colors.deepOrange)),
      //       onTap: () {
      //         // Update the state of the app.
      //         // ...
      //       },
      //     ),
      //     ListTile(
      //       leading: Icon(Icons.person_rounded),
      //       title:
      //           Text('Candidats', style: TextStyle(color: Colors.deepOrange)),
      //       onTap: () {
      //         // Update the state of the app.
      //         // ...
      //       },
      //     ),
      //     ListTile(
      //       leading: Icon(Icons.supervised_user_circle),
      //       title: Text('Groupes', style: TextStyle(color: Colors.deepOrange)),
      //       onTap: () {
      //         // Update the state of the app.
      //         // ...
      //       },
      //     ),
      //   ]),
      // ),
      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                gradient: FlutterGradient.orangeJuice()),
          )),
      body: _isLoading
          ? Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Container(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  gradient: FlutterGradient.cloudyApple()),
              child: ListView.builder(
                  padding: EdgeInsets.all(20),
                  itemCount: data == null ? 0 : data.length,
                  itemBuilder: (BuildContext context, int index) {
                    Uint8List image = null;
                    if (data[index]['evenement_photo'] != null) {
                      var blob = data[index]['evenement_photo'];
                      image = Base64Codec().decode(blob);
                    }
                    // print(Base64Codec().decode(data[index]["evenement_photo"]));
                    String participantLabel = (data[index]["participant"] > 1
                        ? 'inscrits'
                        : 'inscrit');
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: (data[index]['evenement_photo'] != null)
                                  ? Image.memory(image)
                                  : Image.network(
                                      "https://images.pexels.com/photos/1805895/pexels-photo-1805895.jpeg?cs=srgb&dl=pexels-wendy-wei-1805895.jpg&fm=jpg"),
                            ),
                            Container(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("${data[index]["evenement_nom"]}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF29137C))),
                            ),
                            Container(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Du ${data[index]["evenement_date_debut"]} au ${data[index]["evenement_date_fin"]}",
                                style: TextStyle(
                                    fontSize: 18, color: Color(0xD22A137C)),
                              ),
                            ),
                            Container(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    "${data[index]["participant"]} ${participantLabel}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF29137C))),
                                FlatButton(
                                  textColor: Color(0xFF29137C),
                                  disabledColor: Colors.grey,
                                  disabledTextColor: Colors.black,
                                  padding: EdgeInsets.all(8.0),
                                  splashColor: Color(0xFF503C97),
                                  child: Text("Infos"),
                                  color: Color(0xFFF4F2FF),
                                  onPressed: () {
                                    Navigator.of(context).push(_createRoute(
                                        data[index]["evenement_id"],
                                        data[index]["evenement_type"]));
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
      floatingActionButton: ScaleTransition(
        scale: animation,
        child: FloatingActionButton(
          elevation: 10,
          backgroundColor: HexColor('#FE8556'),
          child: Icon(
            Icons.add,
            color: HexColor('#373A36'),
          ),
          onPressed: () {
            _animationController.reset();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEvenementPage(),
              ),
            );
            _animationController.forward();
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          final color = isActive ? HexColor('#FE8556') : Colors.white;
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconList[index],
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AutoSizeText(
                  menuList[index],
                  maxLines: 1,
                  style: TextStyle(color: color),
                  group: autoSizeGroup,
                ),
              )
            ],
          );
        },
        backgroundColor: HexColor('#373A36'),
        activeIndex: _bottomNavIndex,
        splashColor: HexColor('#FE8556'),
        notchAndCornersAnimation: animation,
        splashSpeedInMilliseconds: 300,
        notchSmoothness: NotchSmoothness.defaultEdge,
        gapLocation: GapLocation.center,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 3) {
            Navigator.of(context).push(_connectJury());
          }
        },
      ),
    );
  }
}

// final menu = <String>["Evènements", "Candidat", "Résultats", "votes"];
Route _createRoute(int evenement, String evenement_type) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      if (evenement_type == "GROUPE") {
        return GroupeEvenementDetailPage(evenement: evenement);
      } else {
        return EvenementDetailPage(evenement: evenement);
      }
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Route _connectJury() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ConnectJuryPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
