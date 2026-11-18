import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/lecon.dart';
import '../services/correction_engine.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ornament_divider.dart';
import 'bilan_lecon_screen.dart';
import 'exercice_screen.dart';

class CorrectionScreen extends StatefulWidget {
  final Lecon lecon;
  final int exerciceIndex;
  final ExerciceResult result;

  const CorrectionScreen({
    super.key,
    required this.lecon,
    required this.exerciceIndex,
    required this.result,
  });

  @override
  State<CorrectionScreen> createState() => _CorrectionScreenState();
}

class _CorrectionScreenState extends State<CorrectionScreen> {
  bool _voirToutesReponses = false;

  @override
  void initState() {
    super.initState();
    _saveProgress();
  }

  Future<void> _saveProgress() async {
    final storage = Provider.of<StorageService>(context, listen: false);
    await storage.saveScore(
      exerciceId: widget.result.exercice.id,
      leconId: widget.lecon.id,
      score: widget.result.score,
      total: widget.result.total,
    );
  }

  Color get _scoreColor {
    if (widget.result.pourcentage >= 80.0) return AppColors.success;
    if (widget.result.pourcentage >= 50.0) return AppColors.warning;
    return AppColors.error;
  }

  String get _appreciationMessage {
    if (widget.result.estParfait) return 'Excellence ! Perfection classique.';
    if (widget.result.pourcentage >= 80.0) return 'Très bien ! Bel art de la langue.';
    if (widget.result.pourcentage >= 50.0) return 'Bien, mais revois quelques règles du cours.';
    return 'Relis attentivement la leçon et recommence.';
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final fautes = widget.result.details.where((d) => !d.estCorrect).toList();
    final bool hasNextExercise = widget.exerciceIndex + 1 < widget.lecon.exercices.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Résultats & Correction'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Score en grand
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _scoreColor, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: _scoreColor.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (widget.result.estParfait) ...[
                    const Icon(Icons.workspace_premium, color: AppColors.gold, size: 48),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    '${widget.result.score} / ${widget.result.total}',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: _scoreColor,
                    ),
                  ),
                  Text(
                    '${widget.result.pourcentage.toInt()} %',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _scoreColor.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _appreciationMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section "Tes erreurs" (si des fautes existent)
            if (fautes.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'TES ERREURS (${fautes.length})',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...fautes.map((item) => _buildDetailCard(item, false)),
              const SizedBox(height: 16),
            ] else ...[
              // Si tout est juste : félicitations et révision complète
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F6F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.success, width: 1.2),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Toutes vos réponses sont exactes ! Retrouvez ci-dessous le rappel des règles pour parfaire votre révision.',
                        style: TextStyle(
                          fontFamily: AppTheme.fontTinos,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Bouton « Voir toutes les réponses »
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _voirToutesReponses = !_voirToutesReponses;
                });
              },
              icon: Icon(
                _voirToutesReponses ? Icons.expand_less : Icons.expand_more,
                color: AppColors.navy,
              ),
              label: Text(
                _voirToutesReponses
                    ? 'Masquer la correction complète'
                    : 'Voir toutes les réponses et explications',
                style: const TextStyle(
                  fontFamily: AppTheme.fontTinos,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ),
            const SizedBox(height: 14),

            if (_voirToutesReponses) ...[
              ...widget.result.details.map((item) => _buildDetailCard(item, true)),
              const SizedBox(height: 16),
            ],

            const OrnamentDivider(symbol: '❦', width: 180),
            const SizedBox(height: 10),

            // Boutons d'actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExerciceScreen(
                            lecon: widget.lecon,
                            exerciceIndex: widget.exerciceIndex,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Recommencer'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (hasNextExercise) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExerciceScreen(
                              lecon: widget.lecon,
                              exerciceIndex: widget.exerciceIndex + 1,
                            ),
                          ),
                        );
                      } else {
                        // Tous les exercices de la leçon sont terminés : Bilan de la leçon
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BilanLeconScreen(lecon: widget.lecon),
                          ),
                        );
                      }
                    },
                    icon: Icon(hasNextExercise ? Icons.arrow_forward : Icons.assignment_turned_in),
                    label: Text(hasNextExercise ? 'Exercice suivant' : 'Bilan de la leçon'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Retour à la leçon
                },
                icon: const Icon(Icons.arrow_back, size: 16, color: AppColors.gold),
                label: const Text(
                  'Retour au cours de la leçon',
                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(QuestionResult item, bool showAllMode) {
    final bool correct = item.estCorrect;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: correct ? AppColors.success.withOpacity(0.5) : AppColors.error.withOpacity(0.5),
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                correct ? Icons.check_circle : Icons.cancel,
                color: correct ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.question.enonce,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontTinos,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Réponse de l'élève
          if (!correct)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: '❌ Votre réponse : ',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.error, fontSize: 13),
                    ),
                    TextSpan(
                      text: item.reponseEleveAffichee,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bonne réponse
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '✅ Bonne réponse : ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 13),
                ),
                TextSpan(
                  text: item.bonneReponseAffichee,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Explication pédagogique
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡 ', style: TextStyle(fontSize: 15)),
                Expanded(
                  child: Text(
                    item.question.explication,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 13,
                      color: AppColors.ink,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
