import 'dart:math';
import 'ai_difficulty.dart';

class AILogic {
  static const List<List<int>> _winningCombinations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6], // Diagonals
  ];

  static const List<int> _magicSquare = [2, 7, 6, 9, 5, 1, 4, 3, 8];
  static const Map<int, int> _magicSquareMap = {2: 0, 7: 1, 6: 2, 9: 3, 5: 4, 1: 5, 4: 6, 3: 7, 8: 8};

  /// Get AI move based on difficulty level
  static int getAIMove(List<String> board, AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return _getEasyMove(board);
      case AIDifficulty.medium:
        return _getMediumMove(board);
      case AIDifficulty.hard:
        return _getHardMove(board);
    }
  }

  /// Easy Mode: Random moves
  static int _getEasyMove(List<String> board) {
    final availableMoves = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i].isEmpty) {
        availableMoves.add(i);
      }
    }

    if (availableMoves.isEmpty) return -1;

    final random = Random();
    return availableMoves[random.nextInt(availableMoves.length)];
  }

  /// Medium Mode: Semi-smart logic
  static int _getMediumMove(List<String> board) {
    // 1. Try to win first
    final winMove = _canWin(board, 'X');
    if (winMove != null) return winMove;

    // 2. Block player from winning
    final blockMove = _canWin(board, 'O');
    if (blockMove != null) return blockMove;

    // 3. Take center if available
    if (board[4].isEmpty) return 4;

    // 4. Take corners (with some randomness)
    final corners = [0, 2, 6, 8];
    final availableCorners = corners.where((corner) => board[corner].isEmpty).toList();
    if (availableCorners.isNotEmpty) {
      final random = Random();
      return availableCorners[random.nextInt(availableCorners.length)];
    }

    // 5. Take any available edge
    final edges = [1, 3, 5, 7];
    for (final edge in edges) {
      if (board[edge].isEmpty) return edge;
    }

    return -1;
  }

  /// Hard Mode: Unbeatable AI using Minimax
  static int _getHardMove(List<String> board) {
    int bestScore = -1000;
    int bestMove = -1;

    for (int i = 0; i < board.length; i++) {
      if (board[i].isEmpty) {
        board[i] = 'X'; // AI's move
        int score = _minimax(board, 0, false, -1000, 1000);
        board[i] = ''; // Undo move

        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }

    return bestMove;
  }

  /// Minimax algorithm with alpha-beta pruning
  static int _minimax(List<String> board, int depth, bool isMaximizing, int alpha, int beta) {
    // Check for terminal states
    final winner = _checkWinner(board);
    if (winner == 'X') return 10 - depth; // AI wins
    if (winner == 'O') return depth - 10; // Player wins
    if (_isDraw(board)) return 0; // Draw

    if (isMaximizing) {
      int maxScore = -1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i].isEmpty) {
          board[i] = 'X';
          int score = _minimax(board, depth + 1, false, alpha, beta);
          board[i] = '';
          maxScore = max(maxScore, score);
          alpha = max(alpha, score);
          if (beta <= alpha) break; // Alpha-beta pruning
        }
      }
      return maxScore;
    } else {
      int minScore = 1000;
      for (int i = 0; i < board.length; i++) {
        if (board[i].isEmpty) {
          board[i] = 'O';
          int score = _minimax(board, depth + 1, true, alpha, beta);
          board[i] = '';
          minScore = min(minScore, score);
          beta = min(beta, score);
          if (beta <= alpha) break; // Alpha-beta pruning
        }
      }
      return minScore;
    }
  }

  /// Check if a player can win on next move using magic square
  static int? _canWin(List<String> board, String player) {
    for (var i = 0; i < 9; i++) {
      for (var j = i + 1; j < 9; j++) {
        if (board[i] == player && board[j] == player) {
          final diff = 15 - (_magicSquare[i] + _magicSquare[j]);
          if (diff > 0 && diff < 10) {
            final index = _magicSquareMap[diff];
            if (index != null && board[index].isEmpty) {
              return index;
            }
          }
        }
      }
    }
    return null;
  }

  /// Check for winner
  static String? _checkWinner(List<String> board) {
    for (final combination in _winningCombinations) {
      final a = combination[0];
      final b = combination[1];
      final c = combination[2];

      if (board[a].isNotEmpty && board[a] == board[b] && board[b] == board[c]) {
        return board[a];
      }
    }
    return null;
  }

  /// Check if game is draw
  static bool _isDraw(List<String> board) {
    return !board.contains('') && _checkWinner(board) == null;
  }

  /// Get thinking time based on difficulty (for animation)
  static Duration getThinkingTime(AIDifficulty difficulty) {
    switch (difficulty) {
      case AIDifficulty.easy:
        return const Duration(milliseconds: 300);
      case AIDifficulty.medium:
        return const Duration(milliseconds: 600);
      case AIDifficulty.hard:
        return const Duration(milliseconds: 1200);
    }
  }

  /// Get AI display name with difficulty
  static String getAIDisplayName(AIDifficulty difficulty) {
    return 'AI (${difficulty.displayName})';
  }
}
