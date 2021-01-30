import 'dart:convert';

import 'package:http/http.dart' as http;

class URLS {
  static const String BASE_URL = 'http://localhost:8080/evenements';
}

class ApiService {
  static Future<Evenement> getAllEvenements() async {
    final response = await http.get('http://localhost:8080/evenements/3');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Evenement.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Evenement');
    }
  }

  static Future<bool> addEvenement(body) async {
    // BODY
    // {
    //   "name": "test",
    //   "age": "23"
    // }
    final response = await http.post('${URLS.BASE_URL}', body: body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }


}

class Evenement {
  final int evenement_id;
  final String evenement_nom;
  final String evenement_description;
  final String evenement_photo;
  final String evenement_date_debut;
  final String evenement_date_fin;

  Evenement({this.evenement_description, this.evenement_photo, this.evenement_id,
      this.evenement_nom,
      this.evenement_date_debut,
      this.evenement_date_fin});

  factory Evenement.fromJson(Map<String, dynamic> json) {
    return Evenement(
        evenement_id: json['evenement_id'],
        evenement_nom: json['evenement_nom'],
        evenement_photo: json['evenement_photo'],
        evenement_description: json['evenement_description'],
        evenement_date_debut: json['evenement_date_debut'],
        evenement_date_fin: json['evenement_date_fin']);
  }

  get length => null;
}
