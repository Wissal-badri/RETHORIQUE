import '../models/exercice.dart';

class QuestionResult {
  final Question question;
  final dynamic reponseEleve;
  final bool estCorrect;
  final String bonneReponseAffichee;
  final String reponseEleveAffichee;

  QuestionResult({
    required this.question,
    required this.reponseEleve,
    required this.estCorrect,
    required this.bonneReponseAffichee,
    required this.reponseEleveAffichee,
  });
}

class ExerciceResult {
  final Exercice exercice;
  final List<QuestionResult> details;
  final int score;
  final int total;
  final double pourcentage;

  ExerciceResult({
    required this.exercice,
    required this.details,
    required this.score,
    required this.total,
    required this.pourcentage,
  });

  bool get estParfait => score == total && total > 0;
  bool get estReussi => pourcentage >= 80.0;
}

class CorrectionEngine {
  /// Normalisation pour les textes à trous et transformations :
  /// - Ignore les espaces superflus (trim & collapse multiple spaces)
  /// - Ignore la casse (toLowerCase)
  /// - Traite ’ (apostrophe typographique) et ' (apostrophe droite) comme identiques
  /// - Conserve les accents français (é, è, ê, à, ç, etc.) car essentiels en orthographe
  /// - Ignore le point final optionnel
  static String normaliserTexte(String? input) {
    if (input == null) return '';
    String res = input.trim();
    // Remplacer apostrophe typographique par droite
    res = res.replaceAll('’', "'");
    // Remplacer espaces insécables
    res = res.replaceAll('\u00A0', ' ');
    // Réduire les espaces multiples en un seul
    res = res.replaceAll(RegExp(r'\s+'), ' ');
    // Supprimer le point final éventuel
    if (res.endsWith('.')) {
      res = res.substring(0, res.length - 1).trim();
    }
    return res.toLowerCase();
  }

  /// Normalisation stricte sans accents si besoin de recherche
  static String normaliserSansAccents(String s) {
    String str = s.toLowerCase();
    const withAccents = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
    const withoutAccents = 'aaaaaaceeeeiiiinooooouuuuyy';
    for (int i = 0; i < withAccents.length; i++) {
      str = str.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return str;
  }

  /// Évalue une question unique
  static QuestionResult corrigerQuestion(Question q, dynamic reponseEleve, String typeExercice) {
    bool estCorrect = false;
    String bonneRepAffichee = '';
    String repEleveAffichee = '';

    switch (typeExercice) {
      case 'qcm':
      case 'choix_dans_phrase':
        final int? indexEleve = reponseEleve is int ? reponseEleve : null;
        final int indexBonne = (q.reponse is int)
            ? q.reponse as int
            : int.tryParse(q.reponse.toString()) ?? -1;

        estCorrect = (indexEleve != null && indexEleve == indexBonne);

        if (q.options != null && indexBonne >= 0 && indexBonne < q.options!.length) {
          bonneRepAffichee = q.options![indexBonne];
        } else {
          bonneRepAffichee = indexBonne.toString();
        }

        if (indexEleve != null && q.options != null && indexEleve >= 0 && indexEleve < q.options!.length) {
          repEleveAffichee = q.options![indexEleve];
        } else if (indexEleve != null) {
          repEleveAffichee = indexEleve.toString();
        } else {
          repEleveAffichee = 'Aucune réponse';
        }
        break;

      case 'vrai_faux':
        final bool? boolEleve = reponseEleve is bool ? reponseEleve : null;
        final bool boolBonne = (q.reponse is bool)
            ? q.reponse as bool
            : q.reponse.toString().toLowerCase() == 'true';

        estCorrect = (boolEleve != null && boolEleve == boolBonne);
        bonneRepAffichee = boolBonne ? 'Vrai' : 'Faux';
        repEleveAffichee = boolEleve == null
            ? 'Aucune réponse'
            : (boolEleve ? 'Vrai' : 'Faux');
        break;

      case 'trous':
      case 'transformation':
        final String texteEleve = reponseEleve?.toString() ?? '';
        final String normEleve = normaliserTexte(texteEleve);
        final String bonneNorm = normaliserTexte(q.reponse?.toString());

        final List<String> accepteesNorm = (q.acceptees ?? [])
            .map((a) => normaliserTexte(a))
            .toList();
        if (!accepteesNorm.contains(bonneNorm)) {
          accepteesNorm.add(bonneNorm);
        }

        estCorrect = normEleve.isNotEmpty && accepteesNorm.contains(normEleve);
        bonneRepAffichee = q.reponse?.toString() ?? '';
        repEleveAffichee = texteEleve.trim().isEmpty ? 'Aucune réponse' : texteEleve.trim();
        break;

      case 'association':
        // Pour association, reponseEleve est une Map<String, String> {gauche: droite}
        final Map<String, String>? mapEleve = reponseEleve is Map
            ? (reponseEleve as Map).map((k, v) => MapEntry(k.toString(), v.toString()))
            : null;

        int pairsCorrect = 0;
        int totalPairs = q.paires?.length ?? 0;
        if (mapEleve != null && totalPairs > 0) {
          for (final paire in q.paires!) {
            final String? assocEleve = mapEleve[paire.gauche];
            if (assocEleve != null &&
                normaliserTexte(assocEleve) == normaliserTexte(paire.droite)) {
              pairsCorrect++;
            }
          }
        }
        estCorrect = (pairsCorrect == totalPairs && totalPairs > 0);
        bonneRepAffichee = q.paires
                ?.map((p) => '${p.gauche} ➔ ${p.droite}')
                .join(' | ') ??
            '';
        repEleveAffichee = mapEleve != null && mapEleve.isNotEmpty
            ? mapEleve.entries.map((e) => '${e.key} ➔ ${e.value}').join(' | ')
            : 'Aucune association';
        break;

      default:
        estCorrect = false;
        bonneRepAffichee = q.reponse.toString();
        repEleveAffichee = reponseEleve?.toString() ?? 'Aucune réponse';
    }

    return QuestionResult(
      question: q,
      reponseEleve: reponseEleve,
      estCorrect: estCorrect,
      bonneReponseAffichee: bonneRepAffichee,
      reponseEleveAffichee: repEleveAffichee,
    );
  }

  /// Évalue un exercice complet à partir d'une map de réponses {questionIndex: reponse}
  static ExerciceResult corrigerExercice(
      Exercice exercice, Map<int, dynamic> reponsesEleve) {
    final List<QuestionResult> details = [];
    int score = 0;

    for (int i = 0; i < exercice.questions.length; i++) {
      final q = exercice.questions[i];
      final rep = reponsesEleve[i];
      final res = corrigerQuestion(q, rep, exercice.type);
      details.add(res);
      if (res.estCorrect) {
        score++;
      }
    }

    final int total = exercice.questions.length;
    final double pct = total > 0 ? (score / total) * 100.0 : 0.0;

    return ExerciceResult(
      exercice: exercice,
      details: details,
      score: score,
      total: total,
      pourcentage: pct,
    );
  }
}
