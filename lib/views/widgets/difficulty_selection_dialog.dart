import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/ai_difficulty.dart';

class DifficultySelectionDialog extends StatefulWidget {
  final AIDifficulty initialDifficulty;
  final Function(AIDifficulty) onDifficultySelected;

  const DifficultySelectionDialog({super.key, required this.initialDifficulty, required this.onDifficultySelected});

  @override
  State<DifficultySelectionDialog> createState() => _DifficultySelectionDialogState();
}

class _DifficultySelectionDialogState extends State<DifficultySelectionDialog> {
  late AIDifficulty selectedDifficulty;

  @override
  void initState() {
    super.initState();
    selectedDifficulty = widget.initialDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with robot icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.smart_toy, color: Theme.of(context).colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Choose AI Difficulty',
                  style: GoogleFonts.varelaRound(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Select your challenge level to start the game',
              style: GoogleFonts.varelaRound(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Difficulty options
            ...AIDifficulty.values.map((difficulty) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildDifficultyOption(context, difficulty),
              );
            }),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text('Cancel', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onDifficultySelected(selectedDifficulty);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: Text('Start Game', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyOption(BuildContext context, AIDifficulty difficulty) {
    final isSelected = selectedDifficulty == difficulty;
    final color = _getDifficultyColor(difficulty);

    return InkWell(
      onTap: () {
        setState(() {
          selectedDifficulty = difficulty;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.3), width: isSelected ? 3 : 1),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(_getDifficultyIcon(difficulty), color: color, size: 28),
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        difficulty.displayName,
                        style: GoogleFonts.varelaRound(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (isSelected) ...[const SizedBox(width: 8), Icon(Icons.check_circle, color: color, size: 20)],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    difficulty.description,
                    style: GoogleFonts.varelaRound(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
