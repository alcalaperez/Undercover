import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, String> _localizedStrings = {};
  String _currentLanguage = 'en';
  final List<VoidCallback> _listeners = [];

  static const List<String> supportedLanguages = ['en', 'es', 'fr', 'de', 'zh'];
  
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français', 
    'de': 'Deutsch',
    'zh': '简体中文',
  };

  String get currentLanguage => _currentLanguage;
  List<String> get availableLanguages => supportedLanguages;
  Map<String, String> get languageDisplayNames => languageNames;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }

  Future<bool> load(String languageCode) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/locales/$languageCode.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
      _currentLanguage = languageCode;
      _notifyListeners();
      return true;
    } catch (e) {
      // If loading fails, try to load English as fallback
      if (languageCode != 'en') {
        return await load('en');
      }
      return false;
    }
  }

  String translate(String key, {Map<String, String>? placeholders}) {
    String translation = _localizedStrings[key] ?? key;
    
    // Replace placeholders if provided
    if (placeholders != null) {
      placeholders.forEach((placeholder, value) {
        translation = translation.replaceAll('{$placeholder}', value);
      });
    }
    
    return translation;
  }

  String get(String key) => translate(key);

  // Common game terms with shortcuts
  String get appName => translate('app_name');
  String get newGame => translate('new_game');
  String get howToPlay => translate('how_to_play');
  String get settings => translate('settings');
  String get players => translate('players');
  String get startGame => translate('start_game');
  String get nextPhase => translate('next_phase');
  String get vote => translate('vote');
  String get eliminate => translate('eliminate');
  String get civilian => translate('civilian');
  String get undercover => translate('undercover');
  String get mrWhite => translate('mr_white');
  String get victory => translate('victory');
  String get defeat => translate('defeat');
  String get gameOver => translate('game_over');
  String get playAgain => translate('play_again');
  String get mainMenu => translate('main_menu');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get close => translate('close');
  String get tutorial => translate('tutorial');
  String get skip => translate('skip');
  String get next => translate('next');
  String get previous => translate('previous');
  String get finish => translate('finish');
  String get civilians_win => translate('civilians_win');
  String get undercovers_win => translate('undercovers_win');
  String get mr_white_wins => translate('mr_white_wins');
}

class AppLocalizations {
  final LocalizationService _localizationService;

  AppLocalizations(this._localizationService);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String translate(String key, {Map<String, String>? placeholders}) {
    return _localizationService.translate(key, placeholders: placeholders);
  }

  String get(String key) => translate(key);

  // Convenience getters
  String get appName => _localizationService.appName;
  String get newGame => _localizationService.newGame;
  String get howToPlay => _localizationService.howToPlay;
  String get settings => _localizationService.settings;
  String get players => _localizationService.players;
  String get startGame => _localizationService.startGame;
  String get nextPhase => _localizationService.nextPhase;
  String get vote => _localizationService.vote;
  String get eliminate => _localizationService.eliminate;
  String get civilian => _localizationService.civilian;
  String get undercover => _localizationService.undercover;
  String get mrWhite => _localizationService.mrWhite;
  String get victory => _localizationService.victory;
  String get defeat => _localizationService.defeat;
  String get gameOver => _localizationService.gameOver;
  String get playAgain => _localizationService.playAgain;
  String get mainMenu => _localizationService.mainMenu;
  String get cancel => _localizationService.cancel;
  String get confirm => _localizationService.confirm;
  String get close => _localizationService.close;
  String get tutorial => _localizationService.tutorial;
  String get skip => _localizationService.skip;
  String get next => _localizationService.next;
  String get previous => _localizationService.previous;
  String get finish => _localizationService.finish;
  String get civilians_win => _localizationService.civilians_win;
  String get undercovers_win => _localizationService.undercovers_win;
  String get mr_white_wins => _localizationService.mr_white_wins;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return LocalizationService.supportedLanguages.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final LocalizationService localizationService = LocalizationService();
    await localizationService.load(locale.languageCode);
    return AppLocalizations(localizationService);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}