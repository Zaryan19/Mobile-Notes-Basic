import 'package:flutter/material.dart';
import '../theme/destijl_theme.dart';

/// Custom TextEditingController that highlights search query occurrences
/// with De Stijl primary colors (Yellow highlight with Black text,
/// and active match distinction).
class DeepSearchTextController extends TextEditingController {
  String _searchQuery = '';
  int _activeMatchIndex = 0;
  List<int> _matchIndices = [];

  DeepSearchTextController({String? text, String initialQuery = ''})
      : super(text: text) {
    _searchQuery = initialQuery;
    _recalculateMatches();
  }

  String get searchQuery => _searchQuery;
  int get activeMatchIndex => _activeMatchIndex;
  List<int> get matchIndices => List.unmodifiable(_matchIndices);
  int get matchCount => _matchIndices.length;

  /// Update search query and recompute match occurrences.
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _activeMatchIndex = 0;
      _recalculateMatches();
      notifyListeners();
    }
  }

  /// Change active match to a specific index (0-based) and refresh spans.
  void setActiveMatchIndex(int index) {
    if (_matchIndices.isEmpty) {
      _activeMatchIndex = 0;
    } else {
      _activeMatchIndex = index.clamp(0, _matchIndices.length - 1);
    }
    notifyListeners();
  }

  /// Next occurrence (cycles through matches)
  int nextMatch() {
    if (_matchIndices.isEmpty) return 0;
    _activeMatchIndex = (_activeMatchIndex + 1) % _matchIndices.length;
    notifyListeners();
    return _activeMatchIndex;
  }

  /// Previous occurrence (cycles through matches)
  int previousMatch() {
    if (_matchIndices.isEmpty) return 0;
    _activeMatchIndex = (_activeMatchIndex - 1 + _matchIndices.length) % _matchIndices.length;
    notifyListeners();
    return _activeMatchIndex;
  }

  /// Recompute starting indices of all occurrences.
  void _recalculateMatches() {
    _matchIndices.clear();
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty || text.isEmpty) return;

    final lowerText = text.toLowerCase();
    int start = 0;
    while (start < lowerText.length) {
      final index = lowerText.indexOf(query, start);
      if (index == -1) break;
      _matchIndices.add(index);
      start = index + query.length;
    }

    if (_matchIndices.isNotEmpty && _activeMatchIndex >= _matchIndices.length) {
      _activeMatchIndex = 0;
    }
  }

  @override
  set text(String newText) {
    super.text = newText;
    _recalculateMatches();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty || _matchIndices.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final spans = <InlineSpan>[];
    final defaultStyle = style ?? DeStijlTheme.body();
    final lowerText = text.toLowerCase();
    int currentOffset = 0;

    for (int i = 0; i < _matchIndices.length; i++) {
      final matchStart = _matchIndices[i];
      final matchEnd = matchStart + query.length;

      // Add non-matched text prior to this occurrence
      if (matchStart > currentOffset) {
        spans.add(TextSpan(
          text: text.substring(currentOffset, matchStart),
          style: defaultStyle,
        ));
      }

      // Check if this is the active match in the mini-navigator
      final isActive = (i == _activeMatchIndex);

      spans.add(TextSpan(
        text: text.substring(matchStart, matchEnd),
        style: defaultStyle.copyWith(
          backgroundColor: DeStijlTheme.primaryYellow,
          color: DeStijlTheme.black,
          fontWeight: FontWeight.w700,
          // If active match, give it a prominent De Stijl underline indicator
          decoration: isActive ? TextDecoration.underline : TextDecoration.none,
          decorationColor: DeStijlTheme.primaryRed,
          decorationThickness: isActive ? 3.0 : 1.0,
        ),
      ));

      currentOffset = matchEnd;
    }

    // Add any remaining text
    if (currentOffset < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentOffset),
        style: defaultStyle,
      ));
    }

    return TextSpan(children: spans, style: defaultStyle);
  }
}

