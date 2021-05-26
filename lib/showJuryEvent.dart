import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/jury/Jury.dart';
import 'package:learn_flutter/jury/showJuryOneEvent.dart';
import 'package:learn_flutter/main.dart';

import 'constant/constant.dart';

class Evenement {
  final int evenement_id;
  final String evenement_nom;
  final String evenement_description;
  final String evenement_photo;
  final String evenement_type;
  final String evenement_date_debut;
  final String evenement_date_fin;

  Evenement(
      {this.evenement_description,
      this.evenement_photo,
      this.evenement_type,
      this.evenement_id,
      this.evenement_nom,
      this.evenement_date_debut,
      this.evenement_date_fin});

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
        evenement_id: json['evenement_id'],
        evenement_nom: json['evenement_nom'],
        evenement_type: json['evenement_type'],
        evenement_photo: json['evenement_photo'],
        evenement_description: json['evenement_description'],
        evenement_date_debut: json['evenement_date_debut'],
        evenement_date_fin: json['evenement_date_fin']);
  }
  @override
  String toString() {
    return 'Evenement(evenement_id: $evenement_id, evenement_nom: $evenement_nom, evenement_description: $evenement_description, evenement_photo: $evenement_photo, evenement_type: $evenement_type, evenement_date_debut: $evenement_date_debut, evenement_date_fin: $evenement_date_fin)';
  }

  get length => null;
}

class ShowJuryEventPage extends StatefulWidget {
  final Jury jury;
  ShowJuryEventPage({Key key, @required this.jury}) : super(key: key);

  _ShowJuryEventPageState createState() => _ShowJuryEventPageState(jury);
}

class _ShowJuryEventPageState extends State<ShowJuryEventPage> {
  Jury jury;
  bool haveParticipant = false;

  _ShowJuryEventPageState(jury) {
    this.jury = jury;
  }

  List data;
  List evenements;
  bool _isLoading = false;

  Future<Evenement> fetchJuryAllEvent() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.get("${Constant.ip}/evenements/jury/${jury.jury_telephone}");

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        evenements = json.decode(response.body);
      });
      // return json.decode(response.body);
    } else {
      throw Exception("Erreur de récupération des evenements");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchJuryAllEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Mes Evènements'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              tooltip: "Déconnexion",
              onPressed: () {
                Navigator.of(context).pop(MyHomePage());
              },
            ),
          ],
        ),
        body: Center(
          child: _isLoading
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
                  child: ListView.builder(
                      padding: EdgeInsets.all(20),
                      itemCount: evenements == null ? 0 : evenements.length,
                      itemBuilder: (BuildContext context, int index) {
                        Uint8List image = null;
                        if (evenements[index]['evenement_photo'] != null) {
                          var blob = evenements[index]['evenement_photo'];
                          image = Base64Codec().decode(blob);
                        }
                        // print(Base64Codec().decode(data[index]["evenement_photo"]));

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: (evenements[index]
                                              ['evenement_photo'] !=
                                          null)
                                      ? Image.memory(image)
                                      : Image.network(
                                          "https://images.pexels.com/photos/1805895/pexels-photo-1805895.jpeg?cs=srgb&dl=pexels-wendy-wei-1805895.jpg&fm=jpg"),
                                ),
                                Container(height: 10),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      "${evenements[index]["evenement_nom"]}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF29137C))),
                                ),
                                Container(height: 20),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Du ${evenements[index]["evenement_date_debut"]} au ${evenements[index]["evenement_date_fin"]}",
                                    style: TextStyle(
                                        fontSize: 18, color: Color(0xD22A137C)),
                                  ),
                                ),
                                Container(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FlatButton(
                                      textColor: Color(0xFF29137C),
                                      disabledColor: Colors.grey,
                                      disabledTextColor: Colors.black,
                                      padding: EdgeInsets.all(8.0),
                                      splashColor: Color(0xFF503C97),
                                      child: Text("Examiner"),
                                      color: Color(0xFFF4F2FF),
                                      onPressed: () {
                                        jury.jury_id =
                                            evenements[index]["jury_id"];
                                        Navigator.of(context).push(
                                            _showJuryEvent(
                                                jury,
                                                evenements[index]
                                                    ["evenement_id"]));
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
        ));
  }

  Route _showJuryEvent(Jury jury, int evenement) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ShowJuryOneEventPage(jury: jury, evenement: evenement),
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
