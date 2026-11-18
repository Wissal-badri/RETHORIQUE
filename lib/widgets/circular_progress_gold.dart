import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CircularProgressGold extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final bool showText;

  const CircularProgressGold({
    super.key,
    required this.percentage,
    this.size = 54,
    this.strokeWidth = 4.5,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final double value = (percentage / 100.0).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cercle de fond
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: strokeWidth,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.border.withOpacity(0.5),
            ),
          ),
          // Cercle doré de progression
          CircularProgressIndicator(
            value: value,
            strokeWidth: strokeWidth,
            strokeCap: StrokeCap.round,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
          ),
          if (showText)
            Text(
              '${percentage.toInt()}%',
              style: TextStyle(
                fontFamily: AppTheme.fontTinos,
                fontSize: size * 0.26,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
        ],
      ),
    );
  }
}
