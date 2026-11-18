import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrnamentDivider extends StatelessWidget {
  final String symbol;
  final double width;
  final Color color;

  const OrnamentDivider({
    super.key,
    this.symbol = '❦',
    this.width = 180,
    this.color = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: SizedBox(
          width: width,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, color],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  symbol,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
