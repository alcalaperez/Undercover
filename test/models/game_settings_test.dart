import 'package:Undercover/core/constants/enums.dart';
import 'package:Undercover/data/models/game_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameSettings', () {
    test('should create game settings with all fields', () {
      final settings = GameSettings(
        undercoverCount: 2,
        includeMrWhite: true,
        descriptionTimeLimit: 90,
        wordDifficulty: DifficultyLevel.hard,
        selectedCategories: ['Animals', 'Food'],
        soundEffectsEnabled: false,
        vibrationEnabled: false,
      );

      expect(settings.undercoverCount, 2);
      expect(settings.includeMrWhite, true);
      expect(settings.descriptionTimeLimit, 90);
      expect(settings.wordDifficulty, DifficultyLevel.hard);
      expect(settings.selectedCategories, ['Animals', 'Food']);
      expect(settings.soundEffectsEnabled, false);
      expect(settings.vibrationEnabled, false);
    });

    test('should create game settings with default values', () {
      final settings = GameSettings(
        undercoverCount: 1,
        includeMrWhite: false,
        descriptionTimeLimit: 60,
        wordDifficulty: DifficultyLevel.medium,
        selectedCategories: ['Animals'],
      );

      expect(settings.soundEffectsEnabled, true);
      expect(settings.vibrationEnabled, true);
    });

    test('should convert to JSON correctly', () {
      final settings = GameSettings(
        undercoverCount: 1,
        includeMrWhite: true,
        descriptionTimeLimit: 30,
        wordDifficulty: DifficultyLevel.easy,
        selectedCategories: ['Food', 'Objects'],
        soundEffectsEnabled: false,
        vibrationEnabled: true,
      );

      final json = settings.toJson();

      expect(json['undercoverCount'], 1);
      expect(json['includeMrWhite'], true);
      expect(json['descriptionTimeLimit'], 30);
      expect(json['wordDifficulty'], 'easy');
      expect(json['selectedCategories'], ['Food', 'Objects']);
      expect(json['soundEffectsEnabled'], false);
      expect(json['vibrationEnabled'], true);
    });

    test('should create from JSON correctly', () {
      final json = {
        'undercoverCount': 3,
        'includeMrWhite': false,
        'descriptionTimeLimit': 120,
        'wordDifficulty': 'hard',
        'selectedCategories': ['Movies', 'Places'],
        'soundEffectsEnabled': true,
        'vibrationEnabled': false,
      };

      final settings = GameSettings.fromJson(json);

      expect(settings.undercoverCount, 3);
      expect(settings.includeMrWhite, false);
      expect(settings.descriptionTimeLimit, 120);
      expect(settings.wordDifficulty, DifficultyLevel.hard);
      expect(settings.selectedCategories, ['Movies', 'Places']);
      expect(settings.soundEffectsEnabled, true);
      expect(settings.vibrationEnabled, false);
    });

    test('should handle missing optional fields in JSON', () {
      final json = {
        'undercoverCount': 1,
        'includeMrWhite': false,
        'descriptionTimeLimit': 60,
        'wordDifficulty': 'medium',
        'selectedCategories': ['Animals'],
      };

      final settings = GameSettings.fromJson(json);

      expect(settings.soundEffectsEnabled, true);
      expect(settings.vibrationEnabled, true);
    });

    test('should create copy with modified fields', () {
      final original = GameSettings(
        undercoverCount: 1,
        includeMrWhite: false,
        descriptionTimeLimit: 60,
        wordDifficulty: DifficultyLevel.medium,
        selectedCategories: ['Animals'],
      );

      final copy = original.copyWith(
        undercoverCount: 2,
        includeMrWhite: true,
        soundEffectsEnabled: false,
      );

      expect(copy.undercoverCount, 2);
      expect(copy.includeMrWhite, true);
      expect(copy.soundEffectsEnabled, false);
      expect(copy.descriptionTimeLimit, original.descriptionTimeLimit);
      expect(copy.wordDifficulty, original.wordDifficulty);
      expect(copy.selectedCategories, original.selectedCategories);
      expect(copy.vibrationEnabled, original.vibrationEnabled);
    });

    test('should create default settings', () {
      final settings = GameSettings.defaultSettings();

      expect(settings.undercoverCount, 1);
      expect(settings.includeMrWhite, false);
      expect(settings.descriptionTimeLimit, 60);
      expect(settings.wordDifficulty, DifficultyLevel.medium);
      expect(settings.selectedCategories, ['Animals', 'Food', 'Objects']);
      expect(settings.soundEffectsEnabled, true);
      expect(settings.vibrationEnabled, true);
    });

    test('should have proper toString representation', () {
      final settings = GameSettings(
        undercoverCount: 2,
        includeMrWhite: true,
        descriptionTimeLimit: 90,
        wordDifficulty: DifficultyLevel.hard,
        selectedCategories: ['Animals'],
      );

      final string = settings.toString();

      expect(string, contains('2'));
      expect(string, contains('true'));
      expect(string, contains('90'));
      expect(string, contains('hard'));
    });
  });
}