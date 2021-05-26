import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/constant/constant.dart';
import 'package:learn_flutter/criteres/Criteria.dart';
import 'package:learn_flutter/evenementDetail.dart';

Future<Criteria> createCriteria(
    int critere_bareme, String critere_libelle, int evenement) async {
  final http.Response response = await http.post(
    '${Constant.ip}/criteres',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'critere_bareme': critere_bareme,
      'critere_libelle': critere_libelle,
      'evenement_id': evenement
    }),
  );

  if (response.statusCode == 200) {
    return Criteria.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Echec de la création du critères');
  }
}

Widget FadeAlertAnimation(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return Align(
    child: FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}

class AddCriteriaPage extends StatefulWidget {
  int evenement;
  AddCriteriaPage({Key key, this.evenement}) : super(key: key);

  _AddCriteriaPageState createState() => _AddCriteriaPageState(evenement);
}

class _AddCriteriaPageState extends State<AddCriteriaPage> {
  int evenement;

  bool _isUploading = false;

  final TextEditingController _critereBaremeController =
      TextEditingController();
  final TextEditingController _critereLabelController = TextEditingController();

  Future<Criteria> _futureCriteria;

  _AddCriteriaPageState(int evenement) {
    this.evenement = evenement;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.lightBlue,
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
                color: Colors.lightBlue,
              ),
              child: Column(
                children: [
                  Container(
                    child: Center(
                      child: Column(children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Ajouter un Critère",
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
                    const SizedBox(height: 50),
                    TextField(
                        controller: _critereLabelController,
                        cursorColor: Color(0xFF373A36),
                        style: TextStyle(color: Color(0xFFFE8556)),
                        decoration: InputDecoration(
                            labelText: "Libelle du critère",
                            contentPadding: EdgeInsets.all(18),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 0, color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))))),
                    const SizedBox(height: 45),
                    TextField(
                        controller: _critereBaremeController,
                        cursorColor: Color(0xFF373A36),
                        style: TextStyle(color: Color(0xFFFE8556)),
                        decoration: InputDecoration(
                            labelText: "Barême de notation",
                            contentPadding: EdgeInsets.all(18),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(width: 0, color: Colors.white),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))))),
                    const SizedBox(height: 45),
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
                            backgroundColor: Colors.lightBlue,
                            onSurface: Colors.grey,
                            padding: EdgeInsets.only(
                                top: 15, left: 0, right: 0, bottom: 15)),
                        onPressed: () {
                          _isUploading = true;
                          setState(() {
                            _futureCriteria = createCriteria(
                                int.parse(_critereBaremeController.text),
                                _critereLabelController.text,
                                evenement);
                          });
                          _isUploading = false;
                          Navigator.of(context).pop(context);
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
