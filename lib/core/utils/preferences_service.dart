import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/game_settings.dart';
import '../../data/models/player.dart';

class PreferencesService {
  static PreferencesService? _instance;
  static PreferencesService get instance => _instance ??= PreferencesService._();
  
  PreferencesService._();

  late SharedPreferences _prefs;

  static const String _gameSettingsKey = 'game_settings';
  static const String _lastPlayersKey = 'last_players';
  static const String _quickNamesKey = 'quick_names';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _themeKey = 'theme_mode';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Game Settings
  Future<void> saveGameSettings(GameSettings settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await _prefs.setString(_gameSettingsKey, jsonString);
  }

  GameSettings getGameSettings() {
    final jsonString = _prefs.getString(_gameSettingsKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return GameSettings.fromJson(json);
      } catch (e) {
        return GameSettings.defaultSettings();
      }
    }
    return GameSettings.defaultSettings();
  }

  // Last Players (for quick setup)
  Future<void> saveLastPlayers(List<Player> players) async {
    final playersJson = players.map((player) => player.toJson()).toList();
    final jsonString = jsonEncode(playersJson);
    await _prefs.setString(_lastPlayersKey, jsonString);
  }

  List<Player> getLastPlayers() {
    final jsonString = _prefs.getString(_lastPlayersKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as List<dynamic>;
        return json.map((playerJson) => Player.fromJson(playerJson)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  // Quick Name Suggestions
  Future<void> saveQuickNames(List<String> names) async {
    await _prefs.setStringList(_quickNamesKey, names);
  }

  List<String> getQuickNames() {
    return _prefs.getStringList(_quickNamesKey) ?? _getDefaultQuickNames();
  }

  Future<void> addQuickName(String name) async {
    final names = getQuickNames();
    if (!names.contains(name) && name.trim().isNotEmpty) {
      names.add(name);
      // Keep only the last 50 names
      if (names.length > 50) {
        names.removeAt(0);
      }
      await saveQuickNames(names);
    }
  }

  List<String> _getDefaultQuickNames() {
    return [
      'Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank', 'Grace', 'Henry',
      'Iris', 'Jack', 'Kate', 'Liam', 'Maya', 'Noah', 'Olivia', 'Peter',
      'Quinn', 'Ruby', 'Sam', 'Tara', 'Uma', 'Victor', 'Wendy', 'Xavier',
      'Yara', 'Zoe', 'Adam', 'Beth', 'Carl', 'Dora', 'Ethan', 'Fiona',
      'George', 'Hana', 'Ivan', 'Jade', 'Kyle', 'Luna', 'Max', 'Nora'
    ];
  }

  // Sound Settings
  Future<void> setSoundEnabled(bool enabled) async {
    await _prefs.setBool(_soundEnabledKey, enabled);
  }

  bool getSoundEnabled() {
    return _prefs.getBool(_soundEnabledKey) ?? true;
  }

  // Vibration Settings
  Future<void> setVibrationEnabled(bool enabled) async {
    await _prefs.setBool(_vibrationEnabledKey, enabled);
  }

  bool getVibrationEnabled() {
    return _prefs.getBool(_vibrationEnabledKey) ?? true;
  }

  // Theme Settings
  Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  // Clear all preferences
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Get all stored keys (for debugging)
  Set<String> getKeys() {
    return _prefs.getKeys();
  }
}