import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SchemaFonctionsWidget extends StatelessWidget {
  const SchemaFonctionsWidget({super.key});

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
              Icon(Icons.segment, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Analyse Syntaxique des Fonctions',
                style: TextStyle(
                  fontFamily: AppTheme.fontTinos,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Phrase étiquetée
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupe(
                  texte: 'Hier,',
                  fonction: 'CC de Temps',
                  question: 'Quand ?',
                  couleur: const Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                _buildGroupe(
                  texte: 'Sara',
                  fonction: 'Sujet',
                  question: 'Qui est-ce qui ?',
                  couleur: AppColors.navy,
                ),
                const SizedBox(width: 8),
                _buildGroupe(
                  texte: 'a offert',
                  fonction: 'Verbe',
                  question: 'Action',
                  couleur: AppColors.gold,
                  isVerb: true,
                ),
                const SizedBox(width: 8),
                _buildGroupe(
                  texte: 'un livre',
                  fonction: 'COD',
                  question: 'Quoi ? (direct)',
                  couleur: AppColors.success,
                ),
                const SizedBox(width: 8),
                _buildGroupe(
                  texte: 'à son frère.',
                  fonction: 'COI',
                  question: 'À qui ? (indirect)',
                  couleur: const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '💡 Astuce : Les compléments circonstanciels sont déplaçables et supprimables. Le COD est rattaché directement au verbe, le COI par une préposition (à ou de).',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupe({
    required String texte,
    required String fonction,
    required String question,
    required Color couleur,
    bool isVerb = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: couleur, width: 1.2),
      ),
      child: Column(
        children: [
          Text(
            texte,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isVerb ? AppColors.gold : AppColors.ink,
              fontStyle: isVerb ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 50,
            color: couleur,
          ),
          const SizedBox(height: 4),
          Text(
            fonction,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: couleur,
            ),
          ),
          Text(
            question,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.ink.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
