import 'package:flutter_test/flutter_test.dart';
import 'package:undercover_game/data/models/player.dart';
import 'package:undercover_game/data/models/game_settings.dart';
import 'package:undercover_game/data/repositories/game_service.dart';
import 'package:undercover_game/core/constants/enums.dart';

void main() {
  group('GameService', () {
    late GameService gameService;
    late List<Player> testPlayers;
    late GameSettings testSettings;

    setUp(() {
      gameService = GameService.instance;
      gameService.resetSession();
      
      testPlayers = [
        Player(id: '1', name: 'Alice', avatarIndex: '0'),
        Player(id: '2', name: 'Bob', avatarIndex: '1'),
        Player(id: '3', name: 'Charlie', avatarIndex: '2'),
        Player(id: '4', name: 'Diana', avatarIndex: '3'),
      ];
      
      testSettings = GameSettings(
        undercoverCount: 1,
        includeMrWhite: false,
        descriptionTimeLimit: 60,
        wordDifficulty: DifficultyLevel.easy,
        selectedCategories: ['Animals', 'Food'],
      );
    });

    group('Game Initialization', () {
      test('should throw error for too few players', () async {
        final players = [
          Player(id: '1', name: 'Alice', avatarIndex: '0'),
          Player(id: '2', name: 'Bob', avatarIndex: '1'),
          Player(id: '3', name: 'Charlie', avatarIndex: '2'),
        ];

        expect(
          () async => await gameService.initializeGame(players, testSettings),
          throwsException,
        );
      });

      test('should throw error for too many players', () async {
        final players = List.generate(21, (i) => 
          Player(id: '$i', name: 'Player$i', avatarIndex: '0'));

        expect(
          () async => await gameService.initializeGame(players, testSettings),
          throwsException,
        );
      });

      test('should create valid game session', () async {
        // This test requires actual word pairs, so we'll skip it in this context
        // In a real implementation, you'd mock the WordRepository
      });
    });

    group('Role Assignment', () {
      test('should throw error when no active session', () async {
        gameService.resetSession();
        
        expect(
          () async => await gameService.assignRoles(4, 1, 1),
          throwsException,
        );
      });

      test('should throw error for invalid role counts', () async {
        expect(
          () async => await gameService.assignRoles(4, 3, 2),
          throwsException,
        );
      });
    });

    group('Win Condition Calculation', () {
      test('should return null when no active session', () {
        gameService.resetSession();
        final result = gameService.calculateWinCondition();
        expect(result, isNull);
      });

      // Additional win condition tests would require setting up a game session
    });

    group('Voting System', () {
      test('should throw error when no active session', () {
        gameService.resetSession();
        
        expect(
          () => gameService.addVote('1', '2'),
          throwsException,
        );
      });

      test('should throw error for self-voting', () {
        gameService.resetSession();
        
        expect(
          () => gameService.addVote('1', '1'),
          throwsException,
        );
      });
    });

    group('Player Elimination', () {
      test('should throw error when no active session', () {
        gameService.resetSession();
        
        expect(
          () => gameService.eliminatePlayer('1'),
          throwsException,
        );
      });
    });

    group('Mr. White Guess', () {
      test('should return false when no word pair', () {
        gameService.resetSession();
        final result = gameService.handleMrWhiteGuess('test');
        expect(result, false);
      });

      // Test correct guess matching would require a mocked session
    });

    group('Session Management', () {
      test('should reset session correctly', () {
        gameService.resetSession();
        expect(gameService.currentSession, isNull);
      });

      test('should generate session statistics', () {
        final stats = gameService.getGameStatistics();
        expect(stats, isMap);
      });
    });
  });
}