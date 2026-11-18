import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PhraseComplexeWidget extends StatelessWidget {
  const PhraseComplexeWidget({super.key});

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
              Icon(Icons.hub_outlined, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Structure de la Phrase Complexe',
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
          // Exemple visuel interactif en blocs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bloc 1 : Proposition Principale
                _buildBloc(
                  titre: 'PROPOSITION PRINCIPALE',
                  texte: '« Le professeur explique »',
                  sousTitre: 'Verbe 1 (explique)',
                  couleurFond: AppColors.navy,
                  couleurTexte: Colors.white,
                ),
                // Connecteur / Conjonction
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_forward, color: AppColors.gold, size: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: const Text(
                          'pour que\n(conjonction)',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.gold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bloc 2 : Proposition Subordonnée
                _buildBloc(
                  titre: 'PROPOSITION SUBORDONNÉE',
                  texte: '« les élèves réussissent »',
                  sousTitre: 'Verbe 2 au subjonctif',
                  couleurFond: AppColors.card,
                  couleurTexte: AppColors.navy,
                  bordure: AppColors.gold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              '💡 Règle d’or : Une phrase contient autant de propositions que de verbes conjugués. La proposition subordonnée dépend toujours de la principale et ne peut pas former une phrase autonome.',
              style: TextStyle(fontSize: 12, color: AppColors.ink, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloc({
    required String titre,
    required String texte,
    required String sousTitre,
    required Color couleurFond,
    required Color couleurTexte,
    Color? bordure,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: couleurFond,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: bordure ?? AppColors.border, width: bordure != null ? 1.5 : 1.0),
      ),
      child: Column(
        children: [
          Text(
            titre,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: couleurTexte.withOpacity(0.9)),
          ),
          const SizedBox(height: 6),
          Text(
            texte,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: couleurTexte,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sousTitre,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: couleurTexte.withOpacity(0.75)),
          ),
        ],
      ),
    );
  }
}
