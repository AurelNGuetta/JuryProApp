import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/candidat/candidat.dart';
import 'package:learn_flutter/constant/constant.dart';
import 'package:learn_flutter/groupe/groupe.dart';
import 'package:learn_flutter/jury/Jury.dart';
import 'package:learn_flutter/vote/voteCandidatPage.dart';
import 'package:learn_flutter/vote/voteGroupePage.dart';

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

class ShowJuryOneEventPage extends StatefulWidget {
  final Jury jury;
  final int evenement;
  ShowJuryOneEventPage({Key key, @required this.jury, @required this.evenement})
      : super(key: key);

  _ShowJuryOneEventPageState createState() =>
      _ShowJuryOneEventPageState(jury, evenement);
}

class _ShowJuryOneEventPageState extends State<ShowJuryOneEventPage> {
  Jury jury;
  Evenement event;
  int evenementId;
  bool haveParticipant = false;

  _ShowJuryOneEventPageState(Jury jury, int evenement) {
    this.jury = jury;
    this.evenementId = evenement;
  }

  Future<Evenement> futureEvenement;
  List data;
  List candidats;
  List groupes;
  bool _isLoading = false;
  bool _loadGroupe = false;

  Future<Evenement> fetchEvenement() async {
    final response = await http.get('${Constant.ip}/evenements/$evenementId');

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
      throw Exception('Erreur de récupération des évènements');
    }
  }

  Future<Candidat> fetchAllCandidats() async {
    setState(() {
      _isLoading = true;
    });
    final response = await http
        .get("${Constant.ip}/candidats/event/${jury.jury_id}/$evenementId");

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

  Future<Groupe> fetchAllGroupes() async {
    setState(() {
      _loadGroupe = true;
    });
    final response =
        await http.get("${Constant.ip}/groupes/results/$evenementId");

    if (response.statusCode == 200) {
      setState(() {
        _loadGroupe = false;
        groupes = json.decode(response.body);
      });
      // return json.decode(response.body);
    } else {
      throw Exception("Erreur de récupération des groupes");
    }
  }

  @override
  void initState() {
    super.initState();
    futureEvenement = fetchEvenement();
    fetchAllCandidats();
    fetchAllGroupes();
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
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Deconnexion",
            onPressed: () {
              // Navigator.of(context).push(_createRoute(event));
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        child: FutureBuilder<Evenement>(
          future: futureEvenement,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              event = snapshot.data;
              return SingleChildScrollView(
                child: Container(
                  width: double.infinity,
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
                            Base64Codec().decode(snapshot.data.evenement_photo),
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
                      Container(height: 40),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 10, bottom: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "LISTE DES ${snapshot.data.evenement_type}S",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF170557),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          (snapshot.data.evenement_type == "CANDIDAT")
                              ? (_isLoading)
                                  ? Container(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            CircularProgressIndicator(),
                                            Container(
                                              height: 20,
                                            ),
                                            Text("Chargement des candidats")
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
                                          // candidats[index]['candidat_evenement'] =
                                          //     evenementId;
                                          if (candidats[index]
                                                  ['candidat_photo'] !=
                                              null) {
                                            var blob = candidats[index]
                                                ['candidat_photo'];
                                            image = Base64Codec().decode(blob);
                                          }
                                          return GestureDetector(
                                              onTap: () {
                                                Candidat nextCandidat;
                                                if (index < candidats.length) {
                                                  nextCandidat =
                                                      Candidat.fromJson(
                                                          candidats[index + 1]);
                                                } else {
                                                  nextCandidat = null;
                                                }
                                                Navigator.of(context).push(
                                                    _voteCandidat(
                                                        Candidat.fromJson(
                                                            candidats[index]),
                                                        jury,
                                                        nextCandidat));
                                              },
                                              child: Card(
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
                                                              child:
                                                                  Image.memory(
                                                                      image))),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
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
                                                              Container(
                                                                height: 5,
                                                              ),
                                                              Text(
                                                                "${candidats[index]["candidat_email"]}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                ),
                                                              ),
                                                              Text(
                                                                "${candidats[index]["candidat_telephone"]}",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      16.0,
                                                                ),
                                                              )
                                                            ],
                                                          )),
                                                      Text(
                                                        "${candidats[index]["total"]}pts ",
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.green),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ));
                                        },
                                      ),
                                    )
                              : (_loadGroupe)
                                  ? Container(
                                      padding: EdgeInsets.only(top: 20),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            CircularProgressIndicator(),
                                            Container(
                                              height: 20,
                                            ),
                                            Text("Chargement des groupes")
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 250,
                                      child: ListView.builder(
                                        itemCount: groupes == null
                                            ? 0
                                            : groupes.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          Uint8List image = null;
                                          // candidats[index]['candidat_evenement'] =
                                          //     evenementId;
                                          if (groupes[index]['groupe_photo'] !=
                                              null) {
                                            image = Base64Codec().decode(
                                                groupes[index]['groupe_photo']);
                                          }
                                          return GestureDetector(
                                              onTap: () {
                                                // Groupe nextGroupe;
                                                // if (index < groupes.length) {
                                                //   nextGroupe = Groupe.fromJson(
                                                //       groupes[index + 1]);
                                                // } else {
                                                //   nextGroupe = null;
                                                // }
                                                // print(groupes[index]);
                                                // Groupe gr = new Groupe(
                                                //   groupe_id: groupes[index]['groupe_id'],
                                                //   code: groupes[index]['code'],
                                                //   groupe_nom: groupes[index]['groupe_nom'],
                                                //   groupe_photo: groupes[index]['groupe_photo'],
                                                //   evenement_id: groupes[index]['evenement_id']
                                                // );
                                                Navigator.of(context).push(
                                                    _voteGroupe(
                                                        Groupe.fromJson(
                                                            groupes[index]),
                                                        jury,
                                                        null));
                                              },
                                              child: Card(
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
                                                              child:
                                                                  Image.memory(
                                                                      image))),
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
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
                                                              Container(
                                                                height: 5,
                                                              )
                                                            ],
                                                          )),
                                                      Text(
                                                        "${groupes[index]["total"]}pts ",
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.green),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ));
                                        },
                                      ),
                                    ),
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
      ),
    );
  }

  Route _voteCandidat(Candidat candidat, Jury jury, Candidat nextCandidat) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => VoteCandidatPage(
        jury: jury,
        candidat: candidat,
        nextCandidat: nextCandidat,
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

  Route _voteGroupe(Groupe groupe, Jury jury, Groupe nextGroupe) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => VoteGroupePage(
        jury: jury,
        groupe: groupe,
        nextGroupe: nextGroupe,
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
}
