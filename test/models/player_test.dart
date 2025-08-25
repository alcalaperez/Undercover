import 'package:Undercover/core/constants/enums.dart';
import 'package:Undercover/data/models/player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Player', () {
    test('should create player with required fields', () {
      final player = Player(
        id: '1',
        name: 'Alice',
        avatarIndex: '0',
      );

      expect(player.id, '1');
      expect(player.name, 'Alice');
      expect(player.avatarIndex, '0');
      expect(player.role, PlayerRole.civilian);
      expect(player.assignedWord, '');
      expect(player.isEliminated, false);
      expect(player.votesReceived, 0);
    });

    test('should create player with all fields', () {
      final player = Player(
        id: '2',
        name: 'Bob',
        avatarIndex: '1',
        role: PlayerRole.undercover,
        assignedWord: 'test',
        isEliminated: true,
        votesReceived: 3,
      );

      expect(player.id, '2');
      expect(player.name, 'Bob');
      expect(player.avatarIndex, '1');
      expect(player.role, PlayerRole.undercover);
      expect(player.assignedWord, 'test');
      expect(player.isEliminated, true);
      expect(player.votesReceived, 3);
    });

    test('should convert to JSON correctly', () {
      final player = Player(
        id: '1',
        name: 'Alice',
        avatarIndex: '0',
        role: PlayerRole.undercover,
        assignedWord: 'cat',
        isEliminated: true,
        votesReceived: 2,
      );

      final json = player.toJson();

      expect(json['id'], '1');
      expect(json['name'], 'Alice');
      expect(json['avatarIndex'], '0');
      expect(json['role'], 'undercover');
      expect(json['assignedWord'], 'cat');
      expect(json['isEliminated'], true);
      expect(json['votesReceived'], 2);
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': '2',
        'name': 'Bob',
        'avatarIndex': '1',
        'role': 'mrWhite',
        'assignedWord': '',
        'isEliminated': false,
        'votesReceived': 1,
      };

      final player = Player.fromJson(json);

      expect(player.id, '2');
      expect(player.name, 'Bob');
      expect(player.avatarIndex, '1');
      expect(player.role, PlayerRole.mrWhite);
      expect(player.assignedWord, '');
      expect(player.isEliminated, false);
      expect(player.votesReceived, 1);
    });

    test('should create copy with modified fields', () {
      final original = Player(
        id: '1',
        name: 'Alice',
        avatarIndex: '0',
      );

      final copy = original.copyWith(
        role: PlayerRole.undercover,
        assignedWord: 'test',
        isEliminated: true,
        votesReceived: 5,
      );

      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.avatarIndex, original.avatarIndex);
      expect(copy.role, PlayerRole.undercover);
      expect(copy.assignedWord, 'test');
      expect(copy.isEliminated, true);
      expect(copy.votesReceived, 5);
    });

    test('should compare players correctly', () {
      final player1 = Player(id: '1', name: 'Alice', avatarIndex: '0');
      final player2 = Player(id: '1', name: 'Bob', avatarIndex: '1');
      final player3 = Player(id: '2', name: 'Alice', avatarIndex: '0');

      expect(player1 == player2, true);
      expect(player1 == player3, false);
      expect(player1.hashCode == player2.hashCode, true);
      expect(player1.hashCode == player3.hashCode, false);
    });

    test('should have proper toString representation', () {
      final player = Player(
        id: '1',
        name: 'Alice',
        avatarIndex: '0',
        role: PlayerRole.undercover,
        isEliminated: true,
      );

      final string = player.toString();

      expect(string, contains('Alice'));
      expect(string, contains('undercover'));
      expect(string, contains('true'));
    });
  });
}