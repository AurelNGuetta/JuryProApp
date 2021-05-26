import 'dart:convert';

class Groupe {
  int groupe_id;
  String code;
  String groupe_photo;
  String groupe_nom;
  int evenement_id;

  Groupe({
    this.groupe_id,
    this.code,
    this.groupe_photo,
    this.groupe_nom,
    this.evenement_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupe_id': groupe_id,
      'code': code.toString(),
      'groupe_photo': groupe_photo,
      'groupe_nom': groupe_nom,
      'evenement_id': evenement_id,
    };
  }

  factory Groupe.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Groupe(
      groupe_id: map['groupe_id'],
      code: map['code'],
      groupe_photo: map['groupe_photo'],
      groupe_nom: map['groupe_nom'],
      evenement_id: map['evenement_id'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Groupe.fromJson(Map<String, dynamic> json) {
    return Groupe(
        groupe_id: json['groupe_id'],
        code: json['code'].toString(),
        groupe_nom: json['groupe_nom'],
        groupe_photo: json['groupe_photo'],
        evenement_id: json['evenement_id']);
  }

  @override
  String toString() {
    return 'Groupe(groupe_id: $groupe_id, code: $code, groupe_photo: $groupe_photo, groupe_nom: $groupe_nom, evenement_id: $evenement_id)';
  }
}
