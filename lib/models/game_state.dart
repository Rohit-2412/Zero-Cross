enum GameMode { singlePlayer, multiplayer }

enum GameStatus { waiting, playing, paused, finished }

enum Player { player1, player2, ai }

class GameState {
  final List<String> board;
  final bool isPlayer1Turn;
  final Player currentPlayer;
  final List<int> winningIndices;
  final String result;
  final GameStatus status;
  final GameMode mode;
  final int timeRemaining;
  final int maxTime;

  const GameState({
    required this.board,
    required this.isPlayer1Turn,
    required this.currentPlayer,
    required this.winningIndices,
    required this.result,
    required this.status,
    required this.mode,
    required this.timeRemaining,
    required this.maxTime,
  });

  factory GameState.initial({required GameMode mode}) {
    return GameState(
      board: List.filled(9, ''),
      isPlayer1Turn: true,
      currentPlayer: Player.player1,
      winningIndices: [],
      result: '',
      status: GameStatus.waiting,
      mode: mode,
      timeRemaining: 30,
      maxTime: 30,
    );
  }

  GameState copyWith({
    List<String>? board,
    bool? isPlayer1Turn,
    Player? currentPlayer,
    List<int>? winningIndices,
    String? result,
    GameStatus? status,
    GameMode? mode,
    int? timeRemaining,
    int? maxTime,
  }) {
    return GameState(
      board: board ?? this.board,
      isPlayer1Turn: isPlayer1Turn ?? this.isPlayer1Turn,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winningIndices: winningIndices ?? this.winningIndices,
      result: result ?? this.result,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      maxTime: maxTime ?? this.maxTime,
    );
  }

  bool get isGameActive => status == GameStatus.playing && result.isEmpty;
  bool get isGameFinished => status == GameStatus.finished || result.isNotEmpty;
  double get timeProgress => timeRemaining / maxTime;
}
