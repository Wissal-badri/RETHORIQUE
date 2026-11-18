import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RichTextParser {
  /// Transforme un texte balisé avec **gras** et *italique* en liste de TextSpan
  static List<InlineSpan> parseToSpans(String text, TextStyle baseStyle) {
    final List<InlineSpan> spans = [];

    // Regex pour capturer **gras** ou *italique*
    final regex = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*)');
    int lastMatchEnd = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      final matchedText = match.group(0)!;
      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        spans.add(TextSpan(
          text: matchedText.substring(2, matchedText.length - 2),
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ));
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*')) {
        spans.add(TextSpan(
          text: matchedText.substring(1, matchedText.length - 1),
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return spans;
  }

  /// Widget simple affichant le texte enrichi
  static Widget buildRichText(
    String text, {
    required TextStyle baseStyle,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text.rich(
      TextSpan(children: parseToSpans(text, baseStyle)),
      textAlign: textAlign,
    );
  }
}
