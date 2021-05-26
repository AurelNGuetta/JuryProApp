import 'dart:convert';

class Candidat {
  final int candidat_id;
  final String candidat_nom;
  final String candidat_prenom;
  final String candidat_telephone;
  final String candidat_email;
  final String candidat_photo;
  final int candidat_evenement;

  Candidat(
      {this.candidat_id,
      this.candidat_nom,
      this.candidat_prenom,
      this.candidat_telephone,
      this.candidat_email,
      this.candidat_photo,
      this.candidat_evenement});

  factory Candidat.fromJson(Map<String, dynamic> json) {
    return Candidat(
        candidat_id: json['id'],
        candidat_nom: json['candidat_nom'],
        candidat_prenom: json['candidat_prenom'],
        candidat_telephone: json['candidat_telephone'].toString(),
        candidat_email: json['candidat_email'],
        candidat_evenement: json['evenement_id'],
        candidat_photo: json['candidat_photo']);
  }

  get length => null;

  @override
  String toString() {
    return 'Candidat(candidat_id: $candidat_id, candidat_nom: $candidat_nom, candidat_prenom: $candidat_prenom, candidat_telephone: $candidat_telephone, candidat_email: $candidat_email, candidat_photo: $candidat_photo, candidat_evenement: $candidat_evenement)';
  }
}
