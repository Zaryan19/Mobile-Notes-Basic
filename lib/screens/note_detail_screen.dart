import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/destijl_theme.dart';
import '../widgets/deep_search_controller.dart';
import '../widgets/destijl_button.dart';
import '../widgets/search_mini_navigator.dart';

/// Note Detail Screen providing a full-screen plain text editor,
/// debounced auto-save to Hive, and the Deep Search Auto-Jump feature.
class NoteDetailScreen extends StatefulWidget {
  final String noteId;
  final String initialContent;
  final DateTime? initialUpdatedAt;
  final String initialSearchQuery;
  final bool isNewNote;

  const NoteDetailScreen({
    super.key,
    required this.noteId,
    this.initialContent = '',
    this.initialUpdatedAt,
    this.initialSearchQuery = '',
    this.isNewNote = false,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final DeepSearchTextController _textController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  Timer? _debounceTimer;
  bool _isSearchActive = false;
  final TextEditingController _inPageSearchController = TextEditingController();
  late NotesProvider _notesProvider;
  late DateTime _lastModified;
  late String _lastSavedContent;

  static const EdgeInsets _editorPadding = EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 80.0);
  static const TextStyle _editorTextStyle = TextStyle(
    fontFamily: 'Helvetica',
    fontFamilyFallback: ['Arial', 'sans-serif'],
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: DeStijlTheme.black,
  );

  @override
  void initState() {
    super.initState();
    _lastModified = widget.initialUpdatedAt ?? DateTime.now();
    _lastSavedContent = widget.initialContent;
    _isSearchActive = widget.initialSearchQuery.trim().isNotEmpty;
    _inPageSearchController.text = widget.initialSearchQuery;

    _textController = DeepSearchTextController(
      text: widget.initialContent,
      initialQuery: widget.initialSearchQuery,
    );

    _textController.addListener(_handleTextAndMatchChange);

// Initial Auto-Jump when opened via search
    if (_isSearchActive && _textController.matchCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            _jumpToMatchIndex(0);
          }
        });
      });
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notesProvider = Provider.of<NotesProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveNoteImmediate();
    _textController.removeListener(_handleTextAndMatchChange);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _inPageSearchController.dispose();
    super.dispose();
  }

  void _handleTextAndMatchChange() {
    final currentContent = _textController.text;
    // Only schedule auto-save if content actually changed (avoids triggering on selection/cursor moves)
    if (currentContent != _lastSavedContent) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _saveNoteImmediate();
      });
    }
    setState(() {});
  }

  void _saveNoteImmediate() {
    _debounceTimer?.cancel();
    final currentContent = _textController.text;

    // Don't save empty notes if newly created
    if (widget.isNewNote && currentContent.trim().isEmpty) return;

    // Explicitly check: ONLY update timestamp and save if actual text content has changed
    if (currentContent == _lastSavedContent) return;

    final now = DateTime.now();
    _lastModified = now;
    _lastSavedContent = currentContent;

    final note = Note(
      id: widget.noteId,
      content: currentContent,
      updatedAt: now,
    );

    _notesProvider.saveNote(note);
    if (mounted) {
      setState(() {});
    }
  }

  /// Bulletproof scroll-to-match: combines native selection focus scroll
  /// with a manual TextPainter Y-offset scroll for guaranteed reliability on long text.
  void _jumpToMatchIndex(int matchIndex) {
    if (_textController.matchIndices.isEmpty) return;
    if (matchIndex < 0 || matchIndex >= _textController.matchIndices.length) return;

    final startOffset = _textController.matchIndices[matchIndex];
    final queryLength = _textController.searchQuery.length;
    final endOffset = (startOffset + queryLength).clamp(0, _textController.text.length);

    // 1. Update highlight warna kuning di DeepSearchTextController
    _textController.setActiveMatchIndex(matchIndex);
    setState(() {});

    // JANGAN panggil _focusNode.requestFocus() atau _textController.selection di sini!
    // Itu yang menyebabkan bentrok scroll dan merampas fokus keyboard.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      final text = _textController.text;
      if (startOffset < 0 || startOffset > text.length) return;

      final screenWidth = MediaQuery.of(context).size.width;
      final textWidth = (screenWidth - _editorPadding.left - _editorPadding.right)
          .clamp(100.0, screenWidth);

      // 2. Ukur koordinat Y persis sesuai ukuran font & textScaler layar HP
      final painter = TextPainter(
        text: TextSpan(text: text, style: _editorTextStyle),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: textWidth);

      final boxes = painter.getBoxesForSelection(
        TextSelection(baseOffset: startOffset, extentOffset: endOffset),
      );

      double keywordTopY;
      if (boxes.isNotEmpty) {
        keywordTopY = boxes.first.top;
      } else {
        keywordTopY = painter.getOffsetForCaret(
          TextPosition(offset: startOffset),
          Rect.zero,
        ).dy;
      }

      // 3. Hitung posisi target agar kata berada di 1/3 atas layar
      final targetY = keywordTopY + _editorPadding.top;
      final position = _scrollController.position;
      final viewportHeight = position.viewportDimension;
      final maxScroll = position.maxScrollExtent;

      // Jika maxScroll masih 0 (belum selesai layout), tetap paksa ke targetY
      final rawTarget = (targetY - (viewportHeight * 0.3)).clamp(0.0, double.infinity);
      final scrollTarget = maxScroll > 0 ? rawTarget.clamp(0.0, maxScroll) : rawTarget;

      _scrollController.animateTo(
        scrollTarget,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _onNextMatch() {
    if (_textController.matchCount == 0) return;
    final newIndex = _textController.nextMatch();
    setState(() {});
    // Call directly — _jumpToMatchIndex already schedules its own postFrameCallback internally
    _jumpToMatchIndex(newIndex);
  }

  void _onPreviousMatch() {
    if (_textController.matchCount == 0) return;
    final newIndex = _textController.previousMatch();
    setState(() {});
    _jumpToMatchIndex(newIndex);
  }

  void _dismissSearch() {
    setState(() {
      _isSearchActive = false;
      _inPageSearchController.clear();
      _textController.setSearchQuery('');
    });
  }

  void _toggleInPageSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (!_isSearchActive) {
        _inPageSearchController.clear();
        _textController.setSearchQuery('');
      } else {
        _textController.setSearchQuery(_inPageSearchController.text);
      }
    });
  }

  Future<void> _confirmDelete() async {
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
              Text(
                'DELETE NOTE?',
                style: DeStijlTheme.h2(),
              ),
            ],
          ),
          content: Text(
            'This action is irreversible. The note will be permanently purged from Hive.',
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
      await Provider.of<NotesProvider>(context, listen: false)
          .deleteNote(widget.noteId);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = _textController.text.trim().isEmpty
        ? 0
        : _textController.text.trim().split(RegExp(r'\s+')).length;
    final charCount = _textController.text.length;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        _saveNoteImmediate();
      },
      child: Scaffold(
        backgroundColor: DeStijlTheme.white,
        appBar: _buildAppBar(wordCount, charCount),
        body: Column(
          children: [
            // If in-page search bar is toggled, display it
            if (_isSearchActive && widget.initialSearchQuery.isEmpty)
              _buildInPageSearchBar(),

            // Full-screen plain text editor
            Expanded(
              child: TextField(
                controller: _textController,
                scrollController: _scrollController,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                style: _editorTextStyle,
                cursorColor: DeStijlTheme.black,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: 'START WRITING...\nLines, thoughts, neoplastic musings.',
                  hintStyle: DeStijlTheme.body(color: DeStijlTheme.grey),
                  contentPadding: _editorPadding,
                  border: InputBorder.none,
                ),
              ),
            ),

            // Sticky Mini-Navigator for Deep Search
            if (_isSearchActive && _textController.searchQuery.isNotEmpty)
              SearchMiniNavigator(
                query: _textController.searchQuery,
                currentIndex: _textController.activeMatchIndex,
                totalMatches: _textController.matchCount,
                onPrevious: _onPreviousMatch,
                onNext: _onNextMatch,
                onClose: _dismissSearch,
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int wordCount, int charCount) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DeStijlButton(
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          shadowOffset: 2.0,
          child: const Icon(
            Icons.arrow_back,
            size: 18.0,
            color: DeStijlTheme.black,
          ),
        ),
      ),
      titleSpacing: 4.0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'EDITOR',
            style: DeStijlTheme.h2(),
          ),
          Text(
            'Last edited: ${Note.formatTimestamp(_lastModified)}',
            style: DeStijlTheme.metadata(color: DeStijlTheme.grey),
          ),
          Text(
            '$wordCount WORDS // $charCount CHARS',
            style: DeStijlTheme.metadata(color: DeStijlTheme.black),
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(2.0),
        child: Divider(
          height: 2.0,
          thickness: 2.0,
          color: DeStijlTheme.black,
        ),
      ),
      actions: [
        // In-page search toggle
        Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: DeStijlButton(
            onPressed: _toggleInPageSearch,
            padding: const EdgeInsets.all(8.0),
            shadowOffset: 2.0,
            backgroundColor: _isSearchActive
                ? DeStijlTheme.primaryYellow
                : DeStijlTheme.white,
            foregroundColor: DeStijlTheme.black,
            child: const Icon(
              Icons.search,
              size: 18.0,
              color: DeStijlTheme.black,
            ),
          ),
        ),

        // Primary Red Delete Action
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: DeStijlButton.primaryRed(
            onPressed: _confirmDelete,
            padding: const EdgeInsets.all(8.0),
            child: const Icon(
              Icons.delete_outline,
              size: 18.0,
              color: DeStijlTheme.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInPageSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: DeStijlTheme.lightGrey,
        border: Border(
          bottom: BorderSide(
            color: DeStijlTheme.black,
            width: DeStijlTheme.borderWidth,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                color: DeStijlTheme.white,
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: DeStijlTheme.black,
                  width: DeStijlTheme.borderWidth,
                ),
              ),
              child: TextField(
                controller: _inPageSearchController,
                autofocus: true,
                style: DeStijlTheme.body(),
                decoration: InputDecoration(
                  hintText: 'FIND IN NOTE...',
                  hintStyle: DeStijlTheme.metadata(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  _textController.setSearchQuery(val);
                  setState(() {});
                  if (_textController.matchCount > 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _jumpToMatchIndex(0);
                      }
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          DeStijlButton(
            onPressed: _dismissSearch,
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            shadowOffset: 2.0,
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}

