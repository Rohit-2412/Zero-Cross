import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/sound_service.dart';
import '../widgets/game_board.dart';
import '../widgets/score_board.dart';
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
    final isGameActive = timer?.isActive ?? false;
    final hasGameStarted = attempts > 0;
    final isGameOver = result.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hasGameStarted
              ? 'Playing - ${player1Name.length > 8 ? player1Name.substring(0, 8) + "..." : player1Name} vs ${player2Name.length > 8 ? player2Name.substring(0, 8) + "..." : player2Name}'
              : 'Multiplayer Game',
          style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          // Show fewer icons during active gameplay to reduce clutter
          if (!isGameActive || isGameOver) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Player Names',
              onPressed: () {
                _showPlayerNamesDialog();
              },
            ),
          ],
          IconButton(
            icon: Icon(SoundService.soundEnabled ? Icons.volume_up : Icons.volume_off),
            tooltip: 'Toggle Sound',
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
                // Score Board - Only show after game has started
                if (hasGameStarted) ...[
                  ScoreBoard(
                    player1Name: player1Name,
                    player2Name: player2Name,
                    player1Score: oScore,
                    player2Score: xScore,
                    isPlayer1Turn: oTurn,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                ],

                // Player Names Display - Always show but compact during gameplay
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people, color: Theme.of(context).colorScheme.primary, size: hasGameStarted ? 16 : 20),
                      const SizedBox(width: 8),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: GoogleFonts.varelaRound(
                          fontSize: hasGameStarted ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: Text(
                          hasGameStarted
                              ? '${_truncateName(player1Name)} vs ${_truncateName(player2Name)}'
                              : 'Players: ${_truncateName(player1Name)} vs ${_truncateName(player2Name)}',
                        ),
                      ),
                      if (!isGameActive) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => _showPlayerNamesDialog(),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.edit,
                              key: ValueKey('edit_${hasGameStarted}'),
                              color: Theme.of(context).colorScheme.primary,
                              size: hasGameStarted ? 14 : 16,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Current Player Indicator - Always rendered but with animated height
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: (isGameActive && !isGameOver) ? 50 : 0,
                  child: Center(child: _buildCurrentPlayerIndicator()),
                ),

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
                          board: list,
                          winningIndices: winningIndex,
                          onTap: _tapped,
                          isGameActive: result.isEmpty && isGameActive,
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

  double _calculateMaxBoardSize(Size screenSize, bool hasGameStarted, bool isGameActive) {
    // Calculate available space with consistent reserved heights to prevent layout shifts
    double reservedHeight = 120; // Base reserved space (app bar, padding)

    reservedHeight += hasGameStarted ? 80 : 0; // Score board (consistent)
    reservedHeight += 50; // Player names indicator (consistent)
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
            'Ready to play? Let the best player win!',
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

  void _startGame() {
    log('Starting game');
    // Stop any existing timer before starting a new one
    stopTimer();

    setState(() {
      oTurn = true;
      list = ['', '', '', '', '', '', '', '', ''];
      result = "";
      attempts++;
      winningIndex = [];
      log('Game state reset: oTurn=$oTurn, attempts=$attempts');
    });

    // Start timer after state is updated
    startTimer();
  }

  void startTimer() {
    log('Starting timer');
    // Make sure no timer is already running
    timer?.cancel();
    resetTimer();

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

  String _truncateName(String name) {
    return name.length > 10 ? '${name.substring(0, 10)}...' : name;
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

  void _showPlayerNamesDialog() {
    final player1Controller = TextEditingController(text: player1Name);
    final player2Controller = TextEditingController(text: player2Name);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Edit Player Names', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: player1Controller,
                  decoration: InputDecoration(
                    labelText: 'Player 1 (O)',
                    labelStyle: GoogleFonts.varelaRound(),
                    border: const OutlineInputBorder(),
                  ),
                  style: GoogleFonts.varelaRound(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: player2Controller,
                  decoration: InputDecoration(
                    labelText: 'Player 2 (X)',
                    labelStyle: GoogleFonts.varelaRound(),
                    border: const OutlineInputBorder(),
                  ),
                  style: GoogleFonts.varelaRound(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: GoogleFonts.varelaRound()),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    player1Name = player1Controller.text.trim().isEmpty ? 'Player 1' : player1Controller.text.trim();
                    player2Name = player2Controller.text.trim().isEmpty ? 'Player 2' : player2Controller.text.trim();
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Save', style: GoogleFonts.varelaRound(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
    );
  }
}
