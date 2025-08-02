import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/sound_service.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';
import '../widgets/game_timer.dart';
import '../widgets/game_dialogs.dart';

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

  String playerName = "You";

  late AnimationController _slideController;
  late AnimationController _thinkingController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _thinkingAnimation;

  @override
  void initState() {
    super.initState();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Single Player', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(SoundService.soundEnabled ? Icons.volume_up : Icons.volume_off),
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
                // Score Board
                ScoreBoard(
                  player1Name: playerName,
                  player2Name: "AI",
                  player1Score: userScore,
                  player2Score: computerScore,
                  isPlayer1Turn: userTurn,
                ),

                SizedBox(height: screenSize.height * 0.03),

                // Current Player/AI Thinking Indicator
                _buildCurrentPlayerIndicator(),

                SizedBox(height: screenSize.height * 0.02),

                // Game Board
                Expanded(
                  child: Center(
                    child: GameBoard(
                      board: board,
                      winningIndices: winningIndex,
                      onTap: _tapped,
                      isGameActive: result.isEmpty && (timer?.isActive ?? false) && userTurn,
                    ),
                  ),
                ),

                SizedBox(height: screenSize.height * 0.02),

                // Bottom Controls
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Result Text
                      Expanded(
                        child: Text(
                          result.isNotEmpty ? _getResultText() : "",
                          style: GoogleFonts.varelaRound(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: _getResultColor(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Timer/Start Button
                      GameTimer(
                        seconds: seconds,
                        maxSeconds: maxSeconds,
                        isRunning: timer?.isActive ?? false,
                        onStart: _startGame,
                        buttonText: attempts == 0 ? "Start Game" : "Play Again",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlayerIndicator() {
    if (result.isNotEmpty || !(timer?.isActive ?? false)) {
      return const SizedBox.shrink();
    }

    if (!userTurn) {
      // AI is thinking
      return AnimatedBuilder(
        animation: _thinkingAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                    value: _thinkingAnimation.value,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "AI is thinking...",
                  style: GoogleFonts.varelaRound(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.purple),
                ),
              ],
            ),
          );
        },
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('O', style: GoogleFonts.varelaRound(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.red)),
          const SizedBox(width: 8),
          Text(
            "Your Turn",
            style: GoogleFonts.varelaRound(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _startGame() {
    setState(() {
      userTurn = true;
      startTimer();
      board = ['', '', '', '', '', '', '', '', ''];
      result = "";
      attempts++;
      winningIndex = [];
    });
  }

  void startTimer() {
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

    // Simulate AI thinking time
    Future.delayed(const Duration(milliseconds: 800), () {
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
      SoundService.playGameOverSound();
      _showGameOverDialog();
      return;
    }

    if (canWin("X") || canWin("O")) {
      return;
    }

    randomMove();
  }

  bool canWin(String player) {
    if (player == "X") {
      for (var i = 0; i < 9; i++) {
        for (var j = i + 1; j < 9; j++) {
          if (board[i] == 'X' && board[j] == 'X') {
            final diff = 15 - (magicSquare[i] + magicSquare[j]);
            if (diff > 0 && diff < 10) {
              final index = magicSquareMap[diff];
              if (index != null && board[index] == '') {
                setState(() {
                  board[index] = 'X';
                  result = "X Wins";
                  winningIndex = [i, j, index];
                  _updateScore("X");
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
    } else {
      for (var i = 0; i < 9; i++) {
        for (var j = i + 1; j < 9; j++) {
          if (board[i] == 'O' && board[j] == 'O') {
            final diff = 15 - (magicSquare[i] + magicSquare[j]);
            if (diff > 0 && diff < 10) {
              final index = magicSquareMap[diff];
              if (index != null && board[index] == '') {
                setState(() {
                  board[index] = 'X';
                  userTurn = true;
                });
                return true;
              }
            }
          }
        }
      }
      return false;
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

  void randomMove() {
    if (board[4] == '') {
      setState(() {
        board[4] = 'X';
        userTurn = true;
      });
      return;
    }

    final corners = [0, 2, 6, 8];
    for (var i = 0; i < corners.length; i++) {
      if (board[corners[i]] == '') {
        setState(() {
          board[corners[i]] = 'X';
          userTurn = true;
        });
        return;
      }
    }

    final edges = [1, 3, 5, 7];
    for (var i = 0; i < edges.length; i++) {
      if (board[edges[i]] == '') {
        setState(() {
          board[edges[i]] = 'X';
          userTurn = true;
        });
        return;
      }
    }
  }

  void _updateScore(String winner) {
    if (winner == "O") {
      userScore++;
    } else if (winner == "X") {
      computerScore++;
    }
  }

  String _getResultText() {
    if (result == "O Wins") {
      return "You Win!";
    } else if (result == "X Wins") {
      return "AI Wins!";
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
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  void _showGameOverDialog() {
    String winnerName = "";
    if (result == "O Wins") {
      winnerName = "You";
    } else if (result == "X Wins") {
      winnerName = "AI";
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
}
