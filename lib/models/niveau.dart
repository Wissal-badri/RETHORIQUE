import 'lecon.dart';

class Niveau {
  final String code;
  final String nom;
  final String description;
  final List<Lecon> lecons;

  Niveau({
    required this.code,
    required this.nom,
    required this.description,
    required this.lecons,
  });

  factory Niveau.fromJson(Map<String, dynamic> json) {
    return Niveau(
      code: json['code'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      description: json['description'] as String? ?? '',
      lecons: (json['lecons'] as List<dynamic>?)
              ?.map((item) => Lecon.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'nom': nom,
      'description': description,
      'lecons': lecons.map((l) => l.toJson()).toList(),
    };
  }
}
