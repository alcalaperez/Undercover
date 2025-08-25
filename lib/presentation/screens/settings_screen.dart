import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/utils/localization_service.dart';
import '../../core/utils/preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalizationService _localizationService = LocalizationService();

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
      _selectedLanguage = _localizationService.currentLanguage;
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_localizationService.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localizationService.translate('settings_language'),
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            _buildLanguageSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguage,
          isExpanded: true,
          elevation: 8,
          items: _localizationService.availableLanguages.map((languageCode) {
            return DropdownMenuItem<String>(
              value: languageCode,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      _localizationService.languageDisplayNames[languageCode] ?? languageCode,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (_selectedLanguage == languageCode)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, size: 18),
                      ),
                  ],
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
            }
          },
        ),
      ),
    );
  }
}