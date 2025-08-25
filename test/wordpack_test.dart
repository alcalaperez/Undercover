import 'package:Undercover/core/utils/localization_service.dart';
import 'package:Undercover/data/repositories/word_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Wordpack System Tests', () {
    late WordRepository wordRepository;
    late LocalizationService localizationService;

    setUpAll(() {
      // Initialize Flutter bindings for asset loading
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      wordRepository = WordRepository.instance;
      localizationService = LocalizationService();
    });

    test('should load English wordpack by default', () async {
      await wordRepository.initialize('en');
      
      expect(wordRepository.currentLanguage, equals('en'));
      expect(wordRepository.getAllWordPairs().length, greaterThan(0));
    });

    test('should load Spanish wordpack', () async {
      await wordRepository.initialize('es');
      
      expect(wordRepository.currentLanguage, equals('es'));
      expect(wordRepository.getAllWordPairs().length, greaterThan(0));
      
      // Check that we have Spanish words
      final wordPairs = wordRepository.getAllWordPairs();
      final hasSpanishWords = wordPairs.any((pair) => 
        pair.civilianWord.contains('ñ') || 
        pair.category == 'Animales' || 
        pair.category == 'Comida'
      );
      expect(hasSpanishWords, isTrue);
    });

    test('should switch languages correctly', () async {
      await wordRepository.initialize('en');
      final englishWordsCount = wordRepository.getAllWordPairs().length;
      
      await wordRepository.switchLanguage('es');
      final spanishWordsCount = wordRepository.getAllWordPairs().length;
      
      expect(wordRepository.currentLanguage, equals('es'));
      expect(spanishWordsCount, equals(englishWordsCount)); // Should have same number of words
    });

    test('should fallback to English when language not available', () async {
      await wordRepository.initialize('nonexistent');
      
      expect(wordRepository.currentLanguage, equals('en'));
      expect(wordRepository.getAllWordPairs().length, greaterThan(0));
    });

    test('should check language availability correctly', () async {
      expect(await wordRepository.isLanguageAvailable('en'), isTrue);
      expect(await wordRepository.isLanguageAvailable('es'), isTrue);
      expect(await wordRepository.isLanguageAvailable('fr'), isTrue);
      expect(await wordRepository.isLanguageAvailable('de'), isTrue);
      expect(await wordRepository.isLanguageAvailable('zh'), isTrue);
      expect(await wordRepository.isLanguageAvailable('nonexistent'), isFalse);
    });

    test('should get available languages', () async {
      final availableLanguages = await wordRepository.getAvailableLanguages();
      
      expect(availableLanguages, contains('en'));
      expect(availableLanguages, contains('es'));
      expect(availableLanguages, contains('fr'));
      expect(availableLanguages, contains('de'));
      expect(availableLanguages, contains('zh'));
    });
  });
}