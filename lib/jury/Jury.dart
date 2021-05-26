class Jury {
  int jury_id;
  String jury_nom_complet;
  String jury_telephone;
  String email;
  int code;
  int evenement_id;

  Jury(
      {this.jury_id,
      this.jury_nom_complet,
      this.jury_telephone,
      this.email,
      this.code,
      this.evenement_id});

  factory Jury.fromJson(Map<String, dynamic> json) {
    return Jury(
        jury_id: json['jury_id'],
        jury_nom_complet: json['jury_nom_complet'],
        jury_telephone: json['jury_telephone'],
        email: json['email'],
        code: json['code'],
        evenement_id: json['evenement_id']);
  }
}
