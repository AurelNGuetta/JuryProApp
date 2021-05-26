import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:custom_dropdown/custom_dropdown.dart';
import 'package:date_field/date_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

import 'constant/constant.dart';

Future<Evenement> createEvenement(
    String evenement_nom,
    String evenement_type,
    String evenement_photo,
    String evenement_description,
    String evenement_date_debut,
    String evenement_date_fin) async {
  final http.Response response = await http.post(
    '${Constant.ip}/evenements',
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({
      'evenement_nom': evenement_nom,
      'evenement_type': evenement_type,
      'evenement_photo': evenement_photo,
      'evenement_description': evenement_description,
      'evenement_date_debut': evenement_date_debut,
      'evenement_date_fin': evenement_date_fin
    }),
  );

  if (response.statusCode == 200) {
    return Evenement.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Echec de la modification de l\'evenement');
  }
}

_onCustomAnimationAlertPressed(context) {
  Alert(
    context: context,
    title: "RFLUTTER ALERT",
    desc: "Flutter is more awesome with RFlutter Alert.",
    alertAnimation: FadeAlertAnimation,
  ).show();
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

class Evenement {
  final String evenement_nom;
  final String evenement_type;
  final String evenement_photo;
  final String evenement_description;
  final String evenement_date_debut;
  final String evenement_date_fin;

  Evenement(
      {this.evenement_nom,
      this.evenement_type,
      this.evenement_photo,
      this.evenement_description,
      this.evenement_date_debut,
      this.evenement_date_fin});

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
      evenement_nom: json['evenement_nom'],
      evenement_type: json['evenement_type'],
      evenement_photo: json['evenement_photo'],
      evenement_description: json['evenement_description'],
      evenement_date_debut: json['evenement_date_debut'],
      evenement_date_fin: json['evenement_date_fin'],
    );
  }
}

class UpdateEvenementPage extends StatefulWidget {
  Evenement evenement;
  final int id;
  final String name, type, description, dateDebut, dateFin, image;
  UpdateEvenementPage(
      Key key,
      @required int this.id,
      @required String this.name,
      @required String this.type,
      @required String this.description,
      @required String this.dateDebut,
      @required String this.dateFin,
      @required String this.image)
      : super(key: key);

  _UpdateEvenementPageState createState() => _UpdateEvenementPageState(
      id, name, type, description, dateDebut, dateFin, image);
}

class _UpdateEvenementPageState extends State<UpdateEvenementPage> {
  Evenement evenement;
  int id;
  String name, type, description, dateDebut, dateFin, image;

  _UpdateEvenementPageState(int id, String name, String type,
      String description, String dateDebut, String dateFin, String image) {
    this.id = id;
    this.name = name;
    this.type = type;
    this.description = description;
    this.image = image;
    this.dateDebut = dateDebut;
    this.dateFin = dateFin;
  }

  File _imageFile;
  final _picker = ImagePicker();

  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Erreur de chargement du fichier';

  DateTime _dateTime;
  String _checkboxValue, _dateDebut, _dateFin;
  int _selected;
  bool _isUploading = false;
  Uint8List currentImage;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  TextEditingController _evenementNameController = TextEditingController();
  // final TextEditingController _evenementTypeController = TextEditingController();
  TextEditingController _evenementDescribeController = TextEditingController();
  // final TextEditingController _evenementDateDebut = TextEditingController();
  // final TextEditingController _evenementDateFin = TextEditingController();
  Future<Evenement> _futureEvenement;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selected = type == 'CANDIDAT' ? 0 : 1;
    _evenementNameController.text = name;
    _evenementDescribeController.text = description;
    _dateDebut = dateDebut;
    _dateFin = dateFin;
    currentImage = Base64Codec().decode(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xFFFE8556),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft:
                      Radius.circular(MediaQuery.of(context).size.width / 7),
                  bottomRight:
                      Radius.circular(MediaQuery.of(context).size.width / 7)),
              color: Color(0xFFFE8556),
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
                                  tooltip: 'Choisir depuis Galerie',
                                ),
                                (currentImage != null)
                                    ? Flexible(
                                        child: Image.memory(
                                        currentImage,
                                        fit: BoxFit.fill,
                                      ))
                                    : showImage()
                              ],
                            )),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "",
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
                      controller: _evenementNameController,
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
                  const SizedBox(height: 5),
                  CustomDropdown(
                    valueIndex: _selected,
                    hint: "Type",
                    enableTextColor: Color(0xFFFE8556),
                    enabledIconColor: Color(0xFFFE8556),
                    borderRadius: 5,
                    items: [
                      CustomDropdownItem(text: "CANDIDAT"),
                      CustomDropdownItem(text: "GROUPE"),
                    ],
                    onChanged: (newValue) {
                      // print(newValue);
                      setState(() {
                        _selected = newValue;
                        _checkboxValue =
                            (newValue == 0) ? 'CANDIDAT' : 'GROUPE';
                      });
                      // setState(() => _evenementTypeController = 'CANDIDAT');
                    },
                  ),
                  const SizedBox(height: 5),
                  DateTimeFormField(
                    dateTextStyle: TextStyle(),
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Color(0xFF373A36)),
                      errorStyle: TextStyle(color: Colors.redAccent),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.event_note),
                      labelText: 'Date début',
                    ),
                    autovalidateMode: AutovalidateMode.always,
                    initialValue: DateTime.parse(dateDebut + ' 00:00:00.000'),
                    validator: (e) => (e?.day ?? 0) == 1
                        ? 'Imposible de choisir aujourd\'hui'
                        : null,
                    onDateSelected: (DateTime value) {
                      setState(() =>
                          _dateDebut = formatter.format(value).toString());
                      // print(formatter.format(value));
                    },
                  ),
                  const SizedBox(height: 5),
                  DateTimeFormField(
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(color: Color(0xFF373A36)),
                      errorStyle: TextStyle(color: Colors.redAccent),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.event_note),
                      labelText: 'Date fin',
                    ),
                    initialValue: DateTime.parse(dateFin + ' 00:00:00.000'),
                    autovalidateMode: AutovalidateMode.always,
                    validator: (e) => (e?.day ?? 0) == 1
                        ? 'Imposible de choisir aujourd\'hui'
                        : null,
                    onDateSelected: (DateTime value) {
                      // print(value);
                      setState(
                          () => _dateFin = formatter.format(value).toString());
                    },
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _evenementDescribeController,
                    cursorColor: Color(0xFF373A36),
                    maxLines: 3,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFFFE8556)),
                    decoration: InputDecoration(
                      labelText: "Description",
                      contentPadding: EdgeInsets.all(18),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 0, color: Colors.white),
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                  ),
                  Container(height: 5),
                  ButtonTheme(
                    child: TextButton(
                      child: Container(
                        child: Text(
                          'Enregistrer',
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
                        final DateTime now = DateTime.now();
                        final String formatted = formatter.format(now);
                        _isUploading = true;
                        setState(() {
                          _futureEvenement = createEvenement(
                            _evenementNameController.text,
                            _checkboxValue,
                            base64Image,
                            _evenementDescribeController.text,
                            _dateDebut,
                            _dateFin,
                          );
                          _isUploading = false;
                        });
                        if (_isUploading) {
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
                        } else {
                          return Alert(
                            context: context,
                            type: (_futureEvenement == null)
                                ? AlertType.error
                                : AlertType.success,
                            title: "Jury Pro",
                            desc: (_futureEvenement == null)
                                ? "Echec de l'Ajout"
                                : "Enregistrement Réussi",
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                onPressed: () => Navigator.pop(context),
                                width: 120,
                              )
                            ],
                          ).show();
                        }
                      },
                    ),
                  )
                ]),
              )),
        ],
      ),
    );
  }

  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
      currentImage = null;
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
            'Erreur de chargement de l\'image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            "Pas d'image sélectionnée",
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  startUpload() {
    // setStatus('Uploading Image...');
    if (null == tmpFile) {
      // setState(errMessage );
      return;
    }
    String fileName = tmpFile.path.split('/').last;
    // upload(fileName);
  }

  // upload(String fileName) {
  //   http.post(uploadEndPoint, body: {
  //     "image": base64Image,
  //     "name": fileName,
  //   }).then((result) {
  //     setStatus(result.statusCode == 200 ? result.body : errMessage);
  //   }).catchError((error) {
  //     setStatus(error);
  //   });
  // }

}
