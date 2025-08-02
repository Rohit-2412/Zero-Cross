import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/sound_service.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';
import '../widgets/game_timer.dart';
import '../widgets/game_dialogs.dart';

class MultiplayerGameScreen extends StatefulWidget {
  const MultiplayerGameScreen({super.key});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> with TickerProviderStateMixin {
  bool oTurn = true;
  List<String> list = ['', '', '', '', '', '', '', '', ''];
  List<int> winningIndex = [];
  String result = "";
  int oScore = 0;
  int xScore = 0;
  bool stopped = false;
  static const maxSeconds = 30;
  int seconds = maxSeconds;
  Timer? timer;
  int attempts = 0;

  // Player names
  String player1Name = "Player 1";
  String player2Name = "Player 2";

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    log('MultiplayerGameScreen initialized');
    _slideController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));

    _slideController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('Fetching route arguments for player names');

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      player1Name = args['player1Name'] ?? player1Name;
      player2Name = args['player2Name'] ?? player2Name;
      log('Player names set: player1Name=$player1Name, player2Name=$player2Name');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('Building MultiplayerGameScreen UI');
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Multiplayer Game', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(SoundService.soundEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                SoundService.toggleSound();
                log('Sound toggled: ${SoundService.soundEnabled}');
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
                  player1Name: player1Name,
                  player2Name: player2Name,
                  player1Score: oScore,
                  player2Score: xScore,
                  isPlayer1Turn: oTurn,
                ),

                SizedBox(height: screenSize.height * 0.03),

                // Current Player Indicator
                _buildCurrentPlayerIndicator(),

                SizedBox(height: screenSize.height * 0.02),

                // Game Board
                Expanded(
                  child: Center(
                    child: GameBoard(
                      board: list,
                      winningIndices: winningIndex,
                      onTap: _tapped,
                      isGameActive: result.isEmpty && (timer?.isActive ?? false),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: oTurn ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: oTurn ? Colors.red : Colors.blue, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            oTurn ? 'O' : 'X',
            style: GoogleFonts.varelaRound(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: oTurn ? Colors.red : Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "${oTurn ? player1Name : player2Name}'s Turn",
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
    log('Starting game');
    setState(() {
      oTurn = true;
      startTimer();
      list = ['', '', '', '', '', '', '', '', ''];
      result = "";
      attempts++;
      winningIndex = [];
      log('Game state reset: oTurn=$oTurn, attempts=$attempts');
    });
  }

  void startTimer() {
    log('Starting timer');
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (seconds > 0) {
            seconds--;
            log('Timer tick: seconds=$seconds');
          } else {
            _handleTimeUp();
          }
        });
      }
    });
  }

  void _handleTimeUp() {
    log('Time up');
    stopTimer();
    setState(() {
      result = "Time's Up!";
      log('Result updated: $result');
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
    log('Cell tapped: index=$index');
    if (result.isEmpty && (timer?.isActive ?? false) && list[index].isEmpty) {
      SoundService.playTapSound();

      setState(() {
        if (oTurn) {
          list[index] = 'O';
        } else {
          list[index] = 'X';
        }
        log('Cell updated: index=$index, value=${list[index]}');
        oTurn = !oTurn;
        _checkWinner();
      });
    }
  }

  void _checkWinner() {
    log('Checking winner');
    final winningCombinations = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    for (final combination in winningCombinations) {
      final a = combination[0];
      final b = combination[1];
      final c = combination[2];

      if (list[a].isNotEmpty && list[a] == list[b] && list[b] == list[c]) {
        setState(() {
          result = "${list[a]} Wins";
          winningIndex = combination;
          log('Winner found: $result, winningIndex=$winningIndex');
          _updateScore(list[a]);
        });

        stopTimer();
        SoundService.playWinSound();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            _showGameOverDialog();
          }
        });
        return;
      }
    }

    if (!list.contains('')) {
      setState(() {
        result = "Game Draw";
        log('Game draw detected');
      });

      stopTimer();
      SoundService.playGameOverSound();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showGameOverDialog();
        }
      });
    }
  }

  void _updateScore(String winner) {
    log('Updating score for winner: $winner');
    if (winner == 'O') {
      oScore++;
    } else if (winner == 'X') {
      xScore++;
    }
    log('Scores updated: oScore=$oScore, xScore=$xScore');
  }

  String _getResultText() {
    if (result == "O Wins") {
      return "$player1Name Wins!";
    } else if (result == "X Wins") {
      return "$player2Name Wins!";
    }
    return result;
  }

  Color _getResultColor() {
    if (result == "O Wins") {
      return Colors.red;
    } else if (result == "X Wins") {
      return Colors.blue;
    } else if (result == "Game Draw") {
      return Colors.orange;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  void _showGameOverDialog() {
    log('Showing game over dialog');
    String winnerName = "";
    if (result == "O Wins") {
      winnerName = player1Name;
    } else if (result == "X Wins") {
      winnerName = player2Name;
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
