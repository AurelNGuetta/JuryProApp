import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/constant/constant.dart';
import 'package:learn_flutter/criteres/Criteria.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:learn_flutter/groupe/groupe.dart';
import 'package:learn_flutter/jury/Jury.dart';
import 'package:learn_flutter/jury/showJuryOneEvent.dart';
import 'package:learn_flutter/vote/voteCandidat.dart';
import 'package:learn_flutter/vote/voteGroupe.dart';

Future<VoteCandidat> saveVoteGroupe(VoteGroupe vote) async {
  final http.Response response = await http.post(
    '${Constant.ip}/voteGroupe',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'vote_groupe_id': vote.vote_groupe_id,
      'jury_id': vote.jury_id,
      'evenement_id': vote.evenement_id,
      'groupe_id': vote.groupe_id,
      'critere_id': vote.critere_id,
      'note': vote.note,
      'commentaires': vote.commenentaires
    }),
  );

  if (response.statusCode == 200) {
    return VoteCandidat.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Echec d\'enregistrement du vote');
  }
}

class VoteGroupePage extends StatefulWidget {
  final Jury jury;
  final Groupe groupe;
  final Groupe nextGroupe;
  VoteGroupePage(
      {Key key,
      @required this.jury,
      @required this.groupe,
      @required this.nextGroupe})
      : super(key: key);

  _VoteGroupePageState createState() =>
      _VoteGroupePageState(jury, groupe, nextGroupe);
}

class _VoteGroupePageState extends State<VoteGroupePage> {
  Jury jury;
  Groupe groupe;
  Groupe nextGroupe;
  List criteres;
  bool haveParticipant = false;
  Map<int, VoteCandidat> votes;

  _VoteGroupePageState(jury, groupe, nextGroupe) {
    this.jury = jury;
    this.groupe = groupe;
    this.nextGroupe = nextGroupe;
  }

  Future<Criteria> futureCriteres;
  Future<VoteCandidat> futureVotesCandidat;
  Map<int, Future<VoteCandidat>> oldVotes;

  List data;
  List candidats;
  bool _isLoading = false;

  Map notes = {};
  Map choices = {};

  Future<Criteria> fetchCriteres() async {
    setState(() {
      _isLoading = true;
    });
    print(" Evenement du candidat : " + groupe.evenement_id.toString());
    final response =
        await http.get("${Constant.ip}/criteres/event/${groupe.evenement_id}");

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        criteres = json.decode(response.body);
      });
      // return json.decode(response.body);
    } else {
      throw Exception("Erreur de récupération des critères");
    }
  }

  Future<VoteCandidat> fetchCandidatNote(int critere) async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(
        "${Constant.ip}/voteCandidats/noted/${groupe.groupe_id}/${groupe.evenement_id}/$critere/$jury");

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        votes[critere] = json.decode(response.body);
      });
      // return json.decode(response.body);
    } else {
      throw Exception("Erreur de récupération des notes");
    }
  }

  @override
  void initState() {
    super.initState();
    futureCriteres = fetchCriteres();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'NOTER ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0),
        body: SingleChildScrollView(
          child: Column(children: [
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(200)),
                  color: Color(0xFF000000),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(150),
                  child: Image.memory(
                    Base64Codec().decode(groupe.groupe_photo),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  child: (_isLoading)
                      ? Container(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                Container(
                                  height: 20,
                                ),
                                Text("Chargement des Notes")
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: criteres == null ? 0 : criteres.length,
                          itemBuilder: (BuildContext context, int index) {
                            // futureVotesCandidat =
                            //     fetchCandidatNote(criteres[index]['critere_id']);
                            return Card(
                              color: Colors.white,
                              elevation: 0,
                              child: Column(children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(
                                      left: 10, right: 10, top: 25, bottom: 25),
                                  child: Text(
                                    criteres[index]['critere_libelle'],
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange),
                                  ),
                                ),
                                // Divider(height: 6, color: Colors.blueGrey),
                                Container(
                                  padding: EdgeInsets.only(top: 25, bottom: 25),
                                  child: RatingBar.builder(
                                    initialRating: 0,
                                    minRating: 1,
                                    itemSize: 50,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 4.0),
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      double note = (rating *
                                              criteres[index]
                                                  ['critere_bareme']) /
                                          5; // Note définitive en fonction du bareme
                                      choices[criteres[index]['critere_id']] =
                                          note; // sauvegarde la note
                                      print(criteres[index]['critere_libelle'] +
                                          " " +
                                          rating
                                              .toString()); // Affiche le critère et le nombre d'étoile choisi

                                      print("\n Bareme : " +
                                          criteres[index]['critere_bareme']
                                              .toString() +
                                          "\n"); // Affiche le bareme de notation du critère
                                      print(" Notes : " +
                                          choices
                                              .toString()); // affiche la liste des notes par critère
                                    },
                                  ),
                                )
                              ]),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: FlatButton(
                      minWidth: double.infinity,
                      height: 55,
                      color: Colors.teal,
                      textColor: Colors.white,
                      onPressed: () {
                        choices.forEach((critereId, critereNote) {
                          VoteGroupe vote = new VoteGroupe(
                              groupe_id: groupe.groupe_id,
                              evenement_id: groupe.evenement_id,
                              jury_id: jury.jury_id,
                              critere_id: critereId,
                              note: critereNote);
                          saveVoteGroupe(vote);

                          if (nextGroupe != null) {
                            Navigator.of(context)
                                .push(_showNextGroupe(nextGroupe, jury));
                          } else {
                            Navigator.of(context).push(_createRoute(jury));
                          }
                          // print(vote);
                        });
                      },
                      child: Text(
                        'ENREGISTRER NOTES',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      )),
                )
              ],
            )
          ]),
        ));
  }

  Route _createRoute(Jury jury) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ShowJuryOneEventPage(
        jury: jury,
        evenement: groupe.evenement_id,
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

  Route _showNextGroupe(Groupe nextCandidat, Jury jury) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          VoteGroupePage(jury: jury, groupe: nextCandidat, nextGroupe: null),
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
