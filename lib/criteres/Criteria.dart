class Criteria {
  final int critere_id;
  final int critere_bareme;
  final String critere_libelle;
  final String evenement;

  Criteria(
      {this.critere_id,
      this.critere_bareme,
      this.critere_libelle,
      this.evenement});

  factory Criteria.fromJson(Map<String, dynamic> json) {
    return Criteria(
        critere_id: json['critere_id'],
        critere_bareme: json['critere_bareme'],
        critere_libelle: json['critere_libelle'],
        evenement: json['evenement_id']);
  }
}
