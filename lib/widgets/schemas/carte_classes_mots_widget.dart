import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CarteClassesMotsWidget extends StatelessWidget {
  const CarteClassesMotsWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.category_outlined, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Les 10 Classes Grammaticales',
                style: TextStyle(
                  fontFamily: AppTheme.fontTinos,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonne 1 : Variables (5)
              Expanded(
                child: _buildColumn(
                  titre: '5 VARIABLES\n(s’accordent)',
                  couleurTitre: AppColors.navy,
                  elements: [
                    '1. Nom (Sara, livre)',
                    '2. Déterminant (le, un, ces)',
                    '3. Adjectif (beau, grand)',
                    '4. Pronom (il, nous, qui)',
                    '5. Verbe (marcher, être)',
                  ],
                  bgCard: AppColors.card,
                ),
              ),
              const SizedBox(width: 12),
              // Colonne 2 : Invariables (5)
              Expanded(
                child: _buildColumn(
                  titre: '5 INVARIABLES\n(ne changent jamais)',
                  couleurTitre: AppColors.gold,
                  elements: [
                    '6. Adverbe (vite, hier)',
                    '7. Préposition (à, de, pour)',
                    '8. Conj. coordination (mais, car)',
                    '9. Conj. subordination (que, si)',
                    '10. Interjection (Hélas ! Bravo !)',
                  ],
                  bgCard: const Color(0xFFFBF6EC),
                  borderGold: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColumn({
    required String titre,
    required Color couleurTitre,
    required List<String> elements,
    required Color bgCard,
    bool borderGold = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderGold ? AppColors.gold : AppColors.border,
          width: borderGold ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titre,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: couleurTitre,
              height: 1.2,
            ),
          ),
          const Divider(color: AppColors.border, height: 16),
          ...elements.map((el) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0),
                child: Text(
                  el,
                  style: const TextStyle(fontSize: 11, color: AppColors.ink, height: 1.3),
                ),
              )),
        ],
      ),
    );
  }
}
