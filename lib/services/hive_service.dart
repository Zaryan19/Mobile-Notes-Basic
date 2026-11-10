import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

/// Hive database service handling local storage, CRUD operations,
/// and instant case-insensitive substring searching.
class HiveService {
  static const String boxName = 'notes_box';

  /// Initialize Hive, register NoteAdapter, and open the notes box.
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    await Hive.openBox<Note>(boxName);
  }

  Box<Note> get _box => Hive.box<Note>(boxName);

  /// Listen to changes in the Hive box.
  ValueListenable<Box<Note>> get listenable => _box.listenable();

  /// Retrieve all notes sorted by updatedAt descending (newest first).
  List<Note> getAllNotes() {
    final notes = _box.values.toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  /// Retrieve a specific note by ID.
  Note? getNoteById(String id) {
    try {
      return _box.values.firstWhere((note) => note.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Save or update a note in Hive.
  Future<void> saveNote(Note note) async {
    await _box.put(note.id, note);
  }

  /// Delete a note from Hive.
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  /// Delete multiple notes from Hive in batch.
  Future<void> deleteNotes(Iterable<String> ids) async {
    await _box.deleteAll(ids);
  }

  /// Perform case-insensitive substring search across all notes.
  List<Note> searchNotes(String query) {
    final trimmed = query.trim().toLowerCase();
    final all = getAllNotes();
    if (trimmed.isEmpty) return all;

    return all.where((note) {
      return note.content.toLowerCase().contains(trimmed);
    }).toList();
  }

  /// Seed initial De Stijl sample notes if the box is empty.
  Future<void> seedInitialNotesIfEmpty() async {
    if (_box.isEmpty) {
      final sampleNotes = [
        Note(
          id: 'sample-destijl-manifesto',
          content: '''DE STIJL MANIFESTO I (1918)
The old world is being destroyed. The new world is ready to emerge.
There is an old and a new consciousness of time.
The old consciousness is directed towards the individual.
The new consciousness is directed towards the universal.

The struggle of the individual against the universal is revealing itself
in the world war as well as in the art of our day.

Art must express universal harmony through pure geometric relations:
- Vertical and horizontal lines
- Three primary colors: Red, Blue, Yellow
- Three non-colors: White, Grey, Black

Deep search allows instant navigation across this neoplastic manuscript.''',
          updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        Note(
          id: 'sample-neoplasticism-grid',
          content: '''NEOPLASTICISM & THE ASYMMETRIC GRID
Piet Mondrian rejected symmetry because symmetry is static and dead.
Dynamic equilibrium is achieved through unequal oppositions.

A large field of white is balanced by a small square of red.
A slender blue bar anchors the baseline.
A brilliant flash of yellow sparks optical tension.

Borders must be thick, black, and deliberate (2dp to 4dp).
Curves and soft drop shadows are strictly prohibited.''',
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        Note(
          id: 'sample-deep-search-instructions',
          content: '''DEEP SEARCH & AUTO-JUMP GUIDE
Search for any keyword from the Home screen.
Tap on the search result to trigger instant auto-scroll to the exact keyword offset.

Key features implemented:
- Multiline TextPainter coordinate calculation
- Precise ScrollController jump with 300ms easeOut curve
- Yellow highlight background with black text inline
- Sticky mini-navigator [ < ] 1 / 4 [ > ] for cycling occurrences
- Mechanical tactile feedback on touch
- Debounced auto-save directly to Hive database.''',
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      for (final note in sampleNotes) {
        await saveNote(note);
      }
    }
  }
}

