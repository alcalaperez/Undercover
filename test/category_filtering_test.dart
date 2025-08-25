import 'package:flutter_test/flutter_test.dart';
import 'package:undercover_game/data/repositories/word_repository.dart';
import 'package:undercover_game/core/constants/enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Category Filtering Tests', () {
    late WordRepository wordRepository;

    setUp(() {
      wordRepository = WordRepository.instance;
    });

    test('should filter word pairs by English category names in all languages', () async {
      // Test English
      await wordRepository.initialize('en');
      var animalWords = wordRepository.getWordPairsByCategory('Animals');
      expect(animalWords.length, greaterThan(0));
      
      var foodWords = wordRepository.getWordPairsByCategory('Food');
      expect(foodWords.length, greaterThan(0));
      
      // Test Spanish (should work with English category names)
      await wordRepository.switchLanguage('es');
      animalWords = wordRepository.getWordPairsByCategory('Animals');
      expect(animalWords.length, greaterThan(0));
      
      foodWords = wordRepository.getWordPairsByCategory('Food');
      expect(foodWords.length, greaterThan(0));
      
      // Verify Spanish words are returned
      expect(animalWords.first.civilianWord, anyOf(contains('Perro'), contains('León'), contains('Elefante')));
      
      // Test German
      await wordRepository.switchLanguage('de');
      animalWords = wordRepository.getWordPairsByCategory('Animals');
      expect(animalWords.length, greaterThan(0));
      
      // Verify German words are returned
      expect(animalWords.first.civilianWord, anyOf(contains('Hund'), contains('Löwe'), contains('Elefant')));
    });

    test('should filter by multiple categories', () async {
      await wordRepository.initialize('es');
      
      var multiCategoryWords = wordRepository.getWordPairsByCategories(['Animals', 'Food']);
      expect(multiCategoryWords.length, greaterThan(0));
      
      // Check that we have words from both categories
      var hasAnimals = multiCategoryWords.any((word) => word.category == 'Animals');
      var hasFood = multiCategoryWords.any((word) => word.category == 'Food');
      
      expect(hasAnimals, isTrue);
      expect(hasFood, isTrue);
    });

    test('should filter by difficulty levels', () async {
      await wordRepository.initialize('fr');
      
      var easyWords = wordRepository.getWordPairsByDifficulty(DifficultyLevel.easy);
      var hardWords = wordRepository.getWordPairsByDifficulty(DifficultyLevel.hard);
      
      expect(easyWords.length, greaterThan(0));
      expect(hardWords.length, greaterThan(0));
      
      // Verify all returned words have correct difficulty
      expect(easyWords.every((word) => word.difficulty == DifficultyLevel.easy), isTrue);
      expect(hardWords.every((word) => word.difficulty == DifficultyLevel.hard), isTrue);
    });

    test('should get random words with filtering criteria', () async {
      await wordRepository.initialize('de');
      
      // First check how many easy animals we have
      var easyAnimals = wordRepository.filterWordPairs(
        categories: ['Animals'],
        difficulty: DifficultyLevel.easy,
      );
      var requestCount = easyAnimals.length.clamp(1, 3);
      
      var randomAnimalsEasy = wordRepository.getRandomWordPairs(
        requestCount,
        categories: ['Animals'],
        difficulty: DifficultyLevel.easy,
      );
      
      expect(randomAnimalsEasy.length, equals(requestCount));
      expect(randomAnimalsEasy.every((word) => 
        word.category == 'Animals' && word.difficulty == DifficultyLevel.easy
      ), isTrue);
    });

    test('should get all available categories in all languages', () async {
      final languages = ['en', 'es', 'fr', 'de', 'zh'];
      
      for (final lang in languages) {
        await wordRepository.switchLanguage(lang);
        final categories = wordRepository.getAllCategories();
        
        // All languages should have these standard categories
        expect(categories, contains('Animals'));
        expect(categories, contains('Food')); 
        expect(categories, contains('Objects'));
        expect(categories, contains('Places'));
        expect(categories, contains('Activities'));
        expect(categories, contains('Movies'));
        expect(categories, contains('Professions'));
      }
    });

    test('should return empty when filtering with non-existent category', () async {
      await wordRepository.initialize('en');
      
      var nonExistentCategoryWords = wordRepository.getWordPairsByCategory('NonExistent');
      expect(nonExistentCategoryWords.isEmpty, isTrue);
      
      var randomFromNonExistent = wordRepository.getRandomWordPair(categories: ['NonExistent']);
      expect(randomFromNonExistent, isNull);
    });
  });
}