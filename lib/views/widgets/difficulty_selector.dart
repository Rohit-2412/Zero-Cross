import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/ai_difficulty.dart';

class DifficultySelector extends StatelessWidget {
  final AIDifficulty selectedDifficulty;
  final ValueChanged<AIDifficulty> onDifficultyChanged;
  final bool isGameActive;

  const DifficultySelector({
    super.key,
    required this.selectedDifficulty,
    required this.onDifficultyChanged,
    this.isGameActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'AI Difficulty',
            style: GoogleFonts.varelaRound(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children:
                AIDifficulty.values.map((difficulty) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildDifficultyButton(context, difficulty),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 6),
          Text(
            selectedDifficulty.description,
            style: GoogleFonts.varelaRound(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, AIDifficulty difficulty) {
    final isSelected = selectedDifficulty == difficulty;
    final color = _getDifficultyColor(difficulty);

    return InkWell(
      onTap: isGameActive ? null : () => onDifficultyChanged(difficulty),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.3), width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getDifficultyIcon(difficulty), color: isSelected ? color : color.withValues(alpha: 0.7), size: 20),
            const SizedBox(height: 4),
            Text(
              difficulty.displayName,
              style: GoogleFonts.varelaRound(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : color.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return Colors.green;
      case AIDifficulty.medium:
        return Colors.orange;
      case AIDifficulty.hard:
        return Colors.red;
    }
  }

  IconData _getDifficultyIcon(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return Icons.sentiment_satisfied;
      case AIDifficulty.medium:
        return Icons.sentiment_neutral;
      case AIDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}
