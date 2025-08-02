import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScoreBoard extends StatelessWidget {
  final String player1Name;
  final String player2Name;
  final int player1Score;
  final int player2Score;
  final bool isPlayer1Turn;

  const ScoreBoard({
    super.key,
    required this.player1Name,
    required this.player2Name,
    required this.player1Score,
    required this.player2Score,
    required this.isPlayer1Turn,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _PlayerScore(
            name: player1Name,
            score: player1Score,
            isActive: isPlayer1Turn,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade600,
            symbol: 'O',
            isSmallScreen: isSmallScreen,
          ),
          _ScoreDivider(player1Score: player1Score, player2Score: player2Score, isSmallScreen: isSmallScreen),
          _PlayerScore(
            name: player2Name,
            score: player2Score,
            isActive: !isPlayer1Turn,
            color: Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade300 : Colors.blue.shade600,
            symbol: 'X',
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  final String name;
  final int score;
  final bool isActive;
  final Color color;
  final String symbol;
  final bool isSmallScreen;

  const _PlayerScore({
    required this.name,
    required this.score,
    required this.isActive,
    required this.color,
    required this.symbol,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symbol,
              style: GoogleFonts.varelaRound(
                fontSize: isSmallScreen ? 24 : 32,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: GoogleFonts.varelaRound(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              score.toString(),
              style: GoogleFonts.inter(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreDivider extends StatelessWidget {
  final int player1Score;
  final int player2Score;
  final bool isSmallScreen;

  const _ScoreDivider({required this.player1Score, required this.player2Score, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "VS",
            style: GoogleFonts.varelaRound(
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Container(width: 2, height: 30, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
        ],
      ),
    );
  }
}
