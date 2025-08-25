import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/word_pair.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/localization_service.dart';

class WordRepository {
  static WordRepository? _instance;
  static WordRepository get instance => _instance ??= WordRepository._();
  
  WordRepository._() {
    // Listen for language changes to automatically switch wordpacks
    LocalizationService().addListener(_onLanguageChange);
  }
  
  void _onLanguageChange() async {
    final newLanguage = LocalizationService().currentLanguage;
    if (_currentLanguage != newLanguage) {
      try {
        await switchLanguage(newLanguage);
        print('WordRepository: Switched to $newLanguage wordpack');
      } catch (e) {
        print('WordRepository: Failed to switch to $newLanguage wordpack: $e');
      }
    }
  }

  List<WordPair> _wordPairs = [];
  List<String> _categories = [];
  String _currentLanguage = 'en';

  Future<void> initialize([String? languageCode]) async {
    final targetLanguage = languageCode ?? LocalizationService().currentLanguage;
    if (_wordPairs.isEmpty || _currentLanguage != targetLanguage) {
      await _loadWordPairs(targetLanguage);
    }
  }

  Future<void> _loadWordPairs(String languageCode) async {
    try {
      // Try to load the specific language wordpack first
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/data/wordpacks/$languageCode.json');
      } catch (e) {
        // Fallback to English if specific language not found
        print('Wordpack for $languageCode not found, falling back to English');
        jsonString = await rootBundle.loadString('assets/data/wordpacks/en.json');
        languageCode = 'en';
      }
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _wordPairs = (jsonData['word_pairs'] as List)
          .map((json) => WordPair.fromJson(json))
          .toList();

      _categories = _wordPairs
          .map((pair) => pair.category)
          .toSet()
          .toList()
          ..sort();
          
      _currentLanguage = languageCode;
      print('Loaded ${_wordPairs.length} word pairs for language: $languageCode');
    } catch (e) {
      throw Exception('Failed to load word pairs for $languageCode: $e');
    }
  }

  List<WordPair> getAllWordPairs() {
    return List.unmodifiable(_wordPairs);
  }

  List<String> getAllCategories() {
    return List.unmodifiable(_categories);
  }

  List<WordPair> getWordPairsByCategory(String category) {
    return _wordPairs
        .where((pair) => pair.category == category)
        .toList();
  }

  List<WordPair> getWordPairsByDifficulty(DifficultyLevel difficulty) {
    return _wordPairs
        .where((pair) => pair.difficulty == difficulty)
        .toList();
  }

  List<WordPair> getWordPairsByCategories(List<String> categories) {
    return _wordPairs
        .where((pair) => categories.contains(pair.category))
        .toList();
  }

  List<WordPair> filterWordPairs({
    List<String>? categories,
    DifficultyLevel? difficulty,
  }) {
    List<WordPair> filtered = _wordPairs;

    if (categories != null && categories.isNotEmpty) {
      filtered = filtered
          .where((pair) => categories.contains(pair.category))
          .toList();
    }

    if (difficulty != null) {
      filtered = filtered
          .where((pair) => pair.difficulty == difficulty)
          .toList();
    }

    return filtered;
  }

  WordPair? getRandomWordPair({
    List<String>? categories,
    DifficultyLevel? difficulty,
  }) {
    final filtered = filterWordPairs(
      categories: categories,
      difficulty: difficulty,
    );

    if (filtered.isEmpty) {
      return null;
    }

    final random = Random();
    return filtered[random.nextInt(filtered.length)];
  }

  List<WordPair> getRandomWordPairs(
    int count, {
    List<String>? categories,
    DifficultyLevel? difficulty,
    bool allowDuplicates = false,
  }) {
    final filtered = filterWordPairs(
      categories: categories,
      difficulty: difficulty,
    );

    if (filtered.isEmpty) {
      return [];
    }

    if (!allowDuplicates && count > filtered.length) {
      count = filtered.length;
    }

    final random = Random();
    final List<WordPair> result = [];
    final List<WordPair> available = List.from(filtered);

    for (int i = 0; i < count; i++) {
      if (available.isEmpty) {
        if (allowDuplicates) {
          available.addAll(filtered);
        } else {
          break;
        }
      }

      final index = random.nextInt(available.length);
      result.add(available[index]);

      if (!allowDuplicates) {
        available.removeAt(index);
      }
    }

    return result;
  }

  int getWordPairCount({
    List<String>? categories,
    DifficultyLevel? difficulty,
  }) {
    return filterWordPairs(
      categories: categories,
      difficulty: difficulty,
    ).length;
  }

  Map<String, int> getCategoryCounts() {
    final Map<String, int> counts = {};
    for (final pair in _wordPairs) {
      counts[pair.category] = (counts[pair.category] ?? 0) + 1;
    }
    return counts;
  }

  Map<DifficultyLevel, int> getDifficultyCounts() {
    final Map<DifficultyLevel, int> counts = {};
    for (final pair in _wordPairs) {
      counts[pair.difficulty] = (counts[pair.difficulty] ?? 0) + 1;
    }
    return counts;
  }

  bool hasWordPairs({
    List<String>? categories,
    DifficultyLevel? difficulty,
  }) {
    return getWordPairCount(
      categories: categories,
      difficulty: difficulty,
    ) > 0;
  }

  WordPair? findWordPair({
    String? civilianWord,
    String? undercoverWord,
    String? category,
  }) {
    final matching = _wordPairs.where((pair) {
      bool matches = true;
      
      if (civilianWord != null) {
        matches = matches && pair.civilianWord.toLowerCase() == civilianWord.toLowerCase();
      }
      
      if (undercoverWord != null) {
        matches = matches && pair.undercoverWord.toLowerCase() == undercoverWord.toLowerCase();
      }
      
      if (category != null) {
        matches = matches && pair.category.toLowerCase() == category.toLowerCase();
      }
      
      return matches;
    });
    return matching.isNotEmpty ? matching.first : null;
  }

  void clearCache() {
    _wordPairs.clear();
    _categories.clear();
    _currentLanguage = 'en';
  }

  Future<void> reload([String? languageCode]) async {
    clearCache();
    await _loadWordPairs(languageCode ?? LocalizationService().currentLanguage);
  }
  
  /// Switch to a different language wordpack
  Future<void> switchLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      clearCache();
      await _loadWordPairs(languageCode);
    }
  }
  
  /// Get current language for wordpack
  String get currentLanguage => _currentLanguage;
  
  /// Check if a specific language wordpack is available
  Future<bool> isLanguageAvailable(String languageCode) async {
    try {
      await rootBundle.loadString('assets/data/wordpacks/$languageCode.json');
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get list of available language codes based on existing wordpacks
  Future<List<String>> getAvailableLanguages() async {
    final List<String> languages = [];
    final supportedLanguages = LocalizationService.supportedLanguages;
    
    for (final lang in supportedLanguages) {
      if (await isLanguageAvailable(lang)) {
        languages.add(lang);
      }
    }
    
    return languages;
  }
}