class PaireAssociation {
  final String gauche;
  final String droite;

  PaireAssociation({required this.gauche, required this.droite});

  factory PaireAssociation.fromJson(Map<String, dynamic> json) {
    return PaireAssociation(
      gauche: json['gauche'] as String? ?? '',
      droite: json['droite'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'gauche': gauche, 'droite': droite};
}

class Question {
  final String enonce;
  final List<String>? options;
  final dynamic reponse;
  final List<String>? acceptees;
  final List<PaireAssociation>? paires;
  final String explication;

  Question({
    required this.enonce,
    this.options,
    required this.reponse,
    this.acceptees,
    this.paires,
    required this.explication,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      enonce: json['enonce'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      reponse: json['reponse'],
      acceptees: (json['acceptees'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      paires: (json['paires'] as List<dynamic>?)
          ?.map((p) => PaireAssociation.fromJson(p as Map<String, dynamic>))
          .toList(),
      explication: json['explication'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enonce': enonce,
      if (options != null) 'options': options,
      'reponse': reponse,
      if (acceptees != null) 'acceptees': acceptees,
      if (paires != null) 'paires': paires?.map((p) => p.toJson()).toList(),
      'explication': explication,
    };
  }
}

class Exercice {
  final String id;
  final String titre;
  final String consigne;
  final String type; // qcm, vrai_faux, trous, choix_dans_phrase, association, transformation
  final List<Question> questions;

  Exercice({
    required this.id,
    required this.titre,
    required this.consigne,
    required this.type,
    required this.questions,
  });

  factory Exercice.fromJson(Map<String, dynamic> json) {
    return Exercice(
      id: json['id'] as String? ?? '',
      titre: json['titre'] as String? ?? '',
      consigne: json['consigne'] as String? ?? '',
      type: json['type'] as String? ?? 'qcm',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'consigne': consigne,
      'type': type,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}
