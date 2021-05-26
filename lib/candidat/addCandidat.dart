import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/candidat/candidat.dart';
import 'package:learn_flutter/constant/constant.dart';
import 'package:learn_flutter/groupe/groupeEvenementDetail.dart';

Future<Candidat> createCandidat(
    String candidat_nom,
    String candidat_prenom,
    String candidat_email,
    String candidat_photo,
    String candidat_telephone,
    int evenement,
    int groupe_id) async {
  final http.Response response = await http.post(
    '${Constant.ip}/candidats',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'candidat_nom': candidat_nom,
      'candidat_prenom': candidat_prenom,
      'candidat_email': candidat_email,
      'candidat_telephone': candidat_telephone,
      'candidat_photo': candidat_photo,
      'candidat_evenement': evenement
    }),
  );

  if (response.statusCode == 200) {
    Candidat candidat = Candidat.fromJson(jsonDecode(response.body));

    if (groupe_id != null) {
      Future<bool> addCandidatGroupe;
      final http.Response res = await http.post(
        '${Constant.ip}/groupeCandidat/',
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'candidat_id': candidat.candidat_id,
          'groupe_id': groupe_id,
        }),
      );
      addCandidatGroupe = jsonDecode(res.body);
    }
    return candidat;
  } else {
    throw Exception('Echec de la création du candidat');
  }
}

class AddCandidatPage extends StatefulWidget {
  int evenement;
  int groupe_id;
  AddCandidatPage({Key key, this.evenement, this.groupe_id}) : super(key: key);

  _AddCandidatPageState createState() =>
      _AddCandidatPageState(evenement, groupe_id);
}

class _AddCandidatPageState extends State<AddCandidatPage> {
  int evenement;
  int groupe_id;

  File _imageFile;
  final _picker = ImagePicker();

  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Erreur de chargement du fichier';

  bool _isUploading = false;

  final TextEditingController _candidatNameController = TextEditingController();
  final TextEditingController _candidatSurnameController =
      TextEditingController();
  final TextEditingController _candidatEmailController =
      TextEditingController();
  final TextEditingController _candidatPhoneController =
      TextEditingController();

  _AddCandidatPageState(int evenement, int groupe_id) {
    this.evenement = evenement;
    this.groupe_id = groupe_id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(''),
          backgroundColor: Colors.teal,
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
                      bottomLeft: Radius.circular(
                          MediaQuery.of(context).size.width / 9),
                      bottomRight: Radius.circular(
                          MediaQuery.of(context).size.width / 9)),
                  color: Colors.teal,
                ),
                child: Column(
                  children: [
                    Container(
                      child: Center(
                        child: Column(children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 3.3,
                            height: MediaQuery.of(context).size.width / 3.7,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.photo),
                                      onPressed: () async => chooseImage(),
                                      tooltip: "Choisir depuis la galerie",
                                    ),
                                    showImage()
                                  ],
                                )),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              "Ajouter un Candidat",
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
                          controller: _candidatNameController,
                          cursorColor: Color(0xFF373A36),
                          style: TextStyle(color: Color(0xFFFE8556)),
                          decoration: InputDecoration(
                              labelText: "Nom",
                              contentPadding: EdgeInsets.all(18),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 0, color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))))),
                      const SizedBox(height: 25),
                      TextField(
                          controller: _candidatSurnameController,
                          cursorColor: Color(0xFF373A36),
                          style: TextStyle(color: Color(0xFFFE8556)),
                          decoration: InputDecoration(
                              labelText: "Prénoms",
                              contentPadding: EdgeInsets.all(18),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 0, color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))))),
                      const SizedBox(height: 25),
                      TextField(
                          controller: _candidatEmailController,
                          cursorColor: Color(0xFF373A36),
                          style: TextStyle(color: Color(0xFFFE8556)),
                          decoration: InputDecoration(
                              labelText: "Email",
                              contentPadding: EdgeInsets.all(18),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 0, color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))))),
                      TextField(
                          controller: _candidatPhoneController,
                          cursorColor: Color(0xFF373A36),
                          style: TextStyle(color: Color(0xFFFE8556)),
                          decoration: InputDecoration(
                              labelText: "Telephone",
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
                              backgroundColor: Colors.teal,
                              onSurface: Colors.grey,
                              padding: EdgeInsets.only(
                                  top: 15, left: 0, right: 0, bottom: 15)),
                          onPressed: () {
                            print("Evenement : " + evenement.toString());
                            print("\nGroupe : " + groupe_id.toString());
                            _isUploading = true;
                            createCandidat(
                                _candidatNameController.text,
                                _candidatSurnameController.text,
                                _candidatEmailController.text,
                                base64Image,
                                _candidatPhoneController.text,
                                evenement,
                                groupe_id);
                            Navigator.of(context).push(_createRoute(evenement));
                          },
                        ),
                      )
                    ]),
                  )),
            ],
          ),
        ));
  }

  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Flexible(
            child: Image.file(
              snapshot.data,
              fit: BoxFit.fill,
            ),
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  startUpload() {
    if (null == tmpFile) {
      return;
    }
    String fileName = tmpFile.path.split('/').last;
  }

  Route _createRoute(int evenement) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          GroupeEvenementDetailPage(evenement: evenement),
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
