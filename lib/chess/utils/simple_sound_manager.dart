import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SimpleSoundManager {
  static final SimpleSoundManager _instance = SimpleSoundManager._internal();
  factory SimpleSoundManager() => _instance;
  SimpleSoundManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  // Sound effect methods - haptic feedback with audio fallback
  Future<void> playMoveSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.lightImpact();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/move.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  Future<void> playCaptureSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.mediumImpact();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/capture.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  Future<void> playCheckSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.heavyImpact();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/check.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  Future<void> playCheckmateSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.heavyImpact();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/checkmate.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  Future<void> playStalemateSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.lightImpact();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/stalemate.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  Future<void> playButtonClickSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.selectionClick();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  Future<void> playLevelCompleteSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/level_complete.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  Future<void> playErrorSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.lightImpact();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/illegal_move.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  Future<void> playCastleSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.mediumImpact();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/castle.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  Future<void> playAchievementSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/achievement.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  Future<void> playGameDrawSound() async {
    if (!_soundEnabled) return;
    // Always provide haptic feedback
    HapticFeedback.lightImpact();
    
    // Try to play audio (will fail gracefully if files are invalid)
    try {
      await _audioPlayer.play(AssetSource('sounds/game-draw.mp3'));
    } catch (e) {
      // Silently handle audio errors - haptic feedback is already provided
    }
  }

  // Background music methods - graceful fallback for invalid MP3 files
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.3); // Lower volume for background music
      await _musicPlayer.play(AssetSource('sounds/chess_background_music.mp3'));
    } catch (e) {
      // Silently handle audio errors - provide visual feedback instead
      print('Background music not available (using visual feedback only)');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      // Check if music is already playing before trying to resume
      final state = await _musicPlayer.state;
      if (state == PlayerState.playing) {
        return; // Music is already playing, no need to resume
      }
      await _musicPlayer.resume();
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }

  // Sound control methods
  void enableSound() {
    _soundEnabled = true;
  }

  void disableSound() {
    _soundEnabled = false;
  }

  bool get isSoundEnabled => _soundEnabled;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  // Music control methods
  void enableMusic() {
    _musicEnabled = true;
  }

  void disableMusic() {
    _musicEnabled = false;
    stopBackgroundMusic();
  }

  bool get isMusicEnabled => _musicEnabled;

  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (_musicEnabled) {
      playBackgroundMusic();
    } else {
      stopBackgroundMusic();
    }
  }

  // Dispose method
  void dispose() {
    _audioPlayer.dispose();
    _musicPlayer.dispose();
  }
}
