import 'exercice.dart';

abstract class BlocContenu {
  final String type;
  BlocContenu({required this.type});

  factory BlocContenu.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'paragraphe';
    switch (type) {
      case 'exemple':
        return BlocExemple.fromJson(json);
      case 'tableau':
        return BlocTableau.fromJson(json);
      case 'schema':
        return BlocSchema.fromJson(json);
      case 'paragraphe':
      default:
        return BlocParagraphe.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

class BlocParagraphe extends BlocContenu {
  final String texte;

  BlocParagraphe({required this.texte}) : super(type: 'paragraphe');

  factory BlocParagraphe.fromJson(Map<String, dynamic> json) {
    return BlocParagraphe(texte: json['texte'] as String? ?? '');
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'texte': texte};
}

class BlocExemple extends BlocContenu {
  final String texte;

  BlocExemple({required this.texte}) : super(type: 'exemple');

  factory BlocExemple.fromJson(Map<String, dynamic> json) {
    return BlocExemple(texte: json['texte'] as String? ?? '');
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'texte': texte};
}

class BlocTableau extends BlocContenu {
  final List<String> entetes;
  final List<List<String>> lignes;

  BlocTableau({required this.entetes, required this.lignes})
      : super(type: 'tableau');

  factory BlocTableau.fromJson(Map<String, dynamic> json) {
    return BlocTableau(
      entetes: (json['entetes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lignes: (json['lignes'] as List<dynamic>?)
              ?.map((row) =>
                  (row as List<dynamic>).map((cell) => cell.toString()).toList())
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'entetes': entetes,
        'lignes': lignes,
      };
}

class BlocSchema extends BlocContenu {
  final String id;

  BlocSchema({required this.id}) : super(type: 'schema');

  factory BlocSchema.fromJson(Map<String, dynamic> json) {
    return BlocSchema(id: json['id'] as String? ?? '');
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'id': id};
}

class Lecon {
  final String id;
  final String categorie;
  final String titre;
  final String niveau;
  final bool aValider;
  final List<BlocContenu> contenu;
  final List<Exercice> exercices;

  Lecon({
    required this.id,
    required this.categorie,
    required this.titre,
    required this.niveau,
    required this.aValider,
    required this.contenu,
    required this.exercices,
  });

  factory Lecon.fromJson(Map<String, dynamic> json) {
    return Lecon(
      id: json['id'] as String? ?? '',
      categorie: json['categorie'] as String? ?? 'gram',
      titre: json['titre'] as String? ?? '',
      niveau: json['niveau'] as String? ?? '',
      aValider: json['aValider'] as bool? ?? false,
      contenu: (json['contenu'] as List<dynamic>?)
              ?.map((b) => BlocContenu.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      exercices: (json['exercices'] as List<dynamic>?)
              ?.map((e) => Exercice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categorie': categorie,
      'titre': titre,
      'niveau': niveau,
      'aValider': aValider,
      'contenu': contenu.map((b) => b.toJson()).toList(),
      'exercices': exercices.map((e) => e.toJson()).toList(),
    };
  }

  String get categorieLibelle {
    switch (categorie) {
      case 'gram':
        return 'Grammaire';
      case 'conj':
        return 'Conjugaison';
      case 'orth':
        return 'Orthographe';
      case 'voc':
        return 'Vocabulaire';
      case 'style':
        return 'Style & Figures';
      case 'lecture':
      case 'analyse':
        return 'Lecture & Analyse';
      case 'recit':
        return 'Récit & Conte';
      case 'theatre':
        return 'Le Théâtre';
      case 'media':
        return 'Médias & Presse';
      case 'poesie':
        return 'Poésie';
      case 'methode':
      case 'ecrit':
        return 'Méthodologie';
      default:
        return 'Général';
    }
  }
}
