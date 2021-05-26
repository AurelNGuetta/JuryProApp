import 'package:flutter/material.dart';
import 'package:learn_flutter/main.dart';
import 'package:splashscreen/splashscreen.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 5,
        navigateAfterSeconds: new MyHomePage(title: 'Jury Pro'),
        title: new Text(
          'JURY PRO',
          style: new TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 50.0,
              color: Colors.deepOrange),
        ),
        image: new Image.asset(
          'images/splash.jpg',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 200.0,
        useLoader: false,
        onClick: () => print("JuryPro splashScreen"));
  }
}
