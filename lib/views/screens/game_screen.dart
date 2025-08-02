import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/game_controller.dart';
import '../../models/game_state.dart';
import '../../models/player_model.dart';
import '../../views/widgets/game_board.dart';
import '../../views/widgets/game_dialogs.dart';
import '../../services/sound_service.dart';
import '../../core/constants.dart';
import '../../utils/ui_kit.dart';

class GameScreen extends StatefulWidget {
  final GameMode mode;
  final String? player1Name;
  final String? player2Name;

  const GameScreen({super.key, required this.mode, this.player1Name, this.player2Name});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController gameController;
  late AnimationController _slideController;
  late AnimationController _thinkingController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _thinkingAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize game controller with proper player models
    final player1 = PlayerModel.player1(name: widget.player1Name);
    final player2 =
        widget.mode == GameMode.singlePlayer ? PlayerModel.ai() : PlayerModel.player2(name: widget.player2Name);

    gameController = GameController(mode: widget.mode, player1: player1, player2: player2);

    _slideController = AnimationController(duration: AppConstants.slideAnimationDuration, vsync: this);

    _thinkingController = AnimationController(duration: AppConstants.thinkingAnimationDuration, vsync: this);

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
    gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize UIKit for responsive design
    UIKit.init(context);

    return Scaffold(
      // Enhanced AppBar with gradient background
      appBar: AppBar(
        title: Text(
          widget.mode == GameMode.singlePlayer ? AppStrings.singlePlayer : AppStrings.multiplayer,
          style: GoogleFonts.varelaRound(
            fontWeight: FontWeight.w600,
            fontSize: UIKit.scaledFont(18),
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
            ),
          ),
        ),
        actions: [
          // Enhanced sound toggle button
          Container(
            margin: EdgeInsets.only(right: UIKit.padding(12)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(UIKit.radius(12)),
            ),
            child: IconButton(
              icon: Icon(
                SoundService.soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
                size: UIKit.iconSize(24),
              ),
              onPressed: () {
                setState(() {
                  SoundService.toggleSound();
                });
              },
            ),
          ),
        ],
      ),
      // Enhanced body with gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SlideTransition(
            position: _slideAnimation,
            child: ChangeNotifierProvider.value(
              value: gameController,
              child: Consumer<GameController>(
                builder: (context, controller, child) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: UIKit.padding(16), vertical: UIKit.padding(8)),
                    child: Column(
                      children: [
                        // Score Board with name editing
                        _buildScoreBoardWithNameEdit(controller),

                        SizedBox(height: UIKit.gap(20)),

                        // Current Player/AI Thinking Indicator - Fixed height to prevent layout shifts
                        _buildCurrentPlayerIndicator(controller),

                        SizedBox(height: UIKit.gap(16)),

                        // Game Board - Fixed size to prevent overflow
                        Container(
                          height: UIKit.responsive<double>(
                            mobile: UIKit.minDimension(100),
                            tablet: UIKit.minDimension(60),
                            desktop: UIKit.minDimension(50),
                          ),
                          child: GameBoard(
                            board: controller.gameState.board,
                            winningIndices: controller.gameState.winningIndices,
                            onTap: (index) => controller.makeMove(index),
                            isGameActive:
                                controller.isGameActive &&
                                (widget.mode == GameMode.multiplayer || controller.gameState.isPlayer1Turn),
                          ),
                        ),

                        SizedBox(height: UIKit.gap(16)),

                        // Enhanced bottom controls area
                        _buildBottomControls(controller),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPlayerIndicator(GameController controller) {
    // Always return a container with fixed height to prevent layout shifts
    return Container(
      height: UIKit.responsive<double>(mobile: UIKit.height(8), tablet: UIKit.height(7), desktop: UIKit.height(6)),
      child: Center(child: _buildIndicatorContent(controller)),
    );
  }

  Widget _buildIndicatorContent(GameController controller) {
    if (controller.gameState.result.isNotEmpty || controller.gameState.status != GameStatus.playing) {
      return const SizedBox.shrink();
    }

    if (controller.isAITurn) {
      // Enhanced AI thinking indicator with pulsing animation
      _thinkingController.repeat();
      return AnimatedBuilder(
        animation: _thinkingAnimation,
        builder: (context, child) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: UIKit.padding(20)),
            padding: EdgeInsets.symmetric(horizontal: UIKit.padding(24), vertical: UIKit.padding(16)),
            decoration: BoxDecoration(
              // Enhanced gradient background for AI indicator
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppConstants.aiColor.withOpacity(0.15), AppConstants.aiColor.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(UIKit.radius(24)),
              border: Border.all(color: AppConstants.aiColor.withOpacity(0.3), width: 2),
              // Enhanced glow effect
              boxShadow: [
                BoxShadow(
                  color: AppConstants.aiColor.withOpacity(0.2),
                  blurRadius: UIKit.elevation(15),
                  offset: const Offset(0, 5),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppConstants.aiColor.withOpacity(0.1),
                  blurRadius: UIKit.elevation(30),
                  offset: const Offset(0, 10),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enhanced pulsing loader
                Container(
                  width: UIKit.iconSize(24),
                  height: UIKit.iconSize(24),
                  decoration: BoxDecoration(
                    color: AppConstants.aiColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIKit.radius(12)),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: UIKit.iconSize(16),
                      height: UIKit.iconSize(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.aiColor),
                        value: _thinkingAnimation.value,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: UIKit.gap(16)),
                // Enhanced text with typing animation effect
                Text(
                  AppStrings.aiThinking,
                  style: GoogleFonts.varelaRound(
                    fontSize: UIKit.scaledFont(16),
                    fontWeight: FontWeight.w700,
                    color: AppConstants.aiColor,
                    letterSpacing: 0.5,
                  ),
                ),
                // Animated dots for thinking effect
                AnimatedBuilder(
                  animation: _thinkingAnimation,
                  builder: (context, child) {
                    int dotCount = (_thinkingAnimation.value * 3).floor() + 1;
                    return Text(
                      '.' * dotCount.clamp(1, 3),
                      style: GoogleFonts.varelaRound(
                        fontSize: UIKit.scaledFont(16),
                        fontWeight: FontWeight.w700,
                        color: AppConstants.aiColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      _thinkingController.stop();
      _thinkingController.reset();
    }

    final currentPlayerColor =
        controller.gameState.isPlayer1Turn ? AppConstants.player1Color : AppConstants.player2Color;

    final currentPlayerSymbol =
        controller.gameState.isPlayer1Turn ? controller.player1.symbol : controller.player2.symbol;

    final turnText =
        widget.mode == GameMode.singlePlayer && controller.gameState.isPlayer1Turn
            ? AppStrings.yourTurn
            : "${controller.currentPlayer.name}'s Turn";

    // Enhanced current player indicator with pulse animation - No layout shifts
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.95, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: UIKit.padding(20)),
            padding: EdgeInsets.symmetric(horizontal: UIKit.padding(24), vertical: UIKit.padding(16)),
            decoration: BoxDecoration(
              // Enhanced gradient background
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [currentPlayerColor.withOpacity(0.15), currentPlayerColor.withOpacity(0.08)],
              ),
              borderRadius: BorderRadius.circular(UIKit.radius(24)),
              border: Border.all(color: currentPlayerColor.withOpacity(0.4), width: 2),
              // Enhanced glow effect for current player
              boxShadow: [
                BoxShadow(
                  color: currentPlayerColor.withOpacity(0.25),
                  blurRadius: UIKit.elevation(20),
                  offset: const Offset(0, 8),
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: currentPlayerColor.withOpacity(0.1),
                  blurRadius: UIKit.elevation(40),
                  offset: const Offset(0, 16),
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enhanced symbol with background circle
                Container(
                  width: UIKit.iconSize(40),
                  height: UIKit.iconSize(40),
                  decoration: BoxDecoration(
                    color: currentPlayerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(UIKit.radius(20)),
                    border: Border.all(color: currentPlayerColor.withOpacity(0.4), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      currentPlayerSymbol,
                      style: GoogleFonts.varelaRound(
                        fontSize: UIKit.scaledFont(20),
                        fontWeight: FontWeight.w900,
                        color: currentPlayerColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: UIKit.gap(16)),
                // Enhanced turn text
                Text(
                  turnText,
                  style: GoogleFonts.varelaRound(
                    fontSize: UIKit.scaledFont(16),
                    fontWeight: FontWeight.w700,
                    color: currentPlayerColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getResultText(GameController controller) {
    final result = controller.gameState.result;

    if (result.contains("O ${AppStrings.gameWin}")) {
      return widget.mode == GameMode.singlePlayer ? AppStrings.youWin : "${controller.player1.name} Wins!";
    } else if (result.contains("X ${AppStrings.gameWin}")) {
      return widget.mode == GameMode.singlePlayer ? AppStrings.aiWins : "${controller.player2.name} Wins!";
    }
    return result;
  }

  Color _getResultColor(GameController controller) {
    final result = controller.gameState.result;

    if (result.contains("O ${AppStrings.gameWin}")) {
      return Colors.green;
    } else if (result.contains("X ${AppStrings.gameWin}")) {
      return widget.mode == GameMode.singlePlayer ? Colors.red : Colors.blue;
    } else if (result.contains(AppStrings.gameDraw) || result.contains(AppStrings.gameTied)) {
      return Colors.orange;
    }
    return Theme.of(context).colorScheme.onSurface;
  }

  void _showGameOverDialog(GameController controller) {
    String winnerName = "";
    final result = controller.gameState.result;

    if (result.contains("O ${AppStrings.gameWin}")) {
      winnerName = widget.mode == GameMode.singlePlayer ? AppConstants.userPlayerName : controller.player1.name;
    } else if (result.contains("X ${AppStrings.gameWin}")) {
      winnerName = widget.mode == GameMode.singlePlayer ? AppConstants.aiPlayerName : controller.player2.name;
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
              controller.resetGame();
            },
            onHome: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
    );
  }

  Widget _buildScoreBoardWithNameEdit(GameController controller) {
    log('Building enhanced score board with name edit functionality');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: UIKit.padding(8)),
      padding: EdgeInsets.all(UIKit.padding(20)),
      decoration: BoxDecoration(
        // Enhanced gradient background for score board
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(UIKit.radius(24)),
        // Enhanced shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: UIKit.elevation(20),
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            blurRadius: UIKit.elevation(40),
            offset: const Offset(0, 16),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Enhanced Player 1 card
          _buildPlayerCard(
            controller.player1.name,
            controller.player1.score,
            controller.player1.symbol,
            controller.gameState.isPlayer1Turn,
            AppConstants.player1Color,
            () => _editPlayerName(controller, true),
            true,
          ),

          // Enhanced VS indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: UIKit.padding(20), vertical: UIKit.padding(12)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(UIKit.radius(16)),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  blurRadius: UIKit.elevation(8),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'VS',
              style: GoogleFonts.varelaRound(
                fontSize: UIKit.scaledFont(16),
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Enhanced Player 2 card
          _buildPlayerCard(
            controller.player2.name,
            controller.player2.score,
            controller.player2.symbol,
            !controller.gameState.isPlayer1Turn,
            AppConstants.player2Color,
            () => _editPlayerName(controller, false),
            widget.mode == GameMode.multiplayer, // Only allow editing in multiplayer
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(GameController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: UIKit.padding(8)),
      padding: EdgeInsets.all(UIKit.padding(20)),
      decoration: BoxDecoration(
        // Enhanced gradient background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(UIKit.radius(24)),
        // Enhanced shadow
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: UIKit.elevation(20),
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Enhanced result text area - Fixed height to prevent layout shifts
          Expanded(
            flex: 2,
            child: Container(
              height: UIKit.responsive<double>(
                mobile: UIKit.height(8),
                tablet: UIKit.height(7),
                desktop: UIKit.height(6),
              ),
              padding: EdgeInsets.symmetric(vertical: UIKit.padding(8)),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child:
                      controller.gameState.result.isNotEmpty
                          ? Container(
                            key: ValueKey(controller.gameState.result),
                            padding: EdgeInsets.symmetric(horizontal: UIKit.padding(16), vertical: UIKit.padding(12)),
                            decoration: BoxDecoration(
                              color: _getResultColor(controller).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(UIKit.radius(16)),
                              border: Border.all(color: _getResultColor(controller).withOpacity(0.3), width: 2),
                            ),
                            child: Text(
                              _getResultText(controller),
                              style: GoogleFonts.varelaRound(
                                fontSize: UIKit.scaledFont(18),
                                fontWeight: FontWeight.w700,
                                color: _getResultColor(controller),
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ),
            ),
          ),

          SizedBox(width: UIKit.gap(16)),

          // Enhanced timer/start button - Custom implementation to avoid import issues
          _buildGameTimer(controller),
        ],
      ),
    );
  }

  Widget _buildGameTimer(GameController controller) {
    final isRunning = controller.gameState.status == GameStatus.playing;
    final seconds = controller.gameState.timeRemaining;
    final maxSeconds = controller.gameState.maxTime;
    final isUrgent = seconds <= 10;

    if (isRunning) {
      final progress = 1 - (seconds / maxSeconds);

      return Container(
        width: UIKit.responsive<double>(mobile: UIKit.width(20), tablet: UIKit.width(15), desktop: UIKit.width(12)),
        height: UIKit.responsive<double>(mobile: UIKit.width(20), tablet: UIKit.width(15), desktop: UIKit.width(12)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(UIKit.radius(45)),
          boxShadow: [
            BoxShadow(
              color: isUrgent ? Colors.red.withOpacity(0.3) : Theme.of(context).primaryColor.withOpacity(0.2),
              blurRadius: UIKit.elevation(isUrgent ? 20 : 15),
              offset: const Offset(0, 5),
              spreadRadius: isUrgent ? 3 : 2,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.all(UIKit.padding(8)),
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(isUrgent ? Colors.red : Theme.of(context).primaryColor),
              ),
            ),
            Center(
              child: Text(
                seconds.toString(),
                style: GoogleFonts.varelaRound(
                  fontSize: UIKit.scaledFont(isUrgent ? 24 : 20),
                  fontWeight: FontWeight.w900,
                  color: isUrgent ? Colors.red : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(UIKit.radius(30)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: UIKit.elevation(15),
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(UIKit.radius(30)),
          child: InkWell(
            borderRadius: BorderRadius.circular(UIKit.radius(30)),
            onTap: () {
              controller.startGame();
              if (controller.gameState.isGameFinished) {
                Future.delayed(AppConstants.gameOverDelay, () {
                  if (mounted) {
                    _showGameOverDialog(controller);
                  }
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: UIKit.padding(28), vertical: UIKit.padding(16)),
              child: Text(
                controller.gameState.status == GameStatus.waiting ? AppStrings.startGame : AppStrings.playAgain,
                style: GoogleFonts.varelaRound(
                  fontSize: UIKit.scaledFont(14),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildPlayerCard(
    String name,
    int score,
    String symbol,
    bool isActive,
    Color color,
    VoidCallback onEdit,
    bool canEdit,
  ) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: UIKit.padding(4)),
        padding: EdgeInsets.all(UIKit.padding(16)),
        decoration: BoxDecoration(
          // Enhanced gradient background with glow effect for active player
          gradient:
              isActive
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                  )
                  : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey.withOpacity(0.05), Colors.grey.withOpacity(0.02)],
                  ),
          borderRadius: BorderRadius.circular(UIKit.radius(20)),
          // Enhanced border with glow effect
          border: Border.all(color: isActive ? color : Colors.transparent, width: isActive ? 3 : 1),
          // Enhanced shadow effects
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: UIKit.elevation(15),
                      offset: const Offset(0, 5),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: UIKit.elevation(30),
                      offset: const Offset(0, 10),
                      spreadRadius: 5,
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: UIKit.elevation(8),
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced name section with edit functionality
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: GoogleFonts.varelaRound(
                      fontSize: UIKit.scaledFont(isActive ? 16 : 14),
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive ? color.withOpacity(0.9) : Theme.of(context).colorScheme.onSurface,
                    ),
                    child: Text(name, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, maxLines: 1),
                  ),
                ),
                if (canEdit) ...[
                  SizedBox(width: UIKit.gap(6)),
                  // Enhanced edit button with tap animation
                  GestureDetector(
                    onTap: _canEditNames() ? onEdit : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(UIKit.padding(4)),
                      decoration: BoxDecoration(
                        color:
                            _canEditNames()
                                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(UIKit.radius(8)),
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        size: UIKit.iconSize(16),
                        color:
                            _canEditNames()
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: UIKit.gap(12)),

            // Enhanced symbol and score section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated symbol with scale effect - Using transform to prevent layout shifts
                Transform.scale(
                  scale: isActive ? 1.05 : 1.0,
                  child: Container(
                    width: UIKit.responsive<double>(
                      mobile: UIKit.width(12),
                      tablet: UIKit.width(10),
                      desktop: UIKit.width(8),
                    ),
                    height: UIKit.responsive<double>(
                      mobile: UIKit.width(12),
                      tablet: UIKit.width(10),
                      desktop: UIKit.width(8),
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(UIKit.radius(25)),
                      border: Border.all(color: color.withOpacity(0.3), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        symbol,
                        style: GoogleFonts.varelaRound(
                          fontSize: UIKit.scaledFont(20),
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: UIKit.gap(12)),

                // Enhanced score display
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Score',
                      style: GoogleFonts.varelaRound(
                        fontSize: UIKit.scaledFont(10),
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: UIKit.gap(2)),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(horizontal: UIKit.padding(12), vertical: UIKit.padding(6)),
                      decoration: BoxDecoration(
                        color: isActive ? color.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(UIKit.radius(12)),
                        border: Border.all(color: isActive ? color.withOpacity(0.3) : Colors.transparent, width: 1),
                      ),
                      child: Text(
                        '$score',
                        style: GoogleFonts.varelaRound(
                          fontSize: UIKit.scaledFont(18),
                          fontWeight: FontWeight.w800,
                          color: isActive ? color : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canEditNames() {
    // Can only edit names when game is not active (waiting or finished)
    return gameController.gameState.status == GameStatus.waiting ||
        gameController.gameState.status == GameStatus.finished;
  }

  void _editPlayerName(GameController controller, bool isPlayer1) {
    if (!_canEditNames()) {
      log('Cannot edit names while game is active');
      return;
    }

    final currentName = isPlayer1 ? controller.player1.name : controller.player2.name;
    log('Editing ${isPlayer1 ? 'Player 1' : 'Player 2'} name. Current: $currentName');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PlayerNameDialog(
            title: "Enter ${isPlayer1 ? 'Player 1' : 'Player 2'} Name",
            initialName: currentName,
            onNameSubmitted: (name) {
              log('New name submitted: $name');
              if (isPlayer1) {
                controller.updatePlayerNames(name, controller.player2.name);
              } else {
                controller.updatePlayerNames(controller.player1.name, name);
              }
            },
          ),
    );
  }
}
