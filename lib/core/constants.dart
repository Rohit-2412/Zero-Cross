import 'package:flutter/material.dart';

class AppConstants {
  // Game Constants
  static const int maxGameTime = 30;
  static const int aiThinkingTime = 800;

  // Animation Durations
  static const Duration slideAnimationDuration = Duration(milliseconds: 500);
  static const Duration scaleAnimationDuration = Duration(milliseconds: 300);
  static const Duration thinkingAnimationDuration = Duration(milliseconds: 1000);
  static const Duration gameOverDelay = Duration(milliseconds: 1000);

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusExtraLarge = 20.0;

  // Responsive Breakpoints
  static const double mobileBreakpoint = 400.0;
  static const double tabletBreakpoint = 768.0;

  // Game Colors
  static const Color player1Color = Colors.red;
  static const Color player2Color = Colors.blue;
  static const Color aiColor = Colors.purple;
  static const Color winningColor = Colors.amber;

  // Default Player Names
  static const String defaultPlayer1Name = 'Player 1';
  static const String defaultPlayer2Name = 'Player 2';
  static const String aiPlayerName = 'AI';
  static const String userPlayerName = 'You';
}

class AppStrings {
  // Game States
  static const String gameWin = 'Wins';
  static const String gameDraw = 'Game Draw';
  static const String gameTimeUp = "Time's Up!";
  static const String gameTied = 'Game Tied';

  // Player Actions
  static const String yourTurn = 'Your Turn';
  static const String aiThinking = 'AI is thinking...';
  static const String startGame = 'Start Game';
  static const String playAgain = 'Play Again';
  static const String home = 'Home';

  // Results
  static const String youWin = 'You Win!';
  static const String aiWins = 'AI Wins!';
  static const String congratulations = 'Congratulations on your victory!';
  static const String wellPlayed = 'Great game, well played!';
  static const String thanksForPlaying = 'Thanks for playing!';

  // UI Labels
  static const String singlePlayer = 'Single Player';
  static const String multiplayer = 'Multiplayer';
  static const String playVsAI = 'Play vs AI';
  static const String playWithFriend = 'Play with a friend';
  static const String chooseGameMode = 'Choose Game Mode';
  static const String enterPlayerName = 'Enter name...';
  static const String cancel = 'Cancel';
  static const String ok = 'OK';
  static const String vs = 'VS';
}
