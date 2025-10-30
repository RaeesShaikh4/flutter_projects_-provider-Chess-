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

  Future<void> playMoveSound() async {
    if (!_soundEnabled) return;
    await _initialize();
    if (_audioPlayer == null) return;
    try {
      await _audioPlayer!.play(AssetSource('sounds/move.mp3'));
    } catch (e) {
      print('Move sound not available: $e');
    }
  }

  Future<void> playCaptureSound() async {
    if (!_soundEnabled) return;
    await _initialize();
    if (_audioPlayer == null) return;
    try {
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
      await _audioPlayer!.play(AssetSource('sounds/error.mp3'));
    } catch (e) {
      print('Error sound not available: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    await _initialize();
    if (_musicPlayer == null) return;
    try {
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setVolume(0.3);
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
    _audioPlayer?.dispose();
    _musicPlayer?.dispose();
  }
}
