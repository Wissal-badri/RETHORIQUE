import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FriseTempsWidget extends StatelessWidget {
  const FriseTempsWidget({super.key});

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
            children: const [
              Icon(Icons.timeline, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Frise chronologique des temps de l’indicatif',
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 580,
              child: Column(
                children: [
                  // Ligne des temps avec flèche
                  CustomPaint(
                    size: const Size(580, 50),
                    painter: _FrisePainter(),
                  ),
                  const SizedBox(height: 10),
                  // Légende détaillée
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTempsColumn('PASSÉ LOINTAIN', 'Plus-que-parfait', 'avait chanté'),
                      _buildTempsColumn('RÉCIT & DESCRIPTION', 'Imparfait / Passé simple', 'chantait / chanta'),
                      _buildTempsColumn('PASSÉ RÉCENT', 'Passé composé', 'a chanté'),
                      _buildTempsColumn('PRÉSENT', 'Présent', 'chante', isCurrent: true),
                      _buildTempsColumn('FUTUR ANTÉRIEUR', 'Futur antérieur', 'aura chanté'),
                      _buildTempsColumn('FUTUR', 'Futur simple', 'chantera'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempsColumn(String zone, String temps, String exemple, {bool isCurrent = false}) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Text(
            zone,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isCurrent ? AppColors.gold : AppColors.ink.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.navy : AppColors.card,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCurrent ? AppColors.gold : AppColors.border,
                width: isCurrent ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              children: [
                Text(
                  temps,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? Colors.white : AppColors.navy,
                  ),
                ),
                Text(
                  '*$exemple*',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                    color: isCurrent ? AppColors.goldLight : AppColors.ink,
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

class _FrisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.navy
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final goldPaint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 2.0;

    final dotPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;

    final presentPaint = Paint()
      ..color = AppColors.navy
      ..style = PaintingStyle.fill;

    // Ligne principale
    final y = size.height / 2;
    canvas.drawLine(Offset(10, y), Offset(size.width - 20, y), linePaint);

    // Flèche vers l'avenir
    final path = Path()
      ..moveTo(size.width - 15, y)
      ..lineTo(size.width - 25, y - 6)
      ..lineTo(size.width - 25, y + 6)
      ..close();
    canvas.drawPath(path, linePaint);

    // Points des temps
    final double step = (size.width - 60) / 5;
    for (int i = 0; i <= 5; i++) {
      final x = 30 + i * step;
      canvas.drawLine(Offset(x, y - 8), Offset(x, y + 8), goldPaint);
      if (i == 3) {
        // Présent
        canvas.drawCircle(Offset(x, y), 6, presentPaint);
        canvas.drawCircle(Offset(x, y), 8, Paint()..color = AppColors.gold..style = PaintingStyle.stroke..strokeWidth = 2);
      } else {
        canvas.drawCircle(Offset(x, y), 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
