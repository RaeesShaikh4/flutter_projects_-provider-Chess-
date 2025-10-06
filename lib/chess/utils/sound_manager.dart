import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  AudioPlayer? _audioPlayer;
  AudioPlayer? _musicPlayer;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;
    try {
      _audioPlayer = AudioPlayer();
      _musicPlayer = AudioPlayer();
      _initialized = true;
    } catch (e) {
      print('Audio initialization failed: $e');
      _soundEnabled = false;
      _musicEnabled = false;
    }
  }

  // Sound effect methods
  Future<void> playMoveSound() async {
    if (!_soundEnabled) return;
    await _initialize();
    if (_audioPlayer == null) return;
    try {
      // Play a subtle move sound
      await _audioPlayer!.play(AssetSource('sounds/move.mp3'));
    } catch (e) {
      // Silently handle missing sound files
      print('Move sound not available: $e');
    }
  }

  Future<void> playCaptureSound() async {
    if (!_soundEnabled) return;
    await _initialize();
    if (_audioPlayer == null) return;
    try {
      // Play a more dramatic capture sound
      await _audioPlayer!.play(AssetSource('sounds/capture.mp3'));
    } catch (e) {
      print('Capture sound not available: $e');
    }
  }

  Future<void> playCheckSound() async {
    if (!_soundEnabled) return;
    await _initialize();
    if (_audioPlayer == null) return;
    try {
      // Play an alert sound for check
      await _audioPlayer!.play(AssetSource('sounds/check.mp3'));
    } catch (e) {
      print('Check sound not available: $e');
    }
  }

  Future<void> playCheckmateSound() async {
    if (!_soundEnabled) return;
    await _initialize();
    if (_audioPlayer == null) return;
    try {
      // Play a victory sound for checkmate
      await _audioPlayer!.play(AssetSource('sounds/achievement.mp3'));
    } catch (e) {
      print('Checkmate sound not available: $e');
    }
  }

  Future<void> playStalemateSound() async {
    if (!_soundEnabled) return;
    await _initialize();
    if (_audioPlayer == null) return;
    try {
      // Play a draw sound for stalemate
      await _audioPlayer!.play(AssetSource('sounds/stalemate.mp3'));
    } catch (e) {
      print('Stalemate sound not available: $e');
    }
  }

  Future<void> playButtonClickSound() async {
    if (!_soundEnabled) return;
    await _initialize();
    if (_audioPlayer == null) return;
    try {
      // Play a subtle click sound
      await _audioPlayer!.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      print('Click sound not available: $e');
    }
  }

  Future<void> playLevelCompleteSound() async {
    if (!_soundEnabled) return;
    await _initialize();
    if (_audioPlayer == null) return;
    try {
      // Play a level completion sound
      await _audioPlayer!.play(AssetSource('sounds/level_complete.mp3'));
    } catch (e) {
      print('Level complete sound not available: $e');
    }
  }

  Future<void> playErrorSound() async {
    if (!_soundEnabled) return;
    await _initialize();
    if (_audioPlayer == null) return;
    try {
      // Play an error sound for invalid moves
      await _audioPlayer!.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      print('Error sound not available: $e');
    }
  }

  // Background music methods
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    await _initialize();
    if (_musicPlayer == null) return;
    try {
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setVolume(0.3); // Lower volume for background music
      await _musicPlayer!.play(AssetSource('sounds/background_music.mp3'));
    } catch (e) {
      print('Background music not available: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    if (_musicPlayer == null) return;
    try {
      await _musicPlayer!.stop();
    } catch (e) {
      print('Error stopping background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    if (_musicPlayer == null) return;
    try {
      await _musicPlayer!.pause();
    } catch (e) {
      print('Error pausing background music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_musicEnabled) return;
    if (_musicPlayer == null) return;
    try {
      await _musicPlayer!.resume();
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
    _audioPlayer?.dispose();
    _musicPlayer?.dispose();
  }
}
