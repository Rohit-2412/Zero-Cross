import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/player_model.dart';
import '../core/game_logic.dart';
import '../core/constants.dart';
import '../services/sound_service.dart';

class GameController extends ChangeNotifier {
  GameState _gameState;
  PlayerModel _player1;
  PlayerModel _player2;
  Timer? _timer;

  GameController({required GameMode mode, PlayerModel? player1, PlayerModel? player2})
    : _gameState = GameState.initial(mode: mode),
      _player1 = player1 ?? PlayerModel.player1(),
      _player2 = player2 ?? (mode == GameMode.singlePlayer ? PlayerModel.ai() : PlayerModel.player2());

  // Getters
  GameState get gameState => _gameState;
  PlayerModel get player1 => _player1;
  PlayerModel get player2 => _player2;
  PlayerModel get currentPlayer => _gameState.isPlayer1Turn ? _player1 : _player2;
  bool get isGameActive => _gameState.isGameActive;
  bool get isAITurn => !_gameState.isPlayer1Turn && _player2.isAI;

  void startGame() {
    _gameState = _gameState.copyWith(
      board: List.filled(9, ''),
      isPlayer1Turn: true,
      currentPlayer: Player.player1,
      winningIndices: [],
      result: '',
      status: GameStatus.playing,
      timeRemaining: AppConstants.maxGameTime,
    );

    _startTimer();
    notifyListeners();
  }

  void makeMove(int index) {
    if (!_canMakeMove(index)) return;

    SoundService.playTapSound();

    final newBoard = List<String>.from(_gameState.board);
    newBoard[index] = currentPlayer.symbol;

    _gameState = _gameState.copyWith(
      board: newBoard,
      isPlayer1Turn: !_gameState.isPlayer1Turn,
      currentPlayer: _gameState.isPlayer1Turn ? Player.player2 : Player.player1,
    );

    _checkGameEnd();
    notifyListeners();

    // If it's AI's turn, make AI move after a delay
    if (isAITurn && _gameState.isGameActive) {
      _makeAIMove();
    }
  }

  void _makeAIMove() {
    Future.delayed(const Duration(milliseconds: AppConstants.aiThinkingTime), () {
      if (!_gameState.isGameActive) return;

      final bestMove = GameLogic.getBestMove(_gameState.board);
      if (bestMove != -1) {
        final newBoard = List<String>.from(_gameState.board);
        newBoard[bestMove] = _player2.symbol;

        _gameState = _gameState.copyWith(board: newBoard, isPlayer1Turn: true, currentPlayer: Player.player1);

        _checkGameEnd();
        notifyListeners();
      }
    });
  }

  bool _canMakeMove(int index) {
    return _gameState.isGameActive &&
        _gameState.board[index].isEmpty &&
        (_gameState.mode == GameMode.multiplayer || _gameState.isPlayer1Turn);
  }

  void _checkGameEnd() {
    final winningIndices = GameLogic.checkWinner(_gameState.board);

    if (winningIndices != null) {
      final winner = _gameState.board[winningIndices[0]];
      _gameState = _gameState.copyWith(
        winningIndices: winningIndices,
        result: '$winner ${AppStrings.gameWin}',
        status: GameStatus.finished,
      );

      _updateScore(winner);
      _stopTimer();
      SoundService.playWinSound();
    } else if (GameLogic.isDraw(_gameState.board)) {
      _gameState = _gameState.copyWith(result: AppStrings.gameDraw, status: GameStatus.finished);

      _stopTimer();
      SoundService.playGameOverSound();
    }
  }

  void _updateScore(String winner) {
    if (winner == _player1.symbol) {
      _player1 = _player1.copyWith(score: _player1.score + 1);
    } else if (winner == _player2.symbol) {
      _player2 = _player2.copyWith(score: _player2.score + 1);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState.timeRemaining > 0) {
        _gameState = _gameState.copyWith(timeRemaining: _gameState.timeRemaining - 1);
        notifyListeners();
      } else {
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    _gameState = _gameState.copyWith(result: AppStrings.gameTimeUp, status: GameStatus.finished);

    _stopTimer();
    SoundService.playGameOverSound();
    notifyListeners();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void resetGame() {
    _stopTimer();
    _gameState = GameState.initial(mode: _gameState.mode).copyWith(timeRemaining: AppConstants.maxGameTime);
    notifyListeners();
  }

  void updatePlayerNames(String player1Name, String player2Name) {
    _player1 = _player1.copyWith(name: player1Name);
    _player2 = _player2.copyWith(name: player2Name);
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
