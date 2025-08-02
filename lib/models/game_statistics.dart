import '../core/ai_difficulty.dart';

class GameStatistics {
  final Map<AIDifficulty, DifficultyStats> _stats = {};

  GameStatistics() {
    // Initialize stats for each difficulty
    for (final difficulty in AIDifficulty.values) {
      _stats[difficulty] = DifficultyStats();
    }
  }

  void recordWin(AIDifficulty difficulty, String winner) {
    final stats = _stats[difficulty]!;
    if (winner == 'O') {
      stats.playerWins++;
    } else if (winner == 'X') {
      stats.aiWins++;
    } else {
      stats.draws++;
    }
    stats.totalGames++;
  }

  DifficultyStats getStats(AIDifficulty difficulty) {
    return _stats[difficulty]!;
  }

  void reset() {
    for (final stats in _stats.values) {
      stats.reset();
    }
  }

  void resetDifficulty(AIDifficulty difficulty) {
    _stats[difficulty]!.reset();
  }
}

class DifficultyStats {
  int playerWins = 0;
  int aiWins = 0;
  int draws = 0;
  int totalGames = 0;

  double get winRate => totalGames > 0 ? playerWins / totalGames : 0.0;
  double get lossRate => totalGames > 0 ? aiWins / totalGames : 0.0;
  double get drawRate => totalGames > 0 ? draws / totalGames : 0.0;

  void reset() {
    playerWins = 0;
    aiWins = 0;
    draws = 0;
    totalGames = 0;
  }
}
