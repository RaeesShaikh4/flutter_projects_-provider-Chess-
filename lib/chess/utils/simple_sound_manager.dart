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

  Future<void> playMoveSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.lightImpact();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/move.mp3'));
    } catch (e) {
      print('Error playing move sound: $e');
    }
  }

  Future<void> playCaptureSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.mediumImpact();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/capture.mp3'));
    } catch (e) {
      print('Error playing capture sound: $e');
    }
  }

  Future<void> playCheckSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.heavyImpact();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/check.mp3'));
    } catch (e) {
      print('Error playing check sound: $e');
    }
  }

  Future<void> playCheckmateSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    HapticFeedback.heavyImpact();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/checkmate.mp3'));
    } catch (e) {
      print('Error playing checkmate sound: $e');
    }
  }

  Future<void> playStalemateSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.lightImpact();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/stalemate.mp3'));
    } catch (e) {
      print('Error playing stalemate sound: $e');
    }
  }

  Future<void> playButtonClickSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.selectionClick();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      print('Error playing button click sound: $e');
    }
  }

  Future<void> playLevelCompleteSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/level_complete.mp3'));
    } catch (e) {
      print('Error playing level complete sound: $e');
    }
  }

  Future<void> playErrorSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.lightImpact();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/illegal_move.mp3'));
    } catch (e) {
      print('Error playing error sound: $e');
    }
  }

  Future<void> playCastleSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.mediumImpact();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/castle.mp3'));
    } catch (e) {
      print('Error playing castle sound: $e');
    }
  }

  Future<void> playAchievementSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/achievement.mp3'));
    } catch (e) {
      print('Error playing achievement sound: $e');
    }
  }

  Future<void> playGameDrawSound() async {
    if (!_soundEnabled) return;
    HapticFeedback.lightImpact();
    
    try {
      await _audioPlayer.play(AssetSource('sounds/game-draw.mp3'));
    } catch (e) {
      print('Error playing game draw sound: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(0.3);
      await _musicPlayer.play(AssetSource('sounds/chess_background_music.mp3'));
    } catch (e) {
      print('Error playing background music: $e');
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
      final state = await _musicPlayer.state;
      if (state == PlayerState.playing) {
        return;
      }
      await _musicPlayer.resume();
    } catch (e) {
      print('Error resuming background music: $e');
    }
  }

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

  void dispose() {
    _audioPlayer.dispose();
    _musicPlayer.dispose();
  }
}
