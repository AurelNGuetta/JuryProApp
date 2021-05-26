import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/candidat/candidat.dart';
import 'package:learn_flutter/constant/constant.dart';
import 'package:learn_flutter/groupe/groupe.dart';

class Evenement {
  final int evenement_id;
  final String evenement_nom;
  final String evenement_description;
  final String evenement_photo;
  final String evenement_type;
  final String evenement_date_debut;
  final String evenement_date_fin;
  final int bareme;

  Evenement(
      {this.evenement_description,
      this.evenement_photo,
      this.evenement_type,
      this.evenement_id,
      this.evenement_nom,
      this.evenement_date_debut,
      this.evenement_date_fin,
      this.bareme});

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
        evenement_id: json['evenement_id'],
        evenement_nom: json['evenement_nom'],
        evenement_type: json['evenement_type'],
        evenement_photo: json['evenement_photo'],
        evenement_description: json['evenement_description'],
        evenement_date_debut: json['evenement_date_debut'],
        evenement_date_fin: json['evenement_date_fin'],
        bareme: json['bareme']);
  }

  get length => null;
}

class ShowEvenementResultPage extends StatefulWidget {
  final int evenement;
  ShowEvenementResultPage({Key key, @required this.evenement})
      : super(key: key);

  _ShowEvenementResultPageState createState() =>
      _ShowEvenementResultPageState(evenement);
}

class _ShowEvenementResultPageState extends State<ShowEvenementResultPage> {
  int evenement;
  Evenement event;
  bool haveParticipant = false;

  _ShowEvenementResultPageState(evenement) {
    this.evenement = evenement;
  }

  Future<Evenement> futureEvenement;
  List data;
  List candidats, groupes;
  bool _isLoading = false;

  Future<Evenement> fetchEvenement() async {
    final response = await http.get('${Constant.ip}/evenements/b/$evenement');

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
      throw Exception('Echec du chargement de l\'évènement');
    }
  }

  Future<Candidat> fetchCandidatsResults() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.get("${Constant.ip}/candidats/results/$evenement");

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        candidats = json.decode(response.body);
      });
      // return json.decode(response.body);
    } else {
      throw Exception("Erreur de récupération des candidats");
    }
  }

  Future<Groupe> fetchGroupesResults() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.get("${Constant.ip}/groupes/results/$evenement");

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        groupes = json.decode(response.body);
      });
      // return json.decode(response.body);
    } else {
      throw Exception("Erreur de récupération des informations du groupe");
    }
  }

  @override
  void initState() {
    super.initState();
    futureEvenement = fetchEvenement();
    futureEvenement.then((evenement) {
      if (evenement.evenement_type == "GROUPE") {
        fetchGroupesResults();
      } else {
        fetchCandidatsResults();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(''),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: FutureBuilder<Evenement>(
            future: futureEvenement,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(snapshot.data.evenement_nom,
                                style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF011735))),
                          ),
                        ),
                        Container(height: 40),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "RÉSULTATS",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Color(0xFFFF7900),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(height: 20),
                            (_isLoading)
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
                                : (snapshot.data.evenement_type == "GROUPE")
                                    ? Container(
                                        height: 560,
                                        child: ListView.builder(
                                          itemCount: groupes == null
                                              ? 0
                                              : groupes.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            Uint8List image = null;
                                            if (groupes[index]
                                                    ['groupe_photo'] !=
                                                null) {
                                              image = Base64Codec().decode(
                                                  groupes[index]
                                                      ['groupe_photo']);
                                            }
                                            return Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                        width: 60,
                                                        height: 60,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        150),
                                                            child: Image.memory(
                                                                image))),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10.0,
                                                                right: 10,
                                                                top: 5,
                                                                bottom: 5),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${groupes[index]["groupe_nom"]}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        )),
                                                    Container(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Text(
                                                        '${groupes[index]["total"]} / ${snapshot.data.bareme}',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors
                                                                .blueGrey),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(
                                        height: 560,
                                        child: ListView.builder(
                                          itemCount: candidats == null
                                              ? 0
                                              : candidats.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            Uint8List image = null;
                                            if (candidats[index]
                                                    ['candidat_photo'] !=
                                                null) {
                                              var blob = candidats[index]
                                                  ['candidat_photo'];
                                              image =
                                                  Base64Codec().decode(blob);
                                            }
                                            return Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                        width: 60,
                                                        height: 60,
                                                        child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        150),
                                                            child: Image.memory(
                                                                image))),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10.0,
                                                                right: 10,
                                                                top: 5,
                                                                bottom: 5),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "${candidats[index]["candidat_nom"]} ${candidats[index]["candidat_prenom"]}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        )),
                                                    Container(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: Text(
                                                        '${candidats[index]["total"]} / ${snapshot.data.bareme}',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors
                                                                .blueGrey),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                          ],
                        )
                      ],
                    ),
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
        ));
  }
}
