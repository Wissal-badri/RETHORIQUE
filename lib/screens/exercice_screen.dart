import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/exercice.dart';
import '../models/lecon.dart';
import '../services/correction_engine.dart';
import '../theme/app_theme.dart';
import 'correction_screen.dart';

class ExerciceScreen extends StatefulWidget {
  final Lecon lecon;
  final int exerciceIndex;

  const ExerciceScreen({
    super.key,
    required this.lecon,
    required this.exerciceIndex,
  });

  @override
  State<ExerciceScreen> createState() => _ExerciceScreenState();
}

class _ExerciceScreenState extends State<ExerciceScreen> {
  late Exercice _exercice;
  final Map<int, dynamic> _reponses = {};
  final Map<int, TextEditingController> _textControllers = {};
  // Pour association : Map<int, Map<String, String>> {questionIndex: {gauche: droite}}
  final Map<int, Map<String, String>> _associations = {};

  @override
  void initState() {
    super.initState();
    _exercice = widget.lecon.exercices[widget.exerciceIndex];
    for (int i = 0; i < _exercice.questions.length; i++) {
      if (_exercice.type == 'trous' || _exercice.type == 'transformation') {
        final ctrl = TextEditingController();
        ctrl.addListener(() {
          final text = ctrl.text.trim();
          setState(() {
            if (text.isNotEmpty) {
              _reponses[i] = text;
            } else {
              _reponses.remove(i);
            }
          });
        });
        _textControllers[i] = ctrl;
      }
    }
  }

  @override
  void dispose() {
    for (final ctrl in _textControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  int get _answeredCount => _reponses.length;
  int get _totalQuestions => _exercice.questions.length;

  void _onSelectOption(int questionIndex, dynamic value) {
    HapticFeedback.selectionClick();
    setState(() {
      _reponses[questionIndex] = value;
    });
  }

  void _onAssociationPick(int questionIndex, String gauche, String droite) {
    HapticFeedback.selectionClick();
    setState(() {
      _associations.putIfAbsent(questionIndex, () => {});
      _associations[questionIndex]![gauche] = droite;
      _reponses[questionIndex] = _associations[questionIndex];
    });
  }

  void _demanderCorrection() {
    HapticFeedback.mediumImpact();
    final nonRepondues = _totalQuestions - _answeredCount;
    if (nonRepondues > 0) {
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
              Icon(Icons.help_outline, color: AppColors.gold, size: 24),
              SizedBox(width: 8),
              Text(
                'Questions sans réponse',
                style: TextStyle(
                  fontFamily: AppTheme.fontTinos,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          content: Text(
            'Il reste $nonRepondues question${nonRepondues > 1 ? 's' : ''} sans réponse.\n\nSouhaitez-vous corriger quand même ?',
            style: const TextStyle(
              fontFamily: AppTheme.fontTinos,
              fontSize: 15,
              color: AppColors.ink,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Continuer l’exercice',
                style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _lancerCorrection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.white,
              ),
              child: const Text('Corriger quand même'),
            ),
          ],
        ),
      );
    } else {
      _lancerCorrection();
    }
  }

  void _lancerCorrection() {
    final result = CorrectionEngine.corrigerExercice(_exercice, _reponses);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CorrectionScreen(
          lecon: widget.lecon,
          exerciceIndex: widget.exerciceIndex,
          result: result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_exercice.titre),
      ),
      body: Column(
        children: [
          // Bandeau du haut : progression des réponses
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _exercice.consigne,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontTinos,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _totalQuestions > 0 ? _answeredCount / _totalQuestions : 0.0,
                          backgroundColor: AppColors.border.withOpacity(0.4),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold),
                  ),
                  child: Text(
                    '$_answeredCount / $_totalQuestions répondues',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des questions défilable (AUCUNE correction pendant qu'il répond : pas de vert ni de rouge)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              itemCount: _exercice.questions.length,
              itemBuilder: (context, index) {
                final q = _exercice.questions[index];
                final rep = _reponses[index];

                return _buildQuestionCard(index, q, rep);
              },
            ),
          ),

          // Grand bouton « Corriger » en bas
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: ElevatedButton(
                onPressed: _demanderCorrection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.gold, width: 1.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.done_all, color: AppColors.gold, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'CORRIGER L’EXERCICE',
                      style: TextStyle(
                        fontFamily: AppTheme.fontTinos,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int index, Question q, dynamic rep) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rep != null ? AppColors.gold : AppColors.border,
          width: rep != null ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Numéro et énoncé
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rep != null ? AppColors.navy : AppColors.border,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: rep != null ? Colors.white : AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  q.enonce,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontTinos,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Options de réponse selon le type
          if (_exercice.type == 'qcm' || _exercice.type == 'choix_dans_phrase')
            _buildQcmOptions(index, q, rep),
          if (_exercice.type == 'vrai_faux')
            _buildVraiFauxOptions(index, rep),
          if (_exercice.type == 'trous' || _exercice.type == 'transformation')
            _buildTextInput(index),
          if (_exercice.type == 'association')
            _buildAssociation(index, q),
        ],
      ),
    );
  }

  Widget _buildQcmOptions(int index, Question q, dynamic rep) {
    final options = q.options ?? [];

    return Column(
      children: options.asMap().entries.map((entry) {
        final optIdx = entry.key;
        final optText = entry.value;
        final isSelected = rep == optIdx;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: InkWell(
            onTap: () => _onSelectOption(index, optIdx),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                // Couleur sobre sans vert ni rouge pendant l'exercice
                color: isSelected ? AppColors.card : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.navy : AppColors.border,
                  width: isSelected ? 1.6 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.navy : AppColors.border,
                        width: 2,
                      ),
                      color: isSelected ? AppColors.navy : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optText,
                      style: TextStyle(
                        fontFamily: AppTheme.fontTinos,
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.navy : AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVraiFauxOptions(int index, dynamic rep) {
    return Row(
      children: [
        Expanded(
          child: _buildSimpleButton(
            label: 'Vrai',
            isSelected: rep == true,
            onTap: () => _onSelectOption(index, true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSimpleButton(
            label: 'Faux',
            isSelected: rep == false,
            onTap: () => _onSelectOption(index, false),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.card : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.navy : AppColors.border,
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.fontTinos,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.navy : AppColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(int index) {
    final ctrl = _textControllers[index];

    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: 'Tapez votre réponse ici...',
        hintStyle: TextStyle(
          fontFamily: AppTheme.fontTinos,
          fontSize: 14,
          color: AppColors.ink.withOpacity(0.4),
        ),
        filled: true,
        fillColor: AppColors.card.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      style: const TextStyle(
        fontFamily: AppTheme.fontTinos,
        fontSize: 15,
        color: AppColors.ink,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildAssociation(int index, Question q) {
    final paires = q.paires ?? [];
    final assocMap = _associations[index] ?? {};
    final droites = paires.map((p) => p.droite).toList();

    return Column(
      children: paires.map((p) {
        final selectedRight = assocMap[p.gauche];

        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  p.gauche,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navy),
                ),
              ),
              const Icon(Icons.arrow_right_alt, color: AppColors.gold, size: 20),
              const SizedBox(width: 6),
              Expanded(
                flex: 5,
                child: DropdownButtonFormField<String>(
                  value: selectedRight,
                  hint: const Text('Choisir...', style: TextStyle(fontSize: 12)),
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: droites.map((d) {
                    return DropdownMenuItem(
                      value: d,
                      child: Text(d, style: const TextStyle(fontSize: 12, color: AppColors.ink)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      _onAssociationPick(index, p.gauche, val);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
