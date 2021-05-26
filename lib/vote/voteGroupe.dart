import 'dart:convert';

class VoteGroupe {
  final int vote_groupe_id;
  final int jury_id;
  final int evenement_id;
  final int groupe_id;
  final int critere_id;
  final double note;
  final String commenentaires;

  VoteGroupe({
    this.vote_groupe_id,
    this.jury_id,
    this.evenement_id,
    this.groupe_id,
    this.critere_id,
    this.note,
    this.commenentaires,
  });

  Map<String, dynamic> toMap() {
    return {
      'vote_groupe_id': vote_groupe_id,
      'jury_id': jury_id,
      'evenement_id': evenement_id,
      'groupe_id': groupe_id,
      'critere_id': critere_id,
      'note': note,
      'commenentaires': commenentaires,
    };
  }

  factory VoteGroupe.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return VoteGroupe(
      vote_groupe_id: map['vote_groupe_id'],
      jury_id: map['jury_id'],
      evenement_id: map['evenement_id'],
      groupe_id: map['groupe_id'],
      critere_id: map['critere_id'],
      note: map['note'],
      commenentaires: map['commenentaires'],
    );
  }

  String toJson() => json.encode(toMap());

  factory VoteGroupe.fromJson(String source) =>
      VoteGroupe.fromMap(json.decode(source));

  @override
  String toString() {
    return 'VoteGroupe(vote_groupe_id: $vote_groupe_id, jury_id: $jury_id, evenement_id: $evenement_id, groupe_id: $groupe_id, critere_id: $critere_id, note: $note, commenentaires: $commenentaires)';
  }
}
