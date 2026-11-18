import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ArbreParticipePasseWidget extends StatefulWidget {
  const ArbreParticipePasseWidget({super.key});

  @override
  State<ArbreParticipePasseWidget> createState() => _ArbreParticipePasseWidgetState();
}

class _ArbreParticipePasseWidgetState extends State<ArbreParticipePasseWidget> {
  String? _choixAuxiliaire; // 'etre' ou 'avoir'
  String? _choixCodAvant; // 'oui' ou 'non'

  void _reset() {
    setState(() {
      _choixAuxiliaire = null;
      _choixCodAvant = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.account_tree_outlined, color: AppColors.gold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Arbre de décision : Accord du Participe Passé',
                    style: TextStyle(
                      fontFamily: AppTheme.fontTinos,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              if (_choixAuxiliaire != null)
                TextButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, size: 16, color: AppColors.gold),
                  label: const Text('Recommencer', style: TextStyle(color: AppColors.gold, fontSize: 13)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Touche les étapes pour découvrir la règle d’accord applicable à ta phrase :',
            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.ink),
          ),
          const SizedBox(height: 16),

          // Étape 1 : Quel est l'auxiliaire ?
          _buildCard(
            etape: '1',
            question: 'Quel est l’auxiliaire utilisé avec le participe passé ?',
            content: Row(
              children: [
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Auxiliaire ÊTRE',
                    isSelected: _choixAuxiliaire == 'etre',
                    onTap: () {
                      setState(() {
                        _choixAuxiliaire = 'etre';
                        _choixCodAvant = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildChoiceButton(
                    label: 'Auxiliaire AVOIR',
                    isSelected: _choixAuxiliaire == 'avoir',
                    onTap: () {
                      setState(() {
                        _choixAuxiliaire = 'avoir';
                        _choixCodAvant = null;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Résultat ÊTRE
          if (_choixAuxiliaire == 'etre') ...[
            const SizedBox(height: 12),
            _buildResultCard(
              regle: '✅ ACCORD AVEC LE SUJET',
              explication:
                  'Le participe passé s’accorde en genre (féminin -e) et en nombre (pluriel -s) avec le sujet de la phrase.',
              exemple: '« Elles sont parties hier. » (Elles = fém. pl. ➔ parties)',
            ),
          ],

          // Étape 2 AVOIR : Y a-t-il un COD placé avant ?
          if (_choixAuxiliaire == 'avoir') ...[
            const SizedBox(height: 12),
            _buildCard(
              etape: '2',
              question: 'Y a-t-il un Complément d’Objet Direct (COD) placé AVANT le verbe ?',
              content: Row(
                children: [
                  Expanded(
                    child: _buildChoiceButton(
                      label: 'OUI (COD avant)',
                      isSelected: _choixCodAvant == 'oui',
                      onTap: () {
                        setState(() => _choixCodAvant = 'oui');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildChoiceButton(
                      label: 'NON (COD après ou aucun)',
                      isSelected: _choixCodAvant == 'non',
                      onTap: () {
                        setState(() => _choixCodAvant = 'non');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Résultat AVOIR + COD OUI
          if (_choixAuxiliaire == 'avoir' && _choixCodAvant == 'oui') ...[
            const SizedBox(height: 12),
            _buildResultCard(
              regle: '✅ ACCORD AVEC LE COD PLACÉ AVANT',
              explication:
                  'Le participe passé s’accorde en genre et en nombre avec ce COD (souvent un pronom relatif "que", un pronom personnel "les", "l’", ou une tournure interrogative).',
              exemple: '« Les fleurs que Sara a cueillies. » (COD "que" = les fleurs, fém. pl. ➔ cueillies)',
            ),
          ],

          // Résultat AVOIR + COD NON
          if (_choixAuxiliaire == 'avoir' && _choixCodAvant == 'non') ...[
            const SizedBox(height: 12),
            _buildResultCard(
              regle: '❌ INVARIABLE (AUCUN ACCORD)',
              explication:
                  'Si le COD est placé après le verbe, ou s’il n’y a pas de COD, le participe passé reste invariable.',
              exemple: '« Sara a cueilli des fleurs. » (COD "des fleurs" placé après ➔ cueilli invariable)',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({required String etape, required String question, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: AppColors.navy,
                child: Text(
                  etape,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          content,
        ],
      ),
    );
  }

  Widget _buildChoiceButton({required String label, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({required String regle, required String explication, required String exemple}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6EC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            regle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.gold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(explication, style: const TextStyle(fontSize: 12, color: AppColors.ink, height: 1.4)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              exemple,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}
