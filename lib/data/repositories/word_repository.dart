import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/word_pair.dart';
import '../../core/constants/enums.dart';

class WordRepository {
  static WordRepository? _instance;
  static WordRepository get instance => _instance ??= WordRepository._();
  
  WordRepository._();

  List<WordPair> _wordPairs = [];
  List<String> _categories = [];

  Future<void> initialize() async {
    if (_wordPairs.isEmpty) {
      await _loadWordPairs();
    }
  }

  Future<void> _loadWordPairs() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/word_pairs.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _wordPairs = (jsonData['word_pairs'] as List)
          .map((json) => WordPair.fromJson(json))
          .toList();

      _categories = _wordPairs
          .map((pair) => pair.category)
          .toSet()
          .toList()
          ..sort();
    } catch (e) {
      throw Exception('Failed to load word pairs: $e');
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
  }

  Future<void> reload() async {
    clearCache();
    await _loadWordPairs();
  }
}