import 'package:flutter/material.dart';
import '../models/note.dart';
import '../theme/destijl_theme.dart';
import 'search_highlight_text.dart';

/// Brutalist Note Card item implementing De Stijl asymmetrical padding,
/// solid divider lines, and multi-select support.
class DeStijlNoteCard extends StatefulWidget {
  final Note note;
  final int index;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isSelectionMode;
  final bool isSelected;

  const DeStijlNoteCard({
    super.key,
    required this.note,
    required this.index,
    required this.searchQuery,
    required this.onTap,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
  });

  @override
  State<DeStijlNoteCard> createState() => _DeStijlNoteCardState();
}

class _DeStijlNoteCardState extends State<DeStijlNoteCard> {
  bool _isPressed = false;

  String _formatDate(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$year.$month.$day — $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic asymmetrical padding as specified in design.md:
    // Left 16dp, right 8dp for odd items; left 8dp, right 16dp for even items.
    final bool isEven = widget.index % 2 == 0;
    final EdgeInsets margin = isEven
        ? const EdgeInsets.only(left: 8.0, right: 16.0, bottom: 12.0)
        : const EdgeInsets.only(left: 16.0, right: 8.0, bottom: 12.0);

    // Asymmetric accent color strip (Mondrian signature touch)
    final Color accentColor = widget.isSelected
        ? DeStijlTheme.primaryBlue
        : (widget.index % 3 == 0)
            ? DeStijlTheme.primaryRed
            : (widget.index % 3 == 1)
                ? DeStijlTheme.primaryBlue
                : DeStijlTheme.primaryYellow;

    return Container(
      margin: margin,
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: Transform.translate(
          offset: _isPressed ? const Offset(2.0, 2.0) : Offset.zero,
          child: Container(
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? const Color(0xFFF0F4FF)
                  : DeStijlTheme.white,
              borderRadius: BorderRadius.zero, // STRICTLY 0px
              border: Border.all(
                color: widget.isSelected
                    ? DeStijlTheme.primaryBlue
                    : DeStijlTheme.black,
                width: widget.isSelected ? 2.5 : DeStijlTheme.borderWidth,
              ),
              boxShadow: _isPressed
                  ? null
                  : [
                      BoxShadow(
                        color: widget.isSelected
                            ? DeStijlTheme.primaryBlue
                            : DeStijlTheme.black,
                        offset: const Offset(4.0, 4.0),
                        blurRadius: 0.0,
                      ),
                    ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // De Stijl primary accent color block indicator
                  Container(
                    width: widget.isSelected ? 8.0 : 6.0,
                    color: accentColor,
                  ),
                  VerticalDivider(
                    width: 2.0,
                    thickness: 2.0,
                    color: widget.isSelected
                        ? DeStijlTheme.primaryBlue
                        : DeStijlTheme.black,
                  ),
                  // Card Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Metadata Header: Word Count in JetBrains Mono
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${widget.note.wordCount}W / ${widget.note.charCount}C',
                              style: DeStijlTheme.metadata(
                                color: widget.isSelected
                                    ? DeStijlTheme.primaryBlue
                                    : DeStijlTheme.black,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6.0),

                          // Note Title
                          SearchHighlightText(
                            text: widget.note.title,
                            query: widget.searchQuery,
                            baseStyle: DeStijlTheme.h2(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6.0),

                          // Snippet with Search Highlight
                          SearchHighlightText(
                            text: widget.note.snippet,
                            query: widget.searchQuery,
                            baseStyle: DeStijlTheme.snippet(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10.0),

                          // Last modified date displayed at the bottom of the card
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 12.0,
                                color: DeStijlTheme.grey,
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                widget.note.formattedUpdatedAt,
                                style: DeStijlTheme.metadata(
                                  color: DeStijlTheme.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right Action / Selection Box (0px corner radius)
                  Container(
                    width: 36.0,
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: widget.isSelected
                              ? DeStijlTheme.primaryBlue
                              : DeStijlTheme.black,
                          width: DeStijlTheme.borderWidth,
                        ),
                      ),
                      color: widget.isSelected
                          ? DeStijlTheme.primaryBlue
                          : DeStijlTheme.white,
                    ),
                    child: Center(
                      child: widget.isSelectionMode
                          ? (widget.isSelected
                              ? const Icon(
                                  Icons.check,
                                  size: 20.0,
                                  color: DeStijlTheme.white,
                                )
                              : Container(
                                  width: 14.0,
                                  height: 14.0,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: DeStijlTheme.black,
                                      width: 2.0,
                                    ),
                                    color: DeStijlTheme.white,
                                  ),
                                ))
                          : const Icon(
                              Icons.arrow_forward,
                              size: 16.0,
                              color: DeStijlTheme.black,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
