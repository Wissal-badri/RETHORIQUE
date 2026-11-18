import 'package:flutter_test/flutter_test.dart';
import 'package:rhetorique/models/exercice.dart';
import 'package:rhetorique/services/correction_engine.dart';

void main() {
  group('CorrectionEngine - Normalisation du texte', () {
    test('Ignore la casse et les espaces superflus', () {
      expect(CorrectionEngine.normaliserTexte('   Arrivées  '), equals('arrivées'));
      expect(CorrectionEngine.normaliserTexte('ARRIVÉES'), equals('arrivées'));
    });

    test('Traite l’apostrophe typographique et droite de façon identique', () {
      expect(CorrectionEngine.normaliserTexte("qu’il aime"), equals("qu'il aime"));
      expect(CorrectionEngine.normaliserTexte("qu'il aime"), equals("qu'il aime"));
    });

    test('Conserve rigoureusement les accents pour l’orthographe', () {
      expect(CorrectionEngine.normaliserTexte('arrivé'), isNot(equals('arrive')));
      expect(CorrectionEngine.normaliserTexte('à'), isNot(equals('a')));
      expect(CorrectionEngine.normaliserTexte('français'), equals('français'));
    });
  });

  group('CorrectionEngine - Types d’exercices', () {
    test('Correction QCM par index', () {
      final q = Question(
        enonce: '« Rapidement » est un…',
        options: ['nom', 'adverbe', 'adjectif'],
        reponse: 1,
        explication: 'Adverbe invariable',
      );

      final resBon = CorrectionEngine.corrigerQuestion(q, 1, 'qcm');
      expect(resBon.estCorrect, isTrue);

      final resFaux = CorrectionEngine.corrigerQuestion(q, 0, 'qcm');
      expect(resFaux.estCorrect, isFalse);
      expect(resFaux.bonneReponseAffichee, equals('adverbe'));
    });

    test('Correction Vrai/Faux booléen', () {
      final q = Question(
        enonce: 'La préposition est variable.',
        reponse: false,
        explication: 'Invariable',
      );

      final res1 = CorrectionEngine.corrigerQuestion(q, false, 'vrai_faux');
      expect(res1.estCorrect, isTrue);

      final res2 = CorrectionEngine.corrigerQuestion(q, true, 'vrai_faux');
      expect(res2.estCorrect, isFalse);
    });

    test('Correction Trous avec variantes acceptées', () {
      final q = Question(
        enonce: 'Les filles sont (arriver) ___',
        reponse: 'arrivées',
        acceptees: ['arrivées', 'arrivees'],
        explication: 'Accord avec être',
      );

      final res1 = CorrectionEngine.corrigerQuestion(q, '  arrivées  ', 'trous');
      expect(res1.estCorrect, isTrue);

      final res2 = CorrectionEngine.corrigerQuestion(q, 'Arrivées', 'trous');
      expect(res2.estCorrect, isTrue);

      final res3 = CorrectionEngine.corrigerQuestion(q, 'parti', 'trous');
      expect(res3.estCorrect, isFalse);
    });

    test('Calcul du score d’exercice complet', () {
      final ex = Exercice(
        id: 'test-ex',
        titre: 'Test',
        consigne: 'Consigne',
        type: 'qcm',
        questions: [
          Question(enonce: 'Q1', options: ['A', 'B'], reponse: 0, explication: 'E1'),
          Question(enonce: 'Q2', options: ['A', 'B'], reponse: 1, explication: 'E2'),
          Question(enonce: 'Q3', options: ['A', 'B'], reponse: 0, explication: 'E3'),
          Question(enonce: 'Q4', options: ['A', 'B'], reponse: 1, explication: 'E4'),
          Question(enonce: 'Q5', options: ['A', 'B'], reponse: 0, explication: 'E5'),
        ],
      );

      final reponses = {0: 0, 1: 1, 2: 0, 3: 1, 4: 0}; // 5/5
      final bilan = CorrectionEngine.corrigerExercice(ex, reponses);

      expect(bilan.score, equals(5));
      expect(bilan.total, equals(5));
      expect(bilan.pourcentage, equals(100.0));
      expect(bilan.estParfait, isTrue);
      expect(bilan.estReussi, isTrue);
    });
  });
}
