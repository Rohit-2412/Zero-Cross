class PlayerModel {
  final String name;
  final String symbol;
  final int score;
  final bool isAI;

  const PlayerModel({required this.name, required this.symbol, required this.score, this.isAI = false});

  factory PlayerModel.player1({String? name}) {
    return PlayerModel(name: name ?? 'Player 1', symbol: 'O', score: 0);
  }

  factory PlayerModel.player2({String? name}) {
    return PlayerModel(name: name ?? 'Player 2', symbol: 'X', score: 0);
  }

  factory PlayerModel.ai() {
    return const PlayerModel(name: 'AI', symbol: 'X', score: 0, isAI: true);
  }

  PlayerModel copyWith({String? name, String? symbol, int? score, bool? isAI}) {
    return PlayerModel(
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      score: score ?? this.score,
      isAI: isAI ?? this.isAI,
    );
  }
}
