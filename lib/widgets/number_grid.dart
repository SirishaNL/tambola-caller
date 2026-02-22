import 'package:flutter/material.dart';

/// Shows numbers 1–90 in a grid. Called numbers are highlighted with a lively game-board style.
/// Fits available width and scrolls vertically so nothing is cropped on small screens.
class NumberGrid extends StatelessWidget {
  final Set<int> calledNumbers;
  final bool isDark;

  const NumberGrid({
    super.key,
    required this.calledNumbers,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // Called: vibrant green gradient with glow
    final calledGradientStart = isDark ? const Color(0xFF2E7D32) : const Color(0xFF43A047);
    final calledGradientEnd = isDark ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32);
    final calledText = isDark ? Colors.green.shade100 : Colors.white;

    // Uncalled: soft tile look with subtle gradient
    final uncalledGradientStart = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final uncalledGradientEnd = isDark ? Colors.grey.shade900 : Colors.grey.shade300;
    final uncalledText = isDark ? Colors.grey.shade300 : Colors.black87;
    final uncalledBorder = isDark ? Colors.grey.shade700 : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.grey.shade900,
                  Colors.grey.shade800,
                ]
              : [
                  Colors.grey.shade200,
                  Colors.grey.shade100,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Fit 10 columns in available width; use smaller spacing on narrow screens
          final availableWidth = constraints.maxWidth - 0; // padding already in container
          const crossAxisCount = 10;
          const spacing = 6.0;
          final cellWidth = (availableWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
          final cellHeight = cellWidth / 0.95;
          final fontSize = (cellWidth * 0.55).clamp(14.0, 22.0);

          return SizedBox(
            height: 9 * cellHeight + 8 * spacing,
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.95,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemCount: 90,
              itemBuilder: (context, index) {
                final n = index + 1;
                final called = calledNumbers.contains(n);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: called
                          ? [calledGradientStart, calledGradientEnd]
                          : [uncalledGradientStart, uncalledGradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: called
                          ? (isDark ? Colors.green.shade400 : Colors.green.shade300)
                          : uncalledBorder.withOpacity(0.6),
                      width: called ? 1.5 : 1,
                    ),
                    boxShadow: [
                      if (called) ...[
                        BoxShadow(
                          color: calledGradientStart.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ] else
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.25 : 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Text(
                    '$n',
                    style: TextStyle(
                      color: called ? calledText : uncalledText,
                      fontWeight: called ? FontWeight.bold : FontWeight.w600,
                      fontSize: fontSize,
                      shadows: called
                          ? [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
