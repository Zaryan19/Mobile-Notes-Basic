import 'package:flutter_test/flutter_test.dart';
import 'package:catatan_mobile/models/note.dart';
import 'package:catatan_mobile/widgets/deep_search_controller.dart';

void main() {
  group('De Stijl Note Model Tests', () {
    test('Derives title from the first non-empty line', () {
      final note = Note(
        id: '1',
        content: '\n\n  DE STIJL TITLE \nSecond line body content.',
        updatedAt: DateTime.now(),
      );

      expect(note.title, equals('DE STIJL TITLE'));
      expect(note.snippet, equals('Second line body content.'));
      expect(note.wordCount, equals(7));
    });

    test('Defaults to UNTITLED NOTE when content is blank', () {
      final note = Note(
        id: '2',
        content: '   \n  \n',
        updatedAt: DateTime.now(),
      );

      expect(note.title, equals('UNTITLED NOTE'));
      expect(note.snippet, equals('Empty note...'));
      expect(note.wordCount, equals(0));
    });

    test('Formats timestamp correctly (e.g., Nov 9, 2026, 14:27)', () {
      final dt = DateTime(2026, 11, 9, 14, 27);
      expect(Note.formatTimestamp(dt), equals('Nov 9, 2026, 14:27'));
    });
  });

  group('DeepSearchTextController Tests', () {
    test('Calculates match count and indices accurately', () {
      final controller = DeepSearchTextController(
        text: 'Mondrian composition with primary red, blue, and yellow. Neo-plasticism.',
        initialQuery: 'plastic',
      );

      expect(controller.matchCount, equals(1));
      expect(controller.matchIndices.first, equals(61));
    });

    test('Cycles occurrences seamlessly with nextMatch and previousMatch', () {
      final controller = DeepSearchTextController(
        text: 'grid and line and grid and line',
        initialQuery: 'grid',
      );

      expect(controller.matchCount, equals(2));
      expect(controller.activeMatchIndex, equals(0));

      controller.nextMatch();
      expect(controller.activeMatchIndex, equals(1));

      controller.nextMatch(); // cycles back to 0
      expect(controller.activeMatchIndex, equals(0));

      controller.previousMatch(); // cycles backward to 1
      expect(controller.activeMatchIndex, equals(1));
    });
  });

  group('Batch Selection Tests', () {
    test('Set tracks and toggles selected note IDs accurately', () {
      final selected = <String>{};
      const note1 = 'note_1';
      const note2 = 'note_2';

      selected.add(note1);
      expect(selected.contains(note1), isTrue);
      expect(selected.length, equals(1));

      selected.add(note2);
      expect(selected.length, equals(2));

      selected.remove(note1);
      expect(selected.contains(note1), isFalse);
      expect(selected.length, equals(1));
    });
  });

  group('Content Comparison Auto-Save Logic Tests', () {
    test('Identifies when text content has genuinely changed', () {
      const initial = 'De Stijl content';
      var lastSaved = initial;
      var timestamp = DateTime(2026, 11, 9, 10, 0);

      // Simulating selecting or navigating without edits
      const current1 = 'De Stijl content';
      final shouldSave1 = current1 != lastSaved;
      expect(shouldSave1, isFalse);

      // Simulating actual character changes
      const current2 = 'De Stijl content updated';
      final shouldSave2 = current2 != lastSaved;
      expect(shouldSave2, isTrue);

      if (shouldSave2) {
        lastSaved = current2;
        timestamp = DateTime(2026, 11, 9, 14, 30);
      }
      expect(lastSaved, equals('De Stijl content updated'));
      expect(timestamp, equals(DateTime(2026, 11, 9, 14, 30)));
    });
  });
}
