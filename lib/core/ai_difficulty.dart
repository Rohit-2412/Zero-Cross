enum AIDifficulty {
  easy('Easy', 'Random moves - Great for beginners'),
  medium('Medium', 'Smart blocking and winning moves'),
  hard('Hard', 'Unbeatable AI using Minimax algorithm');

  const AIDifficulty(this.displayName, this.description);

  final String displayName;
  final String description;
}
