import 'package:flutter/material.dart';
import '../theme/destijl_theme.dart';
import 'destijl_button.dart';

/// Sticky De Stijl Mini-Navigator widget displaying:
/// `[ < ]  1 / 4  [ > ]` with sharp edges, 2dp borders, and hard solid shadow.
class SearchMiniNavigator extends StatelessWidget {
  final String query;
  final int currentIndex;
  final int totalMatches;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const SearchMiniNavigator({
    super.key,
    required this.query,
    required this.currentIndex,
    required this.totalMatches,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // If no query or 0 matches, don't show or show minimalist 0/0 indicator
    final displayIndex = totalMatches == 0 ? 0 : currentIndex + 1;

    return Container(
      decoration: const BoxDecoration(
        color: DeStijlTheme.white,
        borderRadius: BorderRadius.zero,
        border: Border(
          top: BorderSide(
            color: DeStijlTheme.black,
            width: DeStijlTheme.borderWidth,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Mondrian Primary Yellow Block indicator
            Container(
              width: 14.0,
              height: 24.0,
              color: DeStijlTheme.primaryYellow,
              margin: const EdgeInsets.only(right: 8.0),
            ),

            // Search Term Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'DEEP SEARCH',
                    style: DeStijlTheme.metadata(color: DeStijlTheme.grey),
                  ),
                  Text(
                    '"$query"',
                    style: DeStijlTheme.monoBold(
                      color: DeStijlTheme.black,
                      size: 13.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8.0),

            // Counter Display: [ 1 / 4 ] in JetBrains Mono
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: DeStijlTheme.white,
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: DeStijlTheme.black,
                  width: DeStijlTheme.borderWidth,
                ),
              ),
              child: Text(
                '$displayIndex / $totalMatches',
                style: DeStijlTheme.monoBold(
                  color: totalMatches == 0
                      ? DeStijlTheme.primaryRed
                      : DeStijlTheme.black,
                  size: 13.0,
                ),
              ),
            ),

            const SizedBox(width: 8.0),

            // Previous Button [ < ]
            DeStijlButton(
              onPressed: totalMatches > 0 ? onPrevious : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              shadowOffset: 2.0,
              backgroundColor: DeStijlTheme.white,
              foregroundColor: DeStijlTheme.black,
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 14.0,
                color: DeStijlTheme.black,
              ),
            ),

            const SizedBox(width: 6.0),

            // Next Button [ > ]
            DeStijlButton.primaryBlue(
              onPressed: totalMatches > 0 ? onNext : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 14.0,
                color: DeStijlTheme.white,
              ),
            ),

            const SizedBox(width: 8.0),

            // Close Button [ X ]
            DeStijlButton.primaryRed(
              onPressed: onClose,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              child: const Icon(
                Icons.close,
                size: 14.0,
                color: DeStijlTheme.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

