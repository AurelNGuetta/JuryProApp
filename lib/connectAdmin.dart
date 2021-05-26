import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/jury/Jury.dart';
import 'package:learn_flutter/showJuryEvent.dart';

import 'constant/constant.dart';

Future<Jury> fetchJury(String data) async {
  final response = await http.get('${Constant.ip}/juries/search/$data');

  if (response.statusCode == 200) {
    return Jury.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Echec de la vérification des informations');
  }
}

class ConnectAdminPage extends StatefulWidget {
  int evenement;
  ConnectAdminPage({Key key}) : super(key: key);

  _ConnectAdminPageState createState() => _ConnectAdminPageState();
}

class _ConnectAdminPageState extends State<ConnectAdminPage> {
  bool _isUploading = false;

  final TextEditingController _juryEmailController = TextEditingController();

  Future<Jury> _futureJury;
  Jury currentJury;
  bool _testConnect = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "RESULTATS EVENEMENT",
              style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 60),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                controller: _juryEmailController,
                cursorColor: Color(0xFF373A36),
                maxLines: 1,
                style: TextStyle(color: Colors.blueGrey, fontSize: 25),
                decoration: InputDecoration(
                  hintText: "Email ou Téléphone",
                  contentPadding:
                      EdgeInsets.only(left: 35, top: 20, bottom: 20, right: 15),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0, color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(left: 30, right: 30, top: 60),
                child: FlatButton(
                    onPressed: () {
                      _isUploading = true;
                      setState(() {
                        _futureJury = fetchJury(_juryEmailController.text);
                        _testConnect = true;
                        _futureJury.then((data) {
                          if (data != null) {
                            currentJury = data;
                            Navigator.of(context)
                                .push(_showJuryEvent(currentJury));
                          } else {
                            currentJury = null;
                          }
                        }).catchError((e) {
                          print(e);
                        });
                      });
                    },
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 30, right: 30),
                    minWidth: double.infinity,
                    height: 60,
                    color: Colors.greenAccent,
                    textColor: Colors.white,
                    focusColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        side: BorderSide(color: Colors.grey)),
                    child: Text("continuer".toUpperCase(),
                        style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)))),
            ((currentJury == null) && (_testConnect == true))
                ? Text(
                    "Informations incorrectes !",
                    style: TextStyle(color: Colors.redAccent),
                  )
                : Text("")
          ],
        ),
      ),
    );
  }

  Route _showJuryEvent(jury) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ShowJuryEventPage(jury: jury),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = Offset(0.0, 1.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
