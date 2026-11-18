import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'rich_text_parser.dart';

class LettrineText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;

  const LettrineText({
    super.key,
    required this.text,
    required this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    // Trouver la première vraie lettre alphabétique pour la lettrine
    int firstLetterIdx = 0;
    while (firstLetterIdx < text.length &&
        !RegExp(r'[a-zA-ZÀ-ÿ]').hasMatch(text[firstLetterIdx])) {
      firstLetterIdx++;
    }

    if (firstLetterIdx >= text.length) {
      return RichTextParser.buildRichText(text, baseStyle: baseStyle);
    }

    final prefix = text.substring(0, firstLetterIdx);
    final lettrineChar = text[firstLetterIdx].toUpperCase();
    final resteTexte = text.substring(firstLetterIdx + 1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 10, top: 2, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.gold, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Text(
            lettrineChar,
            style: const TextStyle(
              fontFamily: AppTheme.fontPinyon,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
              height: 1.0,
            ),
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                if (prefix.isNotEmpty)
                  TextSpan(text: prefix, style: baseStyle),
                ...RichTextParser.parseToSpans(resteTexte, baseStyle),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
