import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter/constant/constant.dart';
import 'package:learn_flutter/groupe/groupe.dart';
import 'package:learn_flutter/groupe/groupeEvenementDetail.dart';

Future<Groupe> createGroupe(
    String code, String groupe_nom, String groupe_photo, int evenement) async {
  final http.Response response = await http.post(
    '${Constant.ip}/groupes',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'code': code,
      'groupe_nom': groupe_nom,
      'groupe_photo': groupe_photo,
      'evenement_id': evenement
    }),
  );

  if (response.statusCode == 200) {
    Groupe groupe = Groupe.fromJson(jsonDecode(response.body));

    return groupe;
  } else {
    throw Exception('Echec de la création du groupe');
  }
}

class AddGroupePage extends StatefulWidget {
  int evenement;
  int groupe_id;
  AddGroupePage({Key key, this.evenement}) : super(key: key);

  _AddGroupePageState createState() => _AddGroupePageState(evenement);
}

class _AddGroupePageState extends State<AddGroupePage> {
  int evenement;

  File _imageFile;
  final _picker = ImagePicker();

  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Erreur de chargement du fichier';

  bool _isUploading = false;

  final TextEditingController _groupeNameController = TextEditingController();
  final TextEditingController _groupeCodeController = TextEditingController();

  _AddGroupePageState(int evenement) {
    this.evenement = evenement;
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
                              "Créer un groupe",
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
                          controller: _groupeCodeController,
                          cursorColor: Color(0xFF373A36),
                          style: TextStyle(color: Color(0xFFFE8556)),
                          decoration: InputDecoration(
                              labelText: "Code Groupe",
                              contentPadding: EdgeInsets.all(18),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(width: 0, color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))))),
                      const SizedBox(height: 25),
                      TextField(
                          controller: _groupeNameController,
                          cursorColor: Color(0xFF373A36),
                          style: TextStyle(color: Color(0xFFFE8556)),
                          decoration: InputDecoration(
                              labelText: "Nom ",
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
                            _isUploading = true;
                            createGroupe(
                                _groupeCodeController.text,
                                _groupeNameController.text,
                                base64Image,
                                evenement);
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
