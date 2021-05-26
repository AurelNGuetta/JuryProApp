import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/candidat/addCandidat.dart';
import 'package:learn_flutter/candidat/candidat.dart';
import 'package:learn_flutter/criteres/Criteria.dart';
import 'package:learn_flutter/criteres/addCriteria.dart';
import 'package:learn_flutter/jury/Jury.dart';
import 'package:learn_flutter/jury/addJury.dart';
import 'package:learn_flutter/upEvenent.dart';
import 'package:learn_flutter/vote/showEvenementResult.dart';
import 'package:random_color/random_color.dart';

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

  get length => null;
}

class EvenementDetailPage extends StatefulWidget {
  final int evenement;
  EvenementDetailPage({Key key, @required this.evenement}) : super(key: key);

  _EvenementDetailPageState createState() =>
      _EvenementDetailPageState(evenement);
}

class _EvenementDetailPageState extends State<EvenementDetailPage> {
  int evenement;
  Evenement event;
  bool haveParticipant = false;

  _EvenementDetailPageState(evenement) {
    this.evenement = evenement;
  }

  Future<Evenement> futureEvenement;
  List data;
  List candidats, juries, criteres;
  bool _isLoading = false;
  bool _loadJury = false;
  bool _loadCritere = false;

  Future<Evenement> fetchEvenement() async {
    final response = await http.get('${Constant.ip}/evenements/$evenement');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      setState(() {
        haveParticipant = true;
      });
      return Evenement.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load evenement');
    }
  }

  Future<Candidat> fetchAllCandidats() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.get("${Constant.ip}/candidats/event/$evenement");

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        candidats = json.decode(response.body);
      });
      // return json.decode(response.body);
    } else {
      throw Exception("Erreur de récupération des evenements");
    }
  }

  Future<Jury> fetchAllJury() async {
    setState(() {
      _loadJury = true;
    });
    final response = await http.get("${Constant.ip}/jury/event/$evenement");

    if (response.statusCode == 200) {
      setState(() {
        _loadJury = false;
        juries = json.decode(response.body);
      });
      // return json.decode(response.body);
    } else {
      throw Exception("Erreur de récupération des memebres du Jury");
    }
  }

  Future<Criteria> fetchAllCriteres() async {
    setState(() {
      _loadCritere = true;
    });
    final response = await http.get("${Constant.ip}/criteres/event/$evenement");

    if (response.statusCode == 200) {
      setState(() {
        _loadCritere = false;
        criteres = json.decode(response.body);
      });
      // return json.decode(response.body);
    } else {
      throw Exception("Erreur de récupération des memebres du Jury");
    }
  }

  @override
  void initState() {
    super.initState();
    futureEvenement = fetchEvenement();
    fetchAllCandidats();
    fetchAllJury();
    fetchAllCriteres();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(''),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: "Modifier l'évènement",
              onPressed: () {
                Navigator.of(context).push(_createRoute(event));
              },
            ),
            IconButton(
              icon: const Icon(Icons.supervisor_account_sharp),
              tooltip: "Ajouter candidat",
              onPressed: () {
                Navigator.of(context).push(_createCandidat(evenement));
              },
            ),
            IconButton(
              icon: const Icon(Icons.supervised_user_circle),
              tooltip: "Ajouter jury",
              onPressed: () {
                Navigator.of(context).push(_createJury(evenement));
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "Ajouter Critères",
              onPressed: () {
                Navigator.of(context).push(_createCriteria(evenement));
              },
            ),
            IconButton(
              icon: const Icon(Icons.list),
              tooltip: "Afficher les Résultats",
              onPressed: () {
                Navigator.of(context).push(_showResults(evenement));
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            child: FutureBuilder<Evenement>(
              future: futureEvenement,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  event = snapshot.data;
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.only(bottom: 70),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: ClipRRect(
                            child: Image.memory(
                              Base64Codec()
                                  .decode(snapshot.data.evenement_photo),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Container(height: 30),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(snapshot.data.evenement_nom,
                                style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF7900))),
                          ),
                        ),
                        Container(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Du ${snapshot.data.evenement_date_debut} au ${snapshot.data.evenement_date_fin}",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF170557),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(height: 10),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              snapshot.data.evenement_description,
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xD2747375)),
                            ),
                          ),
                        ),
                        Container(height: 40),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10, bottom: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "LISTE DES CANDIDATS",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF170557),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            (_isLoading)
                                ? Container(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(),
                                          Container(
                                            height: 20,
                                          ),
                                          Text("Chargement des Participants")
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 250,
                                    child: ListView.builder(
                                      itemCount: candidats == null
                                          ? 0
                                          : candidats.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        Uint8List image = null;
                                        if (candidats[index]
                                                ['candidat_photo'] !=
                                            null) {
                                          var blob = candidats[index]
                                              ['candidat_photo'];
                                          image = Base64Codec().decode(blob);
                                        }
                                        return Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                    width: 60,
                                                    height: 60,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(150),
                                                        child: Image.memory(
                                                            image))),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 10,
                                                            top: 5,
                                                            bottom: 5),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${candidats[index]["candidat_nom"]} ${candidats[index]["candidat_prenom"]}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          "${candidats[index]["candidat_email"]}",
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        Text(
                                                          "${candidats[index]["candidat_telephone"]}",
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "MEMBRES DU JURY",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF170557),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            (_loadJury)
                                ? Container(
                                    padding: EdgeInsets.only(top: 50),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(),
                                          Container(
                                            height: 20,
                                          ),
                                          Text("Chargement des membres du Jury")
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 195,
                                    margin:
                                        EdgeInsets.only(top: 30, bottom: 30),
                                    child: ListView.builder(
                                      itemCount:
                                          juries == null ? 0 : juries.length,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        List<String> names = juries[index]
                                                ["jury_nom_complet"]
                                            .split(' ');

                                        Color _color = RandomColor()
                                            .randomColor(
                                                colorBrightness:
                                                    ColorBrightness.veryDark);
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: Colors.white70,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          color: Colors.grey[200],
                                          elevation: 0.3,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, right: 8, top: 10),
                                            child: Column(
                                              children: <Widget>[
                                                ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            150),
                                                    child: Container(
                                                      width: 70,
                                                      height: 70,
                                                      color: _color,
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        "${names[0][0] + names[1][0]}",
                                                        textScaleFactor: 2,
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 10,
                                                            top: 5,
                                                            bottom: 5),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(height: 5),
                                                        Text(
                                                          "${juries[index]["jury_nom_complet"]}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color: Colors
                                                                  .blueGrey),
                                                        ),
                                                        Container(height: 5),
                                                        Text(
                                                          "${juries[index]["email"]}",
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        ),
                                                        Container(height: 5),
                                                        Text(
                                                          "${juries[index]["jury_telephone"]}",
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                          ),
                                                        )
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "CRITERES D'EVALUATION",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFF170557),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: (_loadCritere)
                                  ? Container(
                                      padding: EdgeInsets.only(top: 50),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            CircularProgressIndicator(),
                                            Container(
                                              height: 20,
                                            ),
                                            Text("Chargement des Participants")
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 250,
                                      child: ListView.builder(
                                        itemCount: criteres == null
                                            ? 0
                                            : criteres.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Card(
                                            elevation: 0,
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    "${criteres[index]["critere_libelle"]}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                        fontSize: 20.0),
                                                  ),
                                                  Text(
                                                    "${criteres[index]["critere_bareme"]}pts",
                                                    style: TextStyle(
                                                        fontSize: 22.0,
                                                        color: Colors.red),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // By default, show a loading spinner.
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
              },
            ),
          ),
        ));
  }

  Route _createRoute(Evenement event) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          UpdateEvenementPage(
              null,
              event.evenement_id,
              event.evenement_nom,
              event.evenement_type,
              event.evenement_description,
              event.evenement_date_debut,
              event.evenement_date_fin,
              event.evenement_photo),
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

  Route _createCandidat(int evenement) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddCandidatPage(
        evenement: evenement,
      ),
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

  Route _createJury(int evenement) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => AddJuryPage(
        evenement: evenement,
      ),
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

  Route _showResults(int evenement) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ShowEvenementResultPage(
        evenement: evenement,
      ),
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

  Route _createCriteria(int evenement) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          AddCriteriaPage(evenement: evenement),
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
