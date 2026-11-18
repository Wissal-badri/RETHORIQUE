import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CartesFiguresStyleWidget extends StatefulWidget {
  const CartesFiguresStyleWidget({super.key});

  @override
  State<CartesFiguresStyleWidget> createState() => _CartesFiguresStyleWidgetState();
}

class _CartesFiguresStyleWidgetState extends State<CartesFiguresStyleWidget> {
  final Map<int, bool> _flipped = {};

  final List<Map<String, String>> _figures = [
    {
      'figure': 'La Métaphore',
      'definition': 'Rapprochement de deux éléments sans mot de comparaison (comme, tel).',
      'exemple': '« Cet homme est un lion au combat. »',
    },
    {
      'figure': 'La Comparaison',
      'definition': 'Rapprochement de deux éléments au moyen d’un outil comparatif.',
      'exemple': '« Il est rapide comme l’éclair. »',
    },
    {
      'figure': 'L’Oxymore',
      'definition': 'Rapprochement de deux mots de sens opposés dans un même syntagme.',
      'exemple': '« Une obscure clarté qui tombe des étoiles. »',
    },
    {
      'figure': 'L’Hyperbole',
      'definition': 'Exagération frappante destinée à amplifier une réalité ou une émotion.',
      'exemple': '« Je meurs de faim et de soif ! »',
    },
    {
      'figure': 'La Personnification',
      'definition': 'Attribution de traits, sentiments ou comportements humains à un objet ou animal.',
      'exemple': '« La forêt gémissait sous le vent glacé. »',
    },
    {
      'figure': 'La Litote',
      'definition': 'Atténuation de l’expression pour en suggérer avec pudeur beaucoup plus.',
      'exemple': '« Va, je ne te hais point (pour dire : je t’aime). »',
    },
    {
      'figure': 'L’Antithèse',
      'definition': 'Opposition de deux idées contraires dans une même phrase.',
      'exemple': '« Le jour est fait pour vivre, la nuit pour rêver. »',
    },
    {
      'figure': 'L’Anaphore',
      'definition': 'Répétition d’un mot ou groupe de mots au début de phrases successives.',
      'exemple': '« Paris brisé ! Paris outragé ! mais Paris libéré ! »',
    },
  ];

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
              Icon(Icons.flip_to_front_outlined, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Cartes des Figures de Style (Touche pour retourner)',
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
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _figures.length,
              itemBuilder: (context, index) {
                final item = _figures[index];
                final isFlipped = _flipped[index] ?? false;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _flipped[index] = !isFlipped;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: 220,
                    margin: const EdgeInsets.only(right: 12, bottom: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFlipped ? const Color(0xFFFBF6EC) : AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isFlipped ? AppColors.gold : AppColors.border,
                        width: isFlipped ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(1, 2),
                        ),
                      ],
                    ),
                    child: isFlipped
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['definition']!,
                                style: const TextStyle(fontSize: 11, color: AppColors.ink, height: 1.3),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['exemple']!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.touch_app_outlined, color: AppColors.gold, size: 28),
                              const SizedBox(height: 8),
                              Text(
                                item['figure']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: AppTheme.fontTinos,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.navy,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Touche pour voir la définition & l’exemple',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, color: AppColors.gold),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
