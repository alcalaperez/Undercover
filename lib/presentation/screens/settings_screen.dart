import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/utils/localization_service.dart';
import '../../core/utils/audio_service.dart';
import '../../core/utils/preferences_service.dart';
import '../../data/models/game_settings.dart';
import '../widgets/common/help_tooltip.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audioService = AudioService();
  final LocalizationService _localizationService = LocalizationService();

  // Settings state
  bool _soundEffectsEnabled = true;
  bool _vibrationEnabled = true;
  bool _backgroundMusicEnabled = true;
  bool _mrWhiteFirstDraw = true;
  double _musicVolume = 0.3;
  double _effectsVolume = 0.7;
  String _selectedLanguage = 'en';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() async {
    try {
      // Initialize preferences service if not already initialized
      await PreferencesService.instance.initialize();
      _loadSettings();
    } catch (e) {
      // Handle initialization error gracefully
      setState(() {
        _isInitialized = false;
      });
    }
  }

  void _loadSettings() {
    setState(() {
      _soundEffectsEnabled = _audioService.soundEffectsEnabled;
      _vibrationEnabled = _audioService.vibrationEnabled;
      _backgroundMusicEnabled = _audioService.musicEnabled;
      _musicVolume = _audioService.musicVolume;
      _effectsVolume = _audioService.effectsVolume;
      _selectedLanguage = _localizationService.currentLanguage;
      _isInitialized = true;
    });
    
    // Load Mr. White setting from preferences
    _loadMrWhiteSetting();
  }

  void _loadMrWhiteSetting() {
    final settings = PreferencesService.instance.getGameSettings();
    setState(() {
      _mrWhiteFirstDraw = settings.mrWhiteFirstDraw;
    });
  }

  void _saveMrWhiteSetting(bool value) async {
    final currentSettings = PreferencesService.instance.getGameSettings();
    
    final updatedSettings = currentSettings.copyWith(mrWhiteFirstDraw: value);
    await PreferencesService.instance.saveGameSettings(updatedSettings);
    
    setState(() {
      _mrWhiteFirstDraw = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_localizationService.settings),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionCard(
            title: _localizationService.translate('settings_language'),
            icon: Icons.language,
            children: [
              _buildLanguageSelector(),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildSectionCard(
            title: 'Audio & Vibration',
            icon: Icons.volume_up,
            children: [
              _buildSwitchTile(
                title: _localizationService.translate('settings_sound_effects'),
                value: _soundEffectsEnabled,
                onChanged: (value) {
                  _audioService.setSoundEffectsEnabled(value);
                  setState(() => _soundEffectsEnabled = value);
                },
              ),
              _buildSwitchTile(
                title: _localizationService.translate('settings_background_music'),
                value: _backgroundMusicEnabled,
                onChanged: (value) {
                  _audioService.setMusicEnabled(value);
                  setState(() => _backgroundMusicEnabled = value);
                },
              ),
              _buildSwitchTile(
                title: _localizationService.translate('settings_vibration'),
                value: _vibrationEnabled,
                onChanged: (value) {
                  _audioService.setVibrationEnabled(value);
                  setState(() => _vibrationEnabled = value);
                },
              ),
              if (_backgroundMusicEnabled) _buildVolumeSlider(
                title: _localizationService.translate('settings_music_volume'),
                value: _musicVolume,
                onChanged: (value) {
                  _audioService.setMusicVolume(value);
                  setState(() => _musicVolume = value);
                },
              ),
              if (_soundEffectsEnabled) _buildVolumeSlider(
                title: _localizationService.translate('settings_effects_volume'),
                value: _effectsVolume,
                onChanged: (value) {
                  _audioService.setEffectsVolume(value);
                  setState(() => _effectsVolume = value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1E293B).withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF6366F1),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF1E293B).withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6366F1),
              thumbColor: const Color(0xFF6366F1),
              overlayColor: const Color(0xFF6366F1).withOpacity(0.2),
              inactiveTrackColor: const Color(0xFFE2E8F0),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0.0,
              max: 1.0,
              divisions: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          isExpanded: true,
          items: _localizationService.availableLanguages.map((languageCode) {
            return DropdownMenuItem<String>(
              value: languageCode,
              child: Text(
                _localizationService.languageDisplayNames[languageCode] ?? languageCode,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1E293B),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) async {
            if (newValue != null) {
              await _localizationService.load(newValue);
              setState(() {
                _selectedLanguage = newValue;
              });
              _audioService.buttonFeedback();
            }
          },
        ),
      ),
    );
  }
}