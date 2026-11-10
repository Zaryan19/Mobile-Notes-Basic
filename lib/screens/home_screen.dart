import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/destijl_theme.dart';
import '../widgets/destijl_button.dart';
import '../widgets/destijl_card.dart';
import 'note_detail_screen.dart';

/// De Stijl Home Screen with Instant Search, Asymmetrical Note List,
/// Multi-Select & Batch Delete, and Neoplasticism Visual Composition.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  // Multi-select state
  final Set<String> _selectedNoteIds = <String>{};
  bool get _isSelectionMode => _selectedNoteIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openNote(BuildContext context, {Note? note, String searchQuery = ''}) {
    if (_isSelectionMode) return;

    final provider = Provider.of<NotesProvider>(context, listen: false);
    final targetNote = note ?? provider.createNewNote();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(
          noteId: targetNote.id,
          initialContent: targetNote.content,
          initialUpdatedAt: targetNote.updatedAt,
          initialSearchQuery: searchQuery,
          isNewNote: note == null,
        ),
      ),
    ).then((_) {
      provider.refresh();
    });
  }

  void _toggleNoteSelection(String noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  void _selectAllNotes(List<Note> notes) {
    setState(() {
      if (_selectedNoteIds.length == notes.length) {
        _selectedNoteIds.clear();
      } else {
        _selectedNoteIds.clear();
        _selectedNoteIds.addAll(notes.map((n) => n.id));
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedNoteIds.clear();
    });
  }

  Future<void> _confirmBatchDelete(BuildContext context) async {
    final count = _selectedNoteIds.length;
    if (count == 0) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: DeStijlTheme.white,
          shape: const BeveledRectangleBorder(
            side: BorderSide(
              color: DeStijlTheme.black,
              width: DeStijlTheme.borderWidth,
            ),
          ),
          title: Row(
            children: [
              Container(
                width: 14.0,
                height: 14.0,
                color: DeStijlTheme.primaryRed,
                margin: const EdgeInsets.only(right: 8.0),
              ),
              Expanded(
                child: Text(
                  'DELETE $count NOTE${count > 1 ? 'S' : ''}?',
                  style: DeStijlTheme.h2(),
                ),
              ),
            ],
          ),
          content: Text(
            'This action is irreversible. The selected notes will be permanently purged from Hive.',
            style: DeStijlTheme.body(),
          ),
          actionsPadding: const EdgeInsets.all(16.0),
          actions: [
            DeStijlButton(
              onPressed: () => Navigator.pop(context, false),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: const Text('CANCEL'),
            ),
            DeStijlButton.primaryRed(
              onPressed: () => Navigator.pop(context, true),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: const Text('PURGE'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && mounted) {
      final provider = Provider.of<NotesProvider>(context, listen: false);
      await provider.deleteNotes(Set<String>.from(_selectedNoteIds));
      _clearSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final notes = provider.notes;
    final isSearching = provider.isSearching;
    final searchQuery = provider.searchQuery;

    return PopScope(
      canPop: !_isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isSelectionMode) {
          _clearSelection();
        }
      },
      child: Scaffold(
        backgroundColor: DeStijlTheme.white,
        body: SafeArea(
          child: Column(
            children: [
              // --- Header: Mondrian Normal Header OR Selection Mode Header ---
              _isSelectionMode
                  ? _buildSelectionHeader(context, notes)
                  : _buildMondrianHeader(context, notes.length, isSearching),

              // --- Pure White Search Bar with Black 2dp border ---
              if (!_isSelectionMode) _buildWhiteSearchBar(provider),

              // --- Note Cards List ---
              Expanded(
                child: notes.isEmpty
                    ? _buildEmptyState(isSearching, searchQuery)
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          final isSelected = _selectedNoteIds.contains(note.id);

                          return DeStijlNoteCard(
                            note: note,
                            index: index,
                            searchQuery: searchQuery,
                            isSelectionMode: _isSelectionMode,
                            isSelected: isSelected,
                            onLongPress: () {
                              _toggleNoteSelection(note.id);
                            },
                            onTap: () {
                              if (_isSelectionMode) {
                                _toggleNoteSelection(note.id);
                              } else {
                                _openNote(
                                  context,
                                  note: note,
                                  searchQuery: searchQuery,
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        // --- Square Primary Blue FAB with Hard Solid Shadow (hidden in selection mode) ---
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: _isSelectionMode
            ? null
            : DeStijlButton.primaryBlue(
                onPressed: () => _openNote(context),
                padding: const EdgeInsets.all(16.0),
                width: 56.0,
                height: 56.0,
                isSquare: true,
                child: const Icon(
                  Icons.add,
                  size: 28.0,
                  color: DeStijlTheme.white,
                ),
              ),
      ),
    );
  }

  /// Selection Mode AppBar with Close, Count, Select All, and Primary Red Delete
  Widget _buildSelectionHeader(BuildContext context, List<Note> notes) {
    final count = _selectedNoteIds.length;
    final allSelected = notes.isNotEmpty && count == notes.length;

    return Container(
      decoration: const BoxDecoration(
        color: DeStijlTheme.white,
        border: Border(
          bottom: BorderSide(
            color: DeStijlTheme.black,
            width: DeStijlTheme.thickBorderWidth,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Cancel / Close Selection [ X ]
          DeStijlButton(
            onPressed: _clearSelection,
            padding: const EdgeInsets.all(8.0),
            shadowOffset: 2.0,
            child: const Icon(
              Icons.close,
              size: 18.0,
              color: DeStijlTheme.black,
            ),
          ),
          const SizedBox(width: 12.0),

          // Selection Count in JetBrains Mono / Helvetica
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count SELECTED',
                  style: DeStijlTheme.h2(color: DeStijlTheme.primaryBlue),
                ),
                Text(
                  'BATCH ACTION MODE',
                  style: DeStijlTheme.metadata(color: DeStijlTheme.grey),
                ),
              ],
            ),
          ),

          // Select All Button
          DeStijlButton(
            onPressed: () => _selectAllNotes(notes),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            shadowOffset: 2.0,
            backgroundColor: allSelected ? DeStijlTheme.black : DeStijlTheme.white,
            foregroundColor: allSelected ? DeStijlTheme.white : DeStijlTheme.black,
            child: Text(
              allSelected ? 'UNSELECT' : 'ALL',
              style: DeStijlTheme.monoBold(
                color: allSelected ? DeStijlTheme.white : DeStijlTheme.black,
                size: 11.0,
              ),
            ),
          ),
          const SizedBox(width: 8.0),

          // Primary Red Batch Delete Button
          DeStijlButton.primaryRed(
            onPressed: count > 0 ? () => _confirmBatchDelete(context) : null,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.delete_outline,
                  size: 18.0,
                  color: DeStijlTheme.white,
                ),
                const SizedBox(width: 4.0),
                Text(
                  'DELETE',
                  style: DeStijlTheme.monoBold(
                    color: DeStijlTheme.white,
                    size: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Header featuring Theo van Doesburg / Piet Mondrian geometric color blocks
  Widget _buildMondrianHeader(
      BuildContext context, int count, bool isSearching) {
    return Container(
      decoration: const BoxDecoration(
        color: DeStijlTheme.white,
        border: Border(
          bottom: BorderSide(
            color: DeStijlTheme.black,
            width: DeStijlTheme.borderWidth,
          ),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Title Block
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Aplikasi Notes',
                          style: DeStijlTheme.displayH1(),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          width: 10.0,
                          height: 10.0,
                          color: DeStijlTheme.primaryRed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      isSearching
                          ? 'SEARCH RESULTS // $count FOUND'
                          : 'Notes Everything // $count ENTRIES // by: zaryan',
                      style: DeStijlTheme.metadata(
                        color: isSearching
                            ? DeStijlTheme.primaryBlue
                            : DeStijlTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vertical Dividing Grid Line
            const VerticalDivider(
              width: 2.0,
              thickness: 2.0,
              color: DeStijlTheme.black,
            ),

            // Right Geometric Color Matrix (Mondrian signature)
            SizedBox(
              width: 64.0,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: DeStijlTheme.primaryRed,
                    ),
                  ),
                  const Divider(
                    height: 2.0,
                    thickness: 2.0,
                    color: DeStijlTheme.black,
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: DeStijlTheme.primaryYellow,
                          ),
                        ),
                        const VerticalDivider(
                          width: 2.0,
                          thickness: 2.0,
                          color: DeStijlTheme.black,
                        ),
                        Expanded(
                          child: Container(
                            color: DeStijlTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pure White Search Bar with Pure Black Border (0px radius, strictly NO Primary Blue).
  Widget _buildWhiteSearchBar(NotesProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: DeStijlTheme.white,
        border: Border(
          bottom: BorderSide(
            color: DeStijlTheme.black,
            width: DeStijlTheme.borderWidth,
          ),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: DeStijlTheme.white, // Pure White (#FFFFFF) fill
          borderRadius: BorderRadius.zero, // STRICTLY 0px
          border: Border.fromBorderSide(
            BorderSide(
              color: DeStijlTheme.black, // Pure Black (#000000) stroke (never blue)
              width: DeStijlTheme.borderWidth,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: DeStijlTheme.black, // Pure Black solid shadow
              offset: Offset(4.0, 4.0),
              blurRadius: 0.0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Search Icon Box (Pure Black icon on White)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              color: DeStijlTheme.white,
              child: const Icon(
                Icons.search,
                color: DeStijlTheme.black,
                size: 20.0,
              ),
            ),
            // Text Input Field (Black text & Grey hint)
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: DeStijlTheme.body(color: DeStijlTheme.black),
                cursorColor: DeStijlTheme.black,
                decoration: InputDecoration(
                  hintText: 'SEARCH NOTES (SUBSTRING MATCH)...',
                  hintStyle: DeStijlTheme.metadata(color: DeStijlTheme.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12.0,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (value) {
                  provider.setSearchQuery(value);
                },
              ),
            ),
            // Clear Button with Black icon on White
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  provider.clearSearch();
                },
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  color: DeStijlTheme.white,
                  child: const Icon(
                    Icons.close,
                    color: DeStijlTheme.black,
                    size: 18.0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Minimalist geometric empty state
  Widget _buildEmptyState(bool isSearching, String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Geometric De Stijl Emblem
            Container(
              width: 90.0,
              height: 90.0,
              decoration: BoxDecoration(
                border: Border.all(
                  color: DeStijlTheme.black,
                  width: DeStijlTheme.thickBorderWidth,
                ),
                boxShadow: DeStijlTheme.hardShadow,
                color: DeStijlTheme.white,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    width: 38.0,
                    height: 38.0,
                    child: Container(color: DeStijlTheme.primaryRed),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    width: 48.0,
                    height: 28.0,
                    child: Container(color: DeStijlTheme.primaryYellow),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    width: 38.0,
                    height: 48.0,
                    child: Container(color: DeStijlTheme.primaryBlue),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.note_alt_outlined,
                      size: 32.0,
                      color: DeStijlTheme.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              isSearching ? 'NO MATCHES FOUND' : 'EMPTY CANVAS',
              style: DeStijlTheme.h2(),
            ),
            const SizedBox(height: 8.0),
            Text(
              isSearching
                  ? 'No notes contain the phrase "$query". Try another keyword.'
                  : 'Tap the blue button to create your first neoplastic note.',
              style: DeStijlTheme.body(color: DeStijlTheme.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
