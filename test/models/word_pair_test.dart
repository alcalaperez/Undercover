import 'package:flutter_test/flutter_test.dart';
import 'package:undercover_game/data/models/word_pair.dart';
import 'package:undercover_game/core/constants/enums.dart';

void main() {
  group('WordPair', () {
    test('should create word pair with all fields', () {
      final wordPair = WordPair(
        civilianWord: 'Dog',
        undercoverWord: 'Cat',
        category: 'Animals',
        difficulty: DifficultyLevel.easy,
      );

      expect(wordPair.civilianWord, 'Dog');
      expect(wordPair.undercoverWord, 'Cat');
      expect(wordPair.category, 'Animals');
      expect(wordPair.difficulty, DifficultyLevel.easy);
    });

    test('should convert to JSON correctly', () {
      final wordPair = WordPair(
        civilianWord: 'Pizza',
        undercoverWord: 'Burger',
        category: 'Food',
        difficulty: DifficultyLevel.medium,
      );

      final json = wordPair.toJson();

      expect(json['civilianWord'], 'Pizza');
      expect(json['undercoverWord'], 'Burger');
      expect(json['category'], 'Food');
      expect(json['difficulty'], 'medium');
    });

    test('should create from JSON correctly', () {
      final json = {
        'civilianWord': 'Guitar',
        'undercoverWord': 'Violin',
        'category': 'Objects',
        'difficulty': 'hard',
      };

      final wordPair = WordPair.fromJson(json);

      expect(wordPair.civilianWord, 'Guitar');
      expect(wordPair.undercoverWord, 'Violin');
      expect(wordPair.category, 'Objects');
      expect(wordPair.difficulty, DifficultyLevel.hard);
    });

    test('should handle unknown difficulty in JSON', () {
      final json = {
        'civilianWord': 'Test',
        'undercoverWord': 'Sample',
        'category': 'Unknown',
        'difficulty': 'unknown',
      };

      final wordPair = WordPair.fromJson(json);

      expect(wordPair.difficulty, DifficultyLevel.medium);
    });

    test('should compare word pairs correctly', () {
      final wordPair1 = WordPair(
        civilianWord: 'Dog',
        undercoverWord: 'Cat',
        category: 'Animals',
        difficulty: DifficultyLevel.easy,
      );

      final wordPair2 = WordPair(
        civilianWord: 'Dog',
        undercoverWord: 'Cat',
        category: 'Animals',
        difficulty: DifficultyLevel.easy,
      );

      final wordPair3 = WordPair(
        civilianWord: 'Lion',
        undercoverWord: 'Tiger',
        category: 'Animals',
        difficulty: DifficultyLevel.easy,
      );

      expect(wordPair1 == wordPair2, true);
      expect(wordPair1 == wordPair3, false);
      expect(wordPair1.hashCode == wordPair2.hashCode, true);
    });

    test('should have proper toString representation', () {
      final wordPair = WordPair(
        civilianWord: 'Dog',
        undercoverWord: 'Cat',
        category: 'Animals',
        difficulty: DifficultyLevel.easy,
      );

      final string = wordPair.toString();

      expect(string, contains('Dog'));
      expect(string, contains('Cat'));
      expect(string, contains('Animals'));
      expect(string, contains('easy'));
    });
  });
}