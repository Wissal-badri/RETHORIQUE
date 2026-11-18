import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lecon.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/circular_progress_gold.dart';
import '../widgets/ornament_divider.dart';

class BilanLeconScreen extends StatelessWidget {
  final Lecon lecon;

  const BilanLeconScreen({super.key, required this.lecon});

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);

    int totalScore = 0;
    int maxPossible = 0;

    final List<Map<String, dynamic>> exScores = [];
    for (final ex in lecon.exercices) {
      final s = storage.getBestScore(ex.id);
      final t = storage.getExerciseTotal(ex.id) > 0 ? storage.getExerciseTotal(ex.id) : ex.questions.length;
      totalScore += s;
      maxPossible += t;
      exScores.add({
        'titre': ex.titre,
        'score': s,
        'total': t,
        'pct': t > 0 ? (s / t) * 100.0 : 0.0,
      });
    }

    final double pctGlobal = maxPossible > 0 ? (totalScore / maxPossible) * 100.0 : 0.0;
    final bool reussi = pctGlobal >= 80.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bilan de la leçon'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  CircularProgressGold(
                    percentage: pctGlobal,
                    size: 80,
                    strokeWidth: 6,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    lecon.titre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reussi
                        ? 'Félicitations ! Vous avez validé cette leçon.'
                        : 'Leçon complétée. Vous pouvez vous entraîner pour perfectionner votre score.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 14,
                      color: reussi ? AppColors.success : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const OrnamentDivider(symbol: '✦', width: 200),
            const SizedBox(height: 10),

            const Text(
              'RÉCAPITULATIF PAR EXERCICE',
              style: TextStyle(
                fontFamily: AppTheme.fontTinos,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 12),

            ...exScores.map((item) {
              final pct = item['pct'] as double;
              final Color col = pct >= 80.0
                  ? AppColors.success
                  : (pct >= 50.0 ? AppColors.warning : AppColors.error);

              return Container(
                margin: const EdgeInsets.only(bottom: 10.0),
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['titre'] as String,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontTinos,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: col, width: 1.5),
                      ),
                      child: Text(
                        '${item['score']} / ${item['total']} (${pct.toInt()}%)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: col,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Retour à la liste des leçons
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('RETOUR À LA LISTE DES LEÇONS'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
