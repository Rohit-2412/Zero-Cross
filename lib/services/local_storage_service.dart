import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/ai_difficulty.dart';
import '../models/game_statistics.dart';

class LocalStorageService {
  static const String _themeKey = 'theme_mode';
  static const String _statsKey = 'game_statistics';
  static const String _soundKey = 'sound_enabled';
  static const String _playerNameKey = 'player_name';

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
}
