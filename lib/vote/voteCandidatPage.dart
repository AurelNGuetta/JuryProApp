import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/candidat/candidat.dart';
import 'package:learn_flutter/constant/constant.dart';
import 'package:learn_flutter/criteres/Criteria.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:learn_flutter/jury/Jury.dart';
import 'package:learn_flutter/jury/showJuryOneEvent.dart';
import 'package:learn_flutter/vote/voteCandidat.dart';

Future<VoteCandidat> saveVoteCandidat(VoteCandidat vote) async {
  final http.Response response = await http.post(
    '${Constant.ip}/voteCandidats',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'vote_candidat_id': vote.vote_candidat_id,
      'jury_id': vote.jury_id,
      'evenement_id': vote.evenement_id,
      'candidat_id': vote.candidat_id,
      'critere_id': vote.critere_id,
      'note': vote.note,
      'commentaires': vote.commentaires
    }),
  );

  if (response.statusCode == 200) {
    return VoteCandidat.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Echec de la création de l\'evenement');
  }
}

class VoteCandidatPage extends StatefulWidget {
  final Jury jury;
  final Candidat candidat;
  final Candidat nextCandidat;
  VoteCandidatPage(
      {Key key,
      @required this.jury,
      @required this.candidat,
      @required this.nextCandidat})
      : super(key: key);

  _VoteCandidatPageState createState() =>
      _VoteCandidatPageState(jury, candidat, nextCandidat);
}

class _VoteCandidatPageState extends State<VoteCandidatPage> {
  Jury jury;
  Candidat candidat;
  Candidat nextCandidat;
  List criteres;
  bool haveParticipant = false;
  Map<int, VoteCandidat> votes;

  _VoteCandidatPageState(jury, candidat, nextCandidat) {
    this.jury = jury;
    this.candidat = candidat;
    this.nextCandidat = nextCandidat;
  }

  Future<Criteria> futureCriteres;
  Future<VoteCandidat> futureVotesCandidat;
  Map<int, Future<VoteCandidat>> oldVotes;

  List data;
  List candidats;
  bool _isLoading = false;

  Map notes = {};
  Map choices = {};

  final TextEditingController _voteCommentaireController =
      TextEditingController();

  Future<Criteria> fetchCriteres() async {
    setState(() {
      _isLoading = true;
    });
    final response = await http
        .get("${Constant.ip}/criteres/event/${candidat.candidat_evenement}");
    print(Constant.ip);

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        criteres = json.decode(response.body);
      });
      return Criteria.fromJson(json.decode(response.body));
    } else {
      throw Exception("Erreur de récupération des critères");
    }
  }

  Future<VoteCandidat> fetchCandidatNote(int critere) async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.get(
        "${Constant.ip}/voteCandidats/noted/${candidat.candidat_id}/${candidat.candidat_evenement}/$critere/${jury.jury_id}");

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        votes[critere] = VoteCandidat.fromJson(json.decode(response.body));
        // print("Votes : " + votes.toString());
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
    // futureCriteres.then((critere) {
    //   criteres.forEach((critere) {
    //     fetchCandidatNote(critere['critere_id']);
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'NOTER ' + candidat.candidat_nom.toUpperCase(),
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
                    Base64Codec().decode(candidat.candidat_photo),
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
                  height: MediaQuery.of(context).size.height / 2.5,
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
                                      left: 10, right: 10, top: 10, bottom: 5),
                                  child: Text(
                                    criteres[index]['critere_libelle'],
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                ),
                                // Divider(height: 6, color: Colors.blueGrey),
                                Container(
                                  padding: EdgeInsets.only(top: 20, bottom: 10),
                                  child: RatingBar.builder(
                                    initialRating: 0,
                                    minRating: 1,
                                    itemSize: 40,
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
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 15),
                  child: TextField(
                      controller: _voteCommentaireController,
                      cursorColor: Color(0xFF373A36),
                      style: TextStyle(color: Colors.blueGrey),
                      maxLines: 3,
                      decoration: InputDecoration(
                          labelText: "Commentaire",
                          contentPadding: EdgeInsets.all(18),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 0, color: Colors.white),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))))),
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
                          VoteCandidat vote = new VoteCandidat(
                              candidat_id: candidat.candidat_id,
                              evenement_id: candidat.candidat_evenement,
                              jury_id: jury.jury_id,
                              critere_id: critereId,
                              commentaires: _voteCommentaireController.text,
                              note: critereNote);
                          saveVoteCandidat(vote);

                          if (nextCandidat != null) {
                            Navigator.of(context)
                                .push(_showNextCandidat(nextCandidat, jury));
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
        evenement: candidat.candidat_evenement,
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

  Route _showNextCandidat(Candidat nextCandidat, Jury jury) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => VoteCandidatPage(
          jury: jury, candidat: nextCandidat, nextCandidat: null),
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
