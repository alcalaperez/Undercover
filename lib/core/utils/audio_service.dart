import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  final AudioPlayer _soundEffectPlayer = AudioPlayer();

  bool _soundEffectsEnabled = true;
  bool _vibrationEnabled = true;
  bool _musicEnabled = true;
  double _musicVolume = 0.3;
  double _effectsVolume = 0.7;

  // Getters
  bool get soundEffectsEnabled => _soundEffectsEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get musicEnabled => _musicEnabled;
  double get musicVolume => _musicVolume;
  double get effectsVolume => _effectsVolume;

  // Audio control methods
  void setSoundEffectsEnabled(bool enabled) {
    _soundEffectsEnabled = enabled;
    if (!enabled) {
      _soundEffectPlayer.stop();
    }
  }

  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
  }

  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _backgroundMusicPlayer.stop();
    } else {
      playBackgroundMusic();
    }
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume;
    _backgroundMusicPlayer.setVolume(volume);
  }

  void setEffectsVolume(double volume) {
    _effectsVolume = volume;
    _soundEffectPlayer.setVolume(volume);
  }

  // Background music
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    
    try {
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusicPlayer.setVolume(_musicVolume);
      await _backgroundMusicPlayer.play(AssetSource('audio/background_music.mp3'));
    } catch (e) {
      // Silently handle if audio file doesn't exist yet
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _backgroundMusicPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _backgroundMusicPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    if (_musicEnabled) {
      await _backgroundMusicPlayer.resume();
    }
  }

  // Sound effects
  Future<void> playButtonSound() async {
    await playSoundEffect('button_click.mp3');
  }

  Future<void> playPhaseChangeSound() async {
    await playSoundEffect('phase_change.mp3');
  }

  Future<void> playVoteSound() async {
    await playSoundEffect('vote_cast.mp3');
  }

  Future<void> playEliminationSound() async {
    await playSoundEffect('elimination.mp3');
  }

  Future<void> playVictorySound() async {
    await playSoundEffect('victory.mp3');
  }

  Future<void> playDefeatSound() async {
    await playSoundEffect('defeat.mp3');
  }

  Future<void> playWarningSound() async {
    await playSoundEffect('warning.mp3');
  }

  Future<void> playNotificationSound() async {
    await playSoundEffect('notification.mp3');
  }

  Future<void> playSoundEffect(String fileName) async {
    if (!_soundEffectsEnabled) return;
    
    try {
      await _soundEffectPlayer.setVolume(_effectsVolume);
      await _soundEffectPlayer.play(AssetSource('audio/effects/$fileName'));
    } catch (e) {
      // Silently handle if audio file doesn't exist yet
    }
  }

  // Vibration feedback
  Future<void> lightVibration() async {
    if (!_vibrationEnabled) return;
    
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      // Silently handle vibration errors
    }
  }

  Future<void> mediumVibration() async {
    if (!_vibrationEnabled) return;
    
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 200);
      }
    } catch (e) {
      // Silently handle vibration errors
    }
  }

  Future<void> strongVibration() async {
    if (!_vibrationEnabled) return;
    
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 500);
      }
    } catch (e) {
      // Silently handle vibration errors
    }
  }

  Future<void> patternVibration() async {
    if (!_vibrationEnabled) return;
    
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(pattern: [0, 100, 100, 100, 100, 100]);
      }
    } catch (e) {
      // Silently handle vibration errors
    }
  }

  // Audio feedback combinations for game events
  Future<void> buttonFeedback() async {
    await Future.wait([
      playButtonSound(),
      lightVibration(),
    ]);
  }

  Future<void> phaseChangeFeedback() async {
    await Future.wait([
      playPhaseChangeSound(),
      mediumVibration(),
    ]);
  }

  Future<void> eliminationFeedback() async {
    await Future.wait([
      playEliminationSound(),
      strongVibration(),
    ]);
  }

  Future<void> victoryFeedback() async {
    await Future.wait([
      playVictorySound(),
      patternVibration(),
    ]);
  }

  Future<void> warningFeedback() async {
    await Future.wait([
      playWarningSound(),
      mediumVibration(),
    ]);
  }

  // Cleanup
  Future<void> dispose() async {
    await _backgroundMusicPlayer.dispose();
    await _soundEffectPlayer.dispose();
  }
}