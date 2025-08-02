import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/ai_difficulty.dart';
import '../models/game_statistics.dart';
import '../providers/theme_provider.dart';

class LocalStorageService {
  static const String _themeKey = 'theme_mode';
  static const String _statsKey = 'game_statistics';
  static const String _soundKey = 'sound_enabled';
  static const String _playerNameKey = 'player_name';
  static const String _colorSchemeKey = 'color_scheme';
  static const String _boardStyleKey = 'board_style';
  static const String _animationsEnabledKey = 'animations_enabled';
  static const String _boardCornerRadiusKey = 'board_corner_radius';
  static const String _gameTimerEnabledKey = 'game_timer_enabled';
  static const String _gameTimerDurationKey = 'game_timer_duration';
  static const String _vibrationsEnabledKey = 'vibrations_enabled';
  static const String _showHintsKey = 'show_hints';
  static const String _autoSaveGameKey = 'auto_save_game';
  static const String _backgroundMusicKey = 'background_music';

  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme Settings
  static Future<void> saveThemeMode(bool isDarkMode) async {
    await _prefs?.setBool(_themeKey, isDarkMode);
  }

  static bool getThemeMode() {
    return _prefs?.getBool(_themeKey) ?? false;
  }

  // Sound Settings
  static Future<void> saveSoundEnabled(bool isEnabled) async {
    await _prefs?.setBool(_soundKey, isEnabled);
  }

  static bool getSoundEnabled() {
    return _prefs?.getBool(_soundKey) ?? true;
  }

  // Player Name
  static Future<void> savePlayerName(String name) async {
    await _prefs?.setString(_playerNameKey, name);
  }

  static String getPlayerName() {
    return _prefs?.getString(_playerNameKey) ?? 'You';
  }

  // Game Statistics
  static Future<void> saveGameStatistics(GameStatistics stats) async {
    final Map<String, dynamic> statsMap = {};

    for (final difficulty in AIDifficulty.values) {
      final difficultyStats = stats.getStats(difficulty);
      statsMap[difficulty.name] = {
        'playerWins': difficultyStats.playerWins,
        'aiWins': difficultyStats.aiWins,
        'draws': difficultyStats.draws,
        'totalGames': difficultyStats.totalGames,
      };
    }

    await _prefs?.setString(_statsKey, jsonEncode(statsMap));
  }

  static GameStatistics getGameStatistics() {
    final statsString = _prefs?.getString(_statsKey);
    final gameStats = GameStatistics();

    if (statsString != null) {
      try {
        final Map<String, dynamic> statsMap = jsonDecode(statsString);

        for (final difficulty in AIDifficulty.values) {
          final difficultyData = statsMap[difficulty.name];
          if (difficultyData != null) {
            final stats = gameStats.getStats(difficulty);
            stats.playerWins = difficultyData['playerWins'] ?? 0;
            stats.aiWins = difficultyData['aiWins'] ?? 0;
            stats.draws = difficultyData['draws'] ?? 0;
            stats.totalGames = difficultyData['totalGames'] ?? 0;
          }
        }
      } catch (e) {
        // If there's an error parsing, return empty stats
        return GameStatistics();
      }
    }

    return gameStats;
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await _prefs?.clear();
  }

  // Clear only statistics
  static Future<void> clearStatistics() async {
    await _prefs?.remove(_statsKey);
  }

  // Color Scheme Settings
  static Future<void> saveColorScheme(AppColorScheme scheme) async {
    await _prefs?.setString(_colorSchemeKey, scheme.name);
  }

  static AppColorScheme getColorScheme() {
    final schemeName = _prefs?.getString(_colorSchemeKey);
    if (schemeName != null) {
      try {
        return AppColorScheme.values.firstWhere((scheme) => scheme.name == schemeName);
      } catch (e) {
        return AppColorScheme.blue;
      }
    }
    return AppColorScheme.blue;
  }

  // Board Style Settings
  static Future<void> saveBoardStyle(BoardStyle style) async {
    await _prefs?.setString(_boardStyleKey, style.name);
  }

  static BoardStyle getBoardStyle() {
    final styleName = _prefs?.getString(_boardStyleKey);
    if (styleName != null) {
      try {
        return BoardStyle.values.firstWhere((style) => style.name == styleName);
      } catch (e) {
        return BoardStyle.classic;
      }
    }
    return BoardStyle.classic;
  }

  // Animation Settings
  static Future<void> saveAnimationsEnabled(bool enabled) async {
    await _prefs?.setBool(_animationsEnabledKey, enabled);
  }

  static bool getAnimationsEnabled() {
    return _prefs?.getBool(_animationsEnabledKey) ?? true;
  }

  // Board Corner Radius
  static Future<void> saveBoardCornerRadius(double radius) async {
    await _prefs?.setDouble(_boardCornerRadiusKey, radius);
  }

  static double getBoardCornerRadius() {
    return _prefs?.getDouble(_boardCornerRadiusKey) ?? 12.0;
  }

  // Game Timer Settings
  static Future<void> saveGameTimerEnabled(bool enabled) async {
    await _prefs?.setBool(_gameTimerEnabledKey, enabled);
  }

  static bool getGameTimerEnabled() {
    return _prefs?.getBool(_gameTimerEnabledKey) ?? true;
  }

  static Future<void> saveGameTimerDuration(int seconds) async {
    await _prefs?.setInt(_gameTimerDurationKey, seconds);
  }

  static int getGameTimerDuration() {
    return _prefs?.getInt(_gameTimerDurationKey) ?? 30;
  }

  // Vibration Settings
  static Future<void> saveVibrationsEnabled(bool enabled) async {
    await _prefs?.setBool(_vibrationsEnabledKey, enabled);
  }

  static bool getVibrationsEnabled() {
    return _prefs?.getBool(_vibrationsEnabledKey) ?? true;
  }

  // Hints Settings
  static Future<void> saveShowHints(bool show) async {
    await _prefs?.setBool(_showHintsKey, show);
  }

  static bool getShowHints() {
    return _prefs?.getBool(_showHintsKey) ?? true;
  }

  // Auto Save Game
  static Future<void> saveAutoSaveGame(bool autoSave) async {
    await _prefs?.setBool(_autoSaveGameKey, autoSave);
  }

  static bool getAutoSaveGame() {
    return _prefs?.getBool(_autoSaveGameKey) ?? true;
  }

  // Background Music
  static Future<void> saveBackgroundMusic(bool enabled) async {
    await _prefs?.setBool(_backgroundMusicKey, enabled);
  }

  static bool getBackgroundMusic() {
    return _prefs?.getBool(_backgroundMusicKey) ?? false;
  }

  // Player Symbols
  static Future<void> savePlayerXSymbol(String symbol) async {
    await _prefs?.setString('player_x_symbol', symbol);
  }

  static String getPlayerXSymbol() {
    return _prefs?.getString('player_x_symbol') ?? 'X';
  }

  static Future<void> savePlayerOSymbol(String symbol) async {
    await _prefs?.setString('player_o_symbol', symbol);
  }

  static String getPlayerOSymbol() {
    return _prefs?.getString('player_o_symbol') ?? 'O';
  }
}
