import 'dart:convert';

class VoteCandidat {
  final int vote_candidat_id;
  final int jury_id;
  final int evenement_id;
  final int candidat_id;
  final int critere_id;
  final double note;
  final String commentaires;

  VoteCandidat({
    this.vote_candidat_id,
    this.jury_id,
    this.evenement_id,
    this.candidat_id,
    this.critere_id,
    this.note,
    this.commentaires,
  });

  factory VoteCandidat.fromJson(Map<String, dynamic> json) {
    return VoteCandidat(
        jury_id: json['jury_id'],
        evenement_id: json['evenement_id'],
        candidat_id: json['candidat_id'],
        critere_id: json['critere_id'],
        note: json['note']);
  }

  get length => null;

  VoteCandidat copyWith({
    int vote_candidat_id,
    int jury_id,
    int evenement_id,
    int candidat_id,
    int critere_id,
    int note,
    String commentaires,
  }) {
    return VoteCandidat(
      vote_candidat_id: vote_candidat_id ?? this.vote_candidat_id,
      jury_id: jury_id ?? this.jury_id,
      evenement_id: evenement_id ?? this.evenement_id,
      candidat_id: candidat_id ?? this.candidat_id,
      critere_id: critere_id ?? this.critere_id,
      note: note ?? this.note,
      commentaires: commentaires ?? this.commentaires,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vote_candidat_id': vote_candidat_id,
      'jury_id': jury_id,
      'evenement_id': evenement_id,
      'candidat_id': candidat_id,
      'critere_id': critere_id,
      'note': note,
      'commentaires': commentaires,
    };
  }

  factory VoteCandidat.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return VoteCandidat(
      vote_candidat_id: map['vote_candidat_id'],
      jury_id: map['jury_id'],
      evenement_id: map['evenement_id'],
      candidat_id: map['candidat_id'],
      critere_id: map['critere_id'],
      note: map['note'],
      commentaires: map['commentaires'],
    );
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'VoteCandidat(vote_candidat_id: $vote_candidat_id, jury_id: $jury_id, evenement_id: $evenement_id, candidat_id: $candidat_id, critere_id: $critere_id, note: $note, commentaires: $commentaires)';
  }
}
