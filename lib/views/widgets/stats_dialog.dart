import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/ai_difficulty.dart';
import '../../models/game_statistics.dart';

class StatsDialog extends StatelessWidget {
  final GameStatistics gameStats;
  final VoidCallback onReset;

  const StatsDialog({super.key, required this.gameStats, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.bar_chart, color: Theme.of(context).colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Game Statistics',
                  style: GoogleFonts.varelaRound(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Statistics for each difficulty
            ...AIDifficulty.values.map((difficulty) {
              final stats = gameStats.getStats(difficulty);
              return _buildDifficultyStats(context, difficulty, stats);
            }),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    onReset();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text('Reset Stats', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Close', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyStats(BuildContext context, AIDifficulty difficulty, DifficultyStats stats) {
    final color = _getDifficultyColor(difficulty);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Difficulty header
          Row(
            children: [
              Icon(_getDifficultyIcon(difficulty), color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                difficulty.displayName,
                style: GoogleFonts.varelaRound(fontSize: 18, fontWeight: FontWeight.w600, color: color),
              ),
              const Spacer(),
              Text(
                '${stats.totalGames} games',
                style: GoogleFonts.varelaRound(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          if (stats.totalGames > 0) ...[
            const SizedBox(height: 12),

            // Win/Loss/Draw stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Wins', stats.playerWins, Colors.green),
                _buildStatItem(context, 'Losses', stats.aiWins, Colors.red),
                _buildStatItem(context, 'Draws', stats.draws, Colors.orange),
              ],
            ),

            const SizedBox(height: 8),

            // Win rate
            Text(
              'Win Rate: ${(stats.winRate * 100).toStringAsFixed(1)}%',
              style: GoogleFonts.varelaRound(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'No games played yet',
              style: GoogleFonts.varelaRound(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(), style: GoogleFonts.varelaRound(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        Text(
          label,
          style: GoogleFonts.varelaRound(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
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
