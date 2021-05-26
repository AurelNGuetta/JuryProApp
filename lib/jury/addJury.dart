import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/constant/constant.dart';
import 'package:learn_flutter/evenementDetail.dart';
import 'package:learn_flutter/jury/Jury.dart';

Future<Jury> createJury(String jury_nom_complet, String jury_telephone,
    String email, int code, int evenement_id) async {
  final http.Response response = await http.post(
    '${Constant.ip}/juries',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'jury_nom_complet': jury_nom_complet,
      'jury_telephone': jury_telephone,
      'email': email,
      'code': code,
      'evenement_id': evenement_id
    }),
  );

  if (response.statusCode == 200) {
    return Jury.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Echec de la création du candidat');
  }
}

class AddJuryPage extends StatefulWidget {
  int evenement;
  AddJuryPage({Key key, this.evenement}) : super(key: key);

  _AddJuryPageState createState() => _AddJuryPageState(evenement);
}

class _AddJuryPageState extends State<AddJuryPage> {
  int evenement;

  String status = '';
  bool _isUploading;

  final TextEditingController _juryNameController = TextEditingController();
  final TextEditingController _juryEmailController = TextEditingController();
  final TextEditingController _juryCodeController = TextEditingController();
  final TextEditingController _juryPhoneController = TextEditingController();

  Future<Jury> _futureJury;

  _AddJuryPageState(int evenement) {
    this.evenement = evenement;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.blueGrey,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(MediaQuery.of(context).size.width / 9),
                    bottomRight:
                        Radius.circular(MediaQuery.of(context).size.width / 9)),
                color: Colors.blueGrey,
              ),
              child: Column(
                children: [
                  Container(
                    child: Center(
                      child: Column(children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Ajouter un Jury",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                color: Colors.white,
                width: double.infinity,
                height: MediaQuery.of(context).size.height -
                    (MediaQuery.of(context).size.height / 3),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(children: <Widget>[
                    const SizedBox(height: 5),
                    TextField(
                        controller: _juryNameController,
                        cursorColor: Color(0xFF373A36),
                        style: TextStyle(color: Colors.blueGrey),
                        decoration: InputDecoration(
                            labelText: "Nom Complet",
                            contentPadding: EdgeInsets.all(18),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 0, color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))))),
                    const SizedBox(height: 25),
                    TextField(
                        controller: _juryEmailController,
                        cursorColor: Color(0xFF373A36),
                        style: TextStyle(color: Colors.blueGrey),
                        decoration: InputDecoration(
                            labelText: "Email",
                            contentPadding: EdgeInsets.all(18),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 0, color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))))),
                    const SizedBox(height: 25),
                    TextField(
                        controller: _juryCodeController,
                        cursorColor: Colors.blueGrey,
                        style: TextStyle(color: Colors.blueGrey),
                        decoration: InputDecoration(
                            labelText: "Jury Code",
                            contentPadding: EdgeInsets.all(18),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 0, color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))))),
                    const SizedBox(height: 25),
                    TextField(
                        controller: _juryPhoneController,
                        cursorColor: Color(0xFF373A36),
                        style: TextStyle(color: Colors.blueGrey),
                        decoration: InputDecoration(
                            labelText: "Numéro de téléphone",
                            contentPadding: EdgeInsets.all(18),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 0, color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))))),
                    const SizedBox(height: 25),
                    ButtonTheme(
                      child: TextButton(
                        child: Container(
                          child: Text(
                            'Ajouter',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                          width: double.infinity,
                        ),
                        style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.blueGrey,
                            onSurface: Colors.grey,
                            padding: EdgeInsets.only(
                                top: 15, left: 0, right: 0, bottom: 15)),
                        onPressed: () {
                          _isUploading = true;
                          setState(() {
                            _futureJury = createJury(
                                _juryNameController.text,
                                _juryPhoneController.text,
                                _juryEmailController.text,
                                int.parse(_juryCodeController.text),
                                evenement);
                          });
                          _isUploading = false;
                          if (_isUploading) {
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: Center(
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            );
                          } else {
                            Navigator.pop(context, () {
                              setState(() {});
                            });
                          }
                        },
                      ),
                    )
                  ]),
                )),
          ],
        ),
      ),
    );
  }

  Route _evenementDetail(int evenement) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          EvenementDetailPage(evenement: evenement),
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
