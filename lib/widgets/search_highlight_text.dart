import 'package:flutter/material.dart';
import '../theme/destijl_theme.dart';

/// Renders a Text widget with substring search highlighting.
/// Matched query substrings are highlighted with a Yellow (#FFFF00) background
/// and Black text, adhering strictly to the De Stijl design specification.
class SearchHighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle baseStyle;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow overflow;

  const SearchHighlightText({
    super.key,
    required this.text,
    required this.query,
    required this.baseStyle,
    this.highlightStyle,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty || !text.toLowerCase().contains(trimmedQuery.toLowerCase())) {
      return Text(
        text,
        style: baseStyle,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = trimmedQuery.toLowerCase();
    final effectiveHighlightStyle = highlightStyle ??
        baseStyle.copyWith(
          backgroundColor: DeStijlTheme.primaryYellow,
          color: DeStijlTheme.black,
          fontWeight: FontWeight.w700,
        );

    int start = 0;
    while (start < text.length) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: baseStyle,
        ));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + lowerQuery.length),
        style: effectiveHighlightStyle,
      ));

      start = index + lowerQuery.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

