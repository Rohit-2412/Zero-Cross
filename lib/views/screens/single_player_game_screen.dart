import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/sound_service.dart';
import '../../services/local_storage_service.dart';
import '../../core/ai_difficulty.dart';
import '../../core/ai_logic.dart';
import '../../models/game_statistics.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';
import '../widgets/game_dialogs.dart';
import '../widgets/stats_dialog.dart';
import '../widgets/difficulty_selection_dialog.dart';
import 'stats_screen.dart';

class SinglePlayerGameScreen extends StatefulWidget {
  const SinglePlayerGameScreen({super.key});

  @override
  State<SinglePlayerGameScreen> createState() => _SinglePlayerGameScreenState();
}

class _SinglePlayerGameScreenState extends State<SinglePlayerGameScreen> with TickerProviderStateMixin {
  bool userTurn = true;
  List<String> board = ['', '', '', '', '', '', '', '', ''];
  List<int> magicSquare = [2, 7, 6, 9, 5, 1, 4, 3, 8];
  Map<int, int> magicSquareMap = {2: 0, 7: 1, 6: 2, 9: 3, 5: 4, 1: 5, 4: 6, 3: 7, 8: 8};
  List<int> winningIndex = [];
  String result = "";
  int userScore = 0;
  int computerScore = 0;
  bool stopped = false;
  static const maxSeconds = 30;
  int seconds = maxSeconds;
  Timer? timer;
  int attempts = 0;
  AIDifficulty selectedDifficulty = AIDifficulty.medium;
  late GameStatistics gameStats;
  bool showDifficultyDialog = true;
  bool _isGameInitialized = false;

  String playerName = "You";

  late AnimationController _slideController;
  late AnimationController _thinkingController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _thinkingAnimation;

  @override
  void initState() {
    super.initState();

    // Load game statistics from local storage
    gameStats = LocalStorageService.getGameStatistics();
    playerName = LocalStorageService.getPlayerName();

    _slideController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _thinkingController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    _thinkingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _thinkingController, curve: Curves.easeInOut));

    _slideController.forward();

    // Show difficulty selection dialog after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (showDifficultyDialog && !_isGameInitialized) {
        _showDifficultySelectionDialog();
      } else if (!_isGameInitialized) {
        // If returning to screen, auto-start the game
        _startGame();
      }
      _isGameInitialized = true;
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _thinkingController.dispose();
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isGameActive = timer?.isActive ?? false;
    final hasGameStarted = attempts > 0;
    final isGameOver = result.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hasGameStarted ? 'Playing - ${selectedDifficulty.displayName}' : 'Single Player',
          style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Show fewer icons during active gameplay to reduce clutter
          if (!isGameActive || isGameOver) ...[
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Change Difficulty',
              onPressed: () {
                _showDifficultySelectionDialog();
              },
            ),
            IconButton(
              icon: const Icon(Icons.analytics),
              tooltip: 'Detailed Statistics',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => StatsScreen(gameStats: gameStats)));
              },
            ),
          ],
          if (!isGameActive || hasGameStarted) ...[
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Quick Stats',
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => StatsDialog(
                        gameStats: gameStats,
                        onReset: () {
                          setState(() {
                            gameStats.reset();
                            LocalStorageService.clearStatistics();
                            userScore = 0;
                            computerScore = 0;
                          });
                        },
                      ),
                );
              },
            ),
          ],
          IconButton(
            icon: Icon(SoundService.soundEnabled ? Icons.volume_up : Icons.volume_off),
            tooltip: 'Toggle Sound',
            onPressed: () {
              setState(() {
                SoundService.toggleSound();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05, vertical: 16),
            child: Column(
              children: [
                // Score Board - Only show after game has started
                if (hasGameStarted) ...[
                  ScoreBoard(
                    player1Name: playerName,
                    player2Name: AILogic.getAIDisplayName(selectedDifficulty),
                    player1Score: userScore,
                    player2Score: computerScore,
                    isPlayer1Turn: userTurn,
                  ),
                  // SizedBox(height: screenSize.height * 0.02),
                ],

                // Current Difficulty Display - Always show but compact during gameplay
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(selectedDifficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getDifficultyColor(selectedDifficulty).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          _getDifficultyIcon(selectedDifficulty),
                          key: ValueKey('${selectedDifficulty}_${hasGameStarted}'),
                          color: _getDifficultyColor(selectedDifficulty),
                          size: hasGameStarted ? 16 : 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: GoogleFonts.varelaRound(
                          fontSize: hasGameStarted ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: _getDifficultyColor(selectedDifficulty),
                        ),
                        child: Text(
                          hasGameStarted
                              ? selectedDifficulty.displayName
                              : 'Difficulty: ${selectedDifficulty.displayName}',
                        ),
                      ),
                      if (!isGameActive) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showDifficultySelectionDialog(),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.edit,
                              key: ValueKey('edit_${hasGameStarted}'),
                              color: _getDifficultyColor(selectedDifficulty),
                              size: hasGameStarted ? 14 : 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Current Player/AI Thinking Indicator - Only during active gameplay
                _buildCurrentPlayerIndicator(),

                // Additional spacing - Always reserve space to prevent layout shifts
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isGameActive && !isGameOver ? screenSize.height * 0.015 : screenSize.height * 0.01,
                ),

                // Game Board - Adaptive size based on available space
                Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      constraints: BoxConstraints(
                        maxHeight: _calculateMaxBoardSize(screenSize, hasGameStarted, isGameActive),
                        maxWidth: screenSize.width * 0.9,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.0, // Square board
                        child: GameBoard(
                          board: board,
                          winningIndices: winningIndex,
                          onTap: _tapped,
                          isGameActive: result.isEmpty && isGameActive && userTurn,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Controls - Always show but with different content
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _getBottomControlsHeight(hasGameStarted, isGameOver),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: _buildBottomControls(hasGameStarted, isGameOver),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlayerIndicator() {
    // Use AnimatedContainer to prevent layout shifts during state changes
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: (timer?.isActive ?? false) && result.isEmpty ? 50 : 0,
      child: Center(child: _buildIndicatorContent()),
    );
  }

  Widget _buildIndicatorContent() {
    if (result.isNotEmpty || !(timer?.isActive ?? false)) {
      return const SizedBox.shrink();
    }

    if (!userTurn) {
      // AI is thinking - More compact version
      return AnimatedBuilder(
        animation: _thinkingAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                    value: _thinkingAnimation.value,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "AI thinking...",
                  style: GoogleFonts.varelaRound(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.purple),
                ),
              ],
            ),
          );
        },
      );
    }

    // Your turn indicator - More compact
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('O', style: GoogleFonts.varelaRound(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.red)),
          const SizedBox(width: 6),
          Text(
            "Your Turn",
            style: GoogleFonts.varelaRound(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    // Stop any existing timer before starting a new one
    stopTimer();

    setState(() {
      userTurn = true;
      board = ['', '', '', '', '', '', '', '', ''];
      result = "";
      attempts++;
      winningIndex = [];
    });

    // Start timer after state is updated
    startTimer();
  }

  void startTimer() {
    // Make sure no timer is already running
    timer?.cancel();
    resetTimer();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (seconds > 0) {
            seconds--;
          } else {
            _handleTimeUp();
          }
        });
      }
    });
  }

  void _handleTimeUp() {
    stopTimer();
    setState(() {
      result = "Time's Up!";
    });

    SoundService.playGameOverSound();
    _showGameOverDialog();
  }

  void stopTimer() {
    resetTimer();
    timer?.cancel();
  }

  void resetTimer() {
    seconds = maxSeconds;
  }

  void _tapped(int index) {
    if (result.isEmpty && (timer?.isActive ?? false) && userTurn && board[index].isEmpty) {
      SoundService.playTapSound();

      setState(() {
        board[index] = 'O';
        userTurn = false;

        if (!_checkWinner("O")) {
          _startAIThinking();
        }
      });
    }
  }

  void _startAIThinking() {
    _thinkingController.repeat();

    // Get thinking time based on difficulty
    final thinkingTime = AILogic.getThinkingTime(selectedDifficulty);

    Future.delayed(thinkingTime, () {
      if (mounted && !userTurn && result.isEmpty) {
        _thinkingController.stop();
        _thinkingController.reset();
        nextTurn();
      }
    });
  }

  void nextTurn() {
    if (!board.contains('')) {
      stopTimer();
      setState(() {
        result = "Game Tied";
      });

      // Record draw statistics
      gameStats.recordWin(selectedDifficulty, "Draw");

      // Save statistics to local storage
      LocalStorageService.saveGameStatistics(gameStats);

      SoundService.playGameOverSound();
      _showGameOverDialog();
      return;
    }

    // Get AI move based on selected difficulty
    final aiMove = AILogic.getAIMove(board, selectedDifficulty);

    if (aiMove != -1) {
      setState(() {
        board[aiMove] = 'X';
        userTurn = true;

        // Check if AI won
        if (!_checkWinner("X")) {
          // Continue game
        }
      });
    }
  }

  bool _checkWinner(String player) {
    for (var i = 0; i < 9; i++) {
      for (var j = i + 1; j < 9; j++) {
        for (var k = j + 1; k < 9; k++) {
          if (board[i] == player && board[j] == player && board[k] == player) {
            if (magicSquare[i] + magicSquare[j] + magicSquare[k] == 15) {
              winningIndex = [i, j, k];
              setState(() {
                result = '$player Wins';
                _updateScore(player);
                stopTimer();
              });

              SoundService.playWinSound();
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  _showGameOverDialog();
                }
              });
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  void _updateScore(String winner) {
    if (winner == "O") {
      userScore++;
    } else if (winner == "X") {
      computerScore++;
    }

    // Record statistics for current difficulty
    gameStats.recordWin(selectedDifficulty, winner);

    // Save statistics to local storage
    LocalStorageService.saveGameStatistics(gameStats);
  }

  void _showGameOverDialog() {
    String winnerName = "";
    if (result == "O Wins") {
      winnerName = "You";
    } else if (result == "X Wins") {
      winnerName = AILogic.getAIDisplayName(selectedDifficulty);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => GameOverDialog(
            result: result,
            winnerName: winnerName,
            onRestart: () {
              Navigator.of(context).pop();
              _startGame();
            },
            onHome: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
    );
  }

  double _calculateMaxBoardSize(Size screenSize, bool hasGameStarted, bool isGameActive) {
    // Calculate available space with consistent reserved heights to prevent layout shifts
    double reservedHeight = 120; // Base reserved space (app bar, padding)

    reservedHeight += hasGameStarted ? 80 : 0; // Score board (consistent)
    reservedHeight += 50; // Difficulty indicator (consistent)
    reservedHeight += 50; // Current player indicator space (always reserved)
    reservedHeight += 20; // Spacing (consistent)
    reservedHeight += 120; // Bottom controls (use max height for consistency)

    final availableHeight = screenSize.height - reservedHeight;
    final availableWidth = screenSize.width * 0.9;

    // Use the smaller dimension and ensure minimum size
    final maxSize = availableHeight < availableWidth ? availableHeight : availableWidth;
    return maxSize.clamp(250.0, 400.0);
  }

  double _getBottomControlsHeight(bool hasGameStarted, bool isGameOver) {
    if (!hasGameStarted) {
      return 120; // Larger space for start button and instructions
    } else if (isGameOver) {
      return 100; // Space for result text and restart button
    } else {
      return 80; // Compact during gameplay
    }
  }

  Widget _buildBottomControls(bool hasGameStarted, bool isGameOver) {
    if (!hasGameStarted) {
      // Before game starts - Show welcome message and start button
      return Column(
        children: [
          Text(
            'Choose your difficulty and start playing!',
            style: GoogleFonts.varelaRound(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.play_arrow),
              label: Text('Start Game', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ),
        ],
      );
    } else {
      // During or after game
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Result Text or Timer
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    isGameOver
                        ? Text(
                          _getResultText(),
                          key: ValueKey(result),
                          style: GoogleFonts.varelaRound(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: _getResultColor(),
                          ),
                          textAlign: TextAlign.center,
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer,
                              color: seconds <= 10 ? Colors.red : Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${seconds}s',
                              style: GoogleFonts.varelaRound(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: seconds <= 10 ? Colors.red : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),

          // Action Button
          ElevatedButton.icon(
            onPressed: _startGame,
            icon: Icon(isGameOver ? Icons.refresh : Icons.replay),
            label: Text(
              isGameOver ? 'Play Again' : 'Restart',
              style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      );
    }
  }

  String _getResultText() {
    if (result == "O Wins") {
      return "🎉 You Win!";
    } else if (result == "X Wins") {
      return "🤖 ${AILogic.getAIDisplayName(selectedDifficulty)} Wins!";
    } else if (result == "Game Tied") {
      return "🤝 It's a Draw!";
    } else if (result == "Time's Up!") {
      return "⏰ Time's Up!";
    }
    return result;
  }

  Color _getResultColor() {
    if (result == "O Wins") {
      return Colors.green;
    } else if (result == "X Wins") {
      return Colors.red;
    } else if (result == "Game Tied") {
      return Colors.orange;
    } else if (result == "Time's Up!") {
      return Colors.red;
    }
    return Theme.of(context).colorScheme.onSurface;
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

  void _showDifficultySelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => DifficultySelectionDialog(
            initialDifficulty: selectedDifficulty,
            onDifficultySelected: (difficulty) {
              setState(() {
                selectedDifficulty = difficulty;
                showDifficultyDialog = false;
              });
              // Auto-start game after difficulty selection
              if (!_isGameInitialized || attempts == 0) {
                _startGame();
              }
            },
          ),
    );
  }
}
