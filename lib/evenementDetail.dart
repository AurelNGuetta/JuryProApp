import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:custom_dropdown/custom_dropdown.dart';
import 'package:date_field/date_field.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/apiService.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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

class Candidat {
  final int candidat_id;
  final String candidat_nom;
  final String candidat_prenom;
  final int candidat_telephone;
  final String candidat_email;
  final String candidat_photo;

  Candidat(
      {this.candidat_id,
      this.candidat_nom,
      this.candidat_prenom,
      this.candidat_telephone,
      this.candidat_email,
      this.candidat_photo});

  factory Candidat.fromJson(Map<String, dynamic> json) {
    return Candidat(
        candidat_id: json['candidat_id'],
        candidat_nom: json['candidat_nom'],
        candidat_prenom: json['candidat_prenom'],
        candidat_telephone: json['candidat_telephone'],
        candidat_email: json['candidat_email'],
        candidat_photo: json['candidat_photo']);
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
  bool haveParticipant = false;

  _EvenementDetailPageState(evenement) {
    this.evenement = evenement;
  }

  Future<Evenement> futureEvenement;
  List data;
  bool _isLoading = false;

  Future<Evenement> fetchEvenement() async {
    final response =
        await http.get('http://172.31.240.145:8080/evenements/$evenement');

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

  Future<List> fetchAllCandidats() async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.get("172.31.240.145:8080/candidats/event/$evenement");

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

    futureEvenement = fetchEvenement();
    fetchAllCandidats();
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
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                  Container(
                    height: 30,
                  ),
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
                        style:
                            TextStyle(fontSize: 18, color: Color(0xD2747375)),
                      ),
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
                            "LISTE DES ${snapshot.data.evenement_type}S",
                            style: TextStyle(
                                fontSize: 22, color: Color(0xFFFF7900)),
                          ),
                        ),
                      ),
                      (_isLoading) ? Container(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              Container(height: 20,),
                              Text("Chargement des Participants")
                            ],
                          ),
                        ),
                      )
                      : Container(
                        height: 280,
                        child: ListView.builder(
                          itemCount: data == null ? 0 : data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: <Widget>[
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          "https://images.pexels.com/photos/4177650/pexels-photo-4177650.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        "${data[index]["candidat_nom"]} ${data[index]["candidat_prenom"]}",
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                            CircularProgressIndicator();
                          },
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
    ));
  }
}
