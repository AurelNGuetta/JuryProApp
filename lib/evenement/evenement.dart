import 'dart:convert';

class Evenement {
  int evenement_id;
  String evenement_nom;
  String evenement_description;
  String evenement_photo;
  String evenement_type;
  String evenement_date_debut;
  String evenement_date_fin;
  Evenement({
    this.evenement_id,
    this.evenement_nom,
    this.evenement_description,
    this.evenement_photo,
    this.evenement_type,
    this.evenement_date_debut,
    this.evenement_date_fin,
  });

  Map<String, dynamic> toMap() {
    return {
      'evenement_id': evenement_id,
      'evenement_nom': evenement_nom,
      'evenement_description': evenement_description,
      'evenement_photo': evenement_photo,
      'evenement_type': evenement_type,
      'evenement_date_debut': evenement_date_debut,
      'evenement_date_fin': evenement_date_fin,
    };
  }

  factory Evenement.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Evenement(
      evenement_id: map['evenement_id'],
      evenement_nom: map['evenement_nom'],
      evenement_description: map['evenement_description'],
      evenement_photo: map['evenement_photo'],
      evenement_type: map['evenement_type'],
      evenement_date_debut: map['evenement_date_debut'],
      evenement_date_fin: map['evenement_date_fin'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Evenement.fromJson(String source) =>
      Evenement.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Evenement(evenement_id: $evenement_id, evenement_nom: $evenement_nom, evenement_description: $evenement_description, evenement_photo: $evenement_photo, evenement_type: $evenement_type, evenement_date_debut: $evenement_date_debut, evenement_date_fin: $evenement_date_fin)';
  }
}
