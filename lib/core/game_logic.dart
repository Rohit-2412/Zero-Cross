class GameLogic {
  static const List<List<int>> _winningCombinations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6], // Diagonals
  ];

  static const List<int> _magicSquare = [2, 7, 6, 9, 5, 1, 4, 3, 8];
  static const Map<int, int> _magicSquareMap = {2: 0, 7: 1, 6: 2, 9: 3, 5: 4, 1: 5, 4: 6, 3: 7, 8: 8};

  /// Check if there's a winner using standard combinations
  static List<int>? checkWinner(List<String> board) {
    for (final combination in _winningCombinations) {
      final a = combination[0];
      final b = combination[1];
      final c = combination[2];

      if (board[a].isNotEmpty && board[a] == board[b] && board[b] == board[c]) {
        return combination;
      }
    }
    return null;
  }

  /// Check if there's a winner using magic square (for AI logic)
  static List<int>? checkWinnerMagicSquare(List<String> board, String player) {
    for (var i = 0; i < 9; i++) {
      for (var j = i + 1; j < 9; j++) {
        for (var k = j + 1; k < 9; k++) {
          if (board[i] == player && board[j] == player && board[k] == player) {
            if (_magicSquare[i] + _magicSquare[j] + _magicSquare[k] == 15) {
              return [i, j, k];
            }
          }
        }
      }
    }
    return null;
  }

  /// Check if game is draw
  static bool isDraw(List<String> board) {
    return !board.contains('') && checkWinner(board) == null;
  }

  /// Get winner from result string
  static String getWinner(List<String> board) {
    final winningIndices = checkWinner(board);
    if (winningIndices != null) {
      return board[winningIndices[0]];
    }
    return '';
  }

  /// AI Logic: Check if AI can win on next move
  static int? canWin(List<String> board, String player) {
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

  /// AI Logic: Get best move for AI
  static int getBestMove(List<String> board) {
    // 1. Try to win
    final winMove = canWin(board, 'X');
    if (winMove != null) return winMove;

    // 2. Block player from winning
    final blockMove = canWin(board, 'O');
    if (blockMove != null) return blockMove;

    // 3. Take center if available
    if (board[4].isEmpty) return 4;

    // 4. Take corners
    final corners = [0, 2, 6, 8];
    for (final corner in corners) {
      if (board[corner].isEmpty) return corner;
    }

    // 5. Take edges
    final edges = [1, 3, 5, 7];
    for (final edge in edges) {
      if (board[edge].isEmpty) return edge;
    }

    return -1; // Should never reach here
  }
}
