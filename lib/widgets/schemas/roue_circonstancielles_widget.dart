import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RoueCirconstanciellesWidget extends StatefulWidget {
  const RoueCirconstanciellesWidget({super.key});

  @override
  State<RoueCirconstanciellesWidget> createState() => _RoueCirconstanciellesWidgetState();
}

class _RoueCirconstanciellesWidgetState extends State<RoueCirconstanciellesWidget> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _valeurs = [
    {
      'nom': 'Cause',
      'conjonctions': 'parce que, puisque, comme, car, étant donné que',
      'mode': 'Indicatif',
      'exemple': 'Comme il pleuvait, nous sommes restés à la maison.',
      'icone': Icons.help_outline,
    },
    {
      'nom': 'Conséquence',
      'conjonctions': 'si bien que, de sorte que, tellement… que',
      'mode': 'Indicatif (ou subjonctif avec négation)',
      'exemple': 'Il a tant couru qu’il est essoufflé.',
      'icone': Icons.arrow_circle_right_outlined,
    },
    {
      'nom': 'But',
      'conjonctions': 'pour que, afin que, de peur que',
      'mode': 'Toujours le Subjonctif',
      'exemple': 'Le maître répète afin que chacun comprenne.',
      'icone': Icons.flag_outlined,
    },
    {
      'nom': 'Temps',
      'conjonctions': 'quand, lorsque, dès que, avant que, après que',
      'mode': 'Indicatif (Subjonctif après "avant que")',
      'exemple': 'Dès que tu arriveras, appelle-moi.',
      'icone': Icons.access_time,
    },
    {
      'nom': 'Condition',
      'conjonctions': 'si, à condition que, au cas où, pourvu que',
      'mode': 'Indicatif (avec Si) / Subjonctif / Conditionnel',
      'exemple': 'Si tu révises régulièrement, tu réussiras avec brio.',
      'icone': Icons.alt_route,
    },
    {
      'nom': 'Concession',
      'conjonctions': 'bien que, quoique, même si',
      'mode': 'Subjonctif (Indicatif après "même si")',
      'exemple': 'Bien qu’il soit fatigué, il poursuit son étude.',
      'icone': Icons.balance_outlined,
    },
    {
      'nom': 'Comparaison',
      'conjonctions': 'comme, ainsi que, de même que, plus… que',
      'mode': 'Indicatif',
      'exemple': 'Il court comme un lièvre dans la plaine.',
      'icone': Icons.compare_arrows,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final active = _valeurs[_selectedIndex];

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
              Icon(Icons.pie_chart_outline, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Roue des Subordonnées Circonstancielles',
                style: TextStyle(
                  fontFamily: AppTheme.fontTinos,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Sélecteur horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_valeurs.length, (idx) {
                final isSel = idx == _selectedIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: FilterChip(
                    label: Text(_valeurs[idx]['nom'] as String),
                    selected: isSel,
                    onSelected: (_) => setState(() => _selectedIndex = idx),
                    selectedColor: AppColors.navy,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.ink,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          // Fiche détaillée de la valeur sélectionnée
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(active['icone'] as IconData, color: AppColors.gold, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Subordonnée de ${active['nom']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.navy),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Conjonctions : ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink)),
                      TextSpan(text: active['conjonctions'] as String, style: const TextStyle(fontSize: 13, color: AppColors.navy)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Mode verbal : ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink)),
                      TextSpan(
                        text: active['mode'] as String,
                        style: const TextStyle(fontSize: 13, color: AppColors.gold, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '*Exemple* : ${active['exemple']}',
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.ink),
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
