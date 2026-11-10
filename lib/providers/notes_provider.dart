import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/hive_service.dart';

/// State management for notes and real-time search filtering.
class NotesProvider extends ChangeNotifier {
  final HiveService _hiveService;
  String _searchQuery = '';
  List<Note> _filteredNotes = [];

  NotesProvider(this._hiveService) {
    _loadNotes();
  }

  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.trim().isNotEmpty;
  List<Note> get notes => _filteredNotes;

  void _loadNotes() {
    if (_searchQuery.trim().isEmpty) {
      _filteredNotes = _hiveService.getAllNotes();
    } else {
      _filteredNotes = _hiveService.searchNotes(_searchQuery);
    }
  }

  /// Update search query and instantly filter notes.
  void setSearchQuery(String query) {
    _searchQuery = query;
    _loadNotes();
    notifyListeners();
  }

  /// Clear the current search filter.
  void clearSearch() {
    _searchQuery = '';
    _loadNotes();
    notifyListeners();
  }

  /// Refresh notes from Hive (e.g., after returning to home).
  void refresh() {
    _loadNotes();
    notifyListeners();
  }

  /// Retrieve note by ID.
  Note? getNote(String id) {
    return _hiveService.getNoteById(id);
  }

  /// Save or update a note.
  Future<void> saveNote(Note note) async {
    await _hiveService.saveNote(note);
    _loadNotes();
    notifyListeners();
  }

  /// Delete note by ID.
  Future<void> deleteNote(String id) async {
    await _hiveService.deleteNote(id);
    _loadNotes();
    notifyListeners();
  }

  /// Delete multiple notes in batch.
  Future<void> deleteNotes(Iterable<String> ids) async {
    await _hiveService.deleteNotes(ids);
    _loadNotes();
    notifyListeners();
  }

  /// Factory helper to create a fresh note with unique ID.
  Note createNewNote() {
    final id = 'note_${DateTime.now().microsecondsSinceEpoch}';
    return Note(
      id: id,
      content: '',
      updatedAt: DateTime.now(),
    );
  }
}

