import 'package:flutter/services.dart';

class SoundService {
  static bool _soundEnabled = true;

  static bool get soundEnabled => _soundEnabled;

  static void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  static Future<void> playTapSound() async {
    if (!_soundEnabled) return;

    try {
      // Using system sounds for now since we don't have audio files
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> playWinSound() async {
    if (!_soundEnabled) return;

    try {
      // Using system sounds for now since we don't have audio files
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Handle error silently
    }
  }

  static Future<void> playGameOverSound() async {
    if (!_soundEnabled) return;

    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      // Handle error silently
    }
  }
}
