import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ornament_divider.dart';

class AProposScreen extends StatelessWidget {
  const AProposScreen({super.key});

  void _confirmerReinitialisation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 26),
            SizedBox(width: 8),
            Text(
              'Réinitialisation',
              style: TextStyle(
                fontFamily: AppTheme.fontTinos,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        content: const Text(
          'Voulez-vous vraiment effacer tous vos scores et votre progression enregistrée ? Cette action est irréversible.',
          style: TextStyle(
            fontFamily: AppTheme.fontTinos,
            fontSize: 15,
            color: AppColors.ink,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: AppColors.navy)),
          ),
          ElevatedButton(
            onPressed: () async {
              final storage = Provider.of<StorageService>(context, listen: false);
              await storage.resetAllProgress();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progression réinitialisée avec succès.'),
                    backgroundColor: AppColors.navy,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Oui, réinitialiser'),
          ),
        ],
      ),
    );
  }

  void _ouvrirConnexionProfesseur(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.school, color: AppColors.gold),
            SizedBox(width: 8),
            Text(
              'Mode Professeur',
              style: TextStyle(fontFamily: AppTheme.fontTinos, fontWeight: FontWeight.bold, color: AppColors.navy),
            ),
          ],
        ),
        content: const Text(
          'Accès réservé à l’enseignant. Ce module sera raccordé lors de l’étape back-end (Supabase Auth & IA).',
          style: TextStyle(fontFamily: AppTheme.fontTinos, fontSize: 14, color: AppColors.ink),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Appui long secret sur le titre calligraphique pour le mode professeur
            GestureDetector(
              onLongPress: () => _ouvrirConnexionProfesseur(context),
              child: Column(
                children: const [
                  Text(
                    'Rhétorique',
                    style: TextStyle(
                      fontFamily: AppTheme.fontPinyon,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '« L’art de Molière »',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppColors.gold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Version 1.0.0 — Édition Classique',
                    style: TextStyle(fontSize: 12, color: AppColors.ink, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const OrnamentDivider(symbol: '❦', width: 200),

            // Origine du mot
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'L’ORIGINE DU MOT',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: AppColors.gold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Le nom vient du grec rhêtorikê : l’art de bien parler, bien écrire et convaincre avec élégance et rigueur.\n\n'
                    'Autrefois, la « classe de rhétorique » couronnait le parcours des humanités classiques. Elle était la dernière et la plus prestigieuse année d’études, celle où l’élève devenait véritablement maître de la langue et de l’éloquence.\n\n'
                    'Cette application s’inscrit dans cette haute tradition d’excellence.',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 14.5,
                      color: AppColors.ink,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Auteur & Établissement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold, width: 1.2),
              ),
              child: Column(
                children: const [
                  Icon(Icons.menu_book, color: AppColors.gold, size: 28),
                  SizedBox(height: 8),
                  Text(
                    'BADRI Chakib',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Professeur de français',
                    style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.ink),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Groupe Scolaire Jean-Henri Lambert\nCasablanca, Maroc',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bouton de réinitialisation de la progression
            OutlinedButton.icon(
              onPressed: () => _confirmerReinitialisation(context),
              icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error, size: 20),
              label: const Text(
                'Réinitialiser ma progression',
                style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 32),

            // Pied de page obligatoire
            const Text(
              '© BADRI Chakib, professeur de français\nGroupe Scolaire Jean-Henri Lambert, Casablanca',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontTinos,
                fontSize: 12,
                color: AppColors.ink,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
