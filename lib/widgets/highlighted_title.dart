import 'package:flutter/material.dart';

class HighlightedTitle extends StatelessWidget {
  const HighlightedTitle({
    required this.text,
    required this.query,
    required this.style,
    super.key,
  });

  final String text;
  final String query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = normalizedQuery.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(text, style: style);
    }

    final before = text.substring(0, matchIndex);
    final match = text.substring(matchIndex, matchIndex + normalizedQuery.length);
    final after = text.substring(matchIndex + normalizedQuery.length);

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: style.copyWith(
              backgroundColor: const Color(0xFFFDE68A),
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
