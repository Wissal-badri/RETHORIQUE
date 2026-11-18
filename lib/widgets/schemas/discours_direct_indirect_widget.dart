import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class DiscoursDirectIndirectWidget extends StatelessWidget {
  const DiscoursDirectIndirectWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final transpositionsTemps = [
      ('Présent', 'Imparfait', '« Je viens » ➔ Il disait qu’il venait'),
      ('Passé composé', 'Plus-que-parfait', '« J’ai fini » ➔ ... qu’il avait fini'),
      ('Futur simple', 'Conditionnel présent', '« Je partirai » ➔ ... qu’il partirait'),
      ('Futur antérieur', 'Conditionnel passé', '« J’aurai lu » ➔ ... qu’il aurait lu'),
      ('Impératif', 'De + Infinitif', '« Écoute ! » ➔ Il lui dit d’écouter'),
    ];

    final transpositionsTempsEspace = [
      ('Aujourd’hui', 'Ce jour-là'),
      ('Hier', 'La veille'),
      ('Demain', 'Le lendemain'),
      ('Ici', 'Là / Là-bas'),
      ('Maintenant', 'Alors / À ce moment-là'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.compare, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Transposition au Discours Indirect (Verbe au Passé)',
                style: TextStyle(
                  fontFamily: AppTheme.fontTinos,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Concordance des temps :',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gold),
          ),
          const SizedBox(height: 8),
          ...transpositionsTemps.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.$1,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.navy),
                      ),
                    ),
                    const Icon(Icons.arrow_right_alt, color: AppColors.gold, size: 18),
                    Expanded(
                      flex: 4,
                      child: Text(
                        item.$2,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.gold),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          const Text(
            'Repères de temps et d’espace :',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: transpositionsTempsEspace.map((p) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${p.$1} ➔ ${p.$2}',
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.ink),
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }
}
