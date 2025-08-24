import '../../core/constants/enums.dart';
import 'player.dart';
import 'word_pair.dart';
import 'game_settings.dart';

class GameSession {
  final String sessionId;
  final List<Player> players;
  final WordPair? currentWordPair;
  final GamePhase currentPhase;
  final int currentRound;
  final int currentPlayerIndex;
  final GameSettings settings;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final GameResult? result;

  GameSession({
    required this.sessionId,
    required this.players,
    this.currentWordPair,
    required this.currentPhase,
    required this.currentRound,
    required this.currentPlayerIndex,
    required this.settings,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
    this.result,
  });

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'players': players.map((player) => player.toJson()).toList(),
      'currentWordPair': currentWordPair?.toJson(),
      'currentPhase': currentPhase.name,
      'currentRound': currentRound,
      'currentPlayerIndex': currentPlayerIndex,
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'result': result?.name,
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      sessionId: json['sessionId'],
      players: (json['players'] as List)
          .map((playerJson) => Player.fromJson(playerJson))
          .toList(),
      currentWordPair: json['currentWordPair'] != null
          ? WordPair.fromJson(json['currentWordPair'])
          : null,
      currentPhase: GamePhase.values.firstWhere(
        (e) => e.name == json['currentPhase'],
        orElse: () => GamePhase.setup,
      ),
      currentRound: json['currentRound'],
      currentPlayerIndex: json['currentPlayerIndex'],
      settings: GameSettings.fromJson(json['settings']),
      createdAt: DateTime.parse(json['createdAt']),
      startedAt:
          json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
      endedAt: json['endedAt'] != null ? DateTime.parse(json['endedAt']) : null,
      result: json['result'] != null
          ? GameResult.values.firstWhere((e) => e.name == json['result'])
          : null,
    );
  }

  GameSession copyWith({
    String? sessionId,
    List<Player>? players,
    WordPair? currentWordPair,
    GamePhase? currentPhase,
    int? currentRound,
    int? currentPlayerIndex,
    GameSettings? settings,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
    GameResult? result,
  }) {
    return GameSession(
      sessionId: sessionId ?? this.sessionId,
      players: players ?? this.players,
      currentWordPair: currentWordPair ?? this.currentWordPair,
      currentPhase: currentPhase ?? this.currentPhase,
      currentRound: currentRound ?? this.currentRound,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      result: result ?? this.result,
    );
  }

  List<Player> get activePlayers => players.where((player) => !player.isEliminated).toList();

  List<Player> get eliminatedPlayers => players.where((player) => player.isEliminated).toList();

  List<Player> get civilians => players.where((player) => player.role == PlayerRole.civilian).toList();

  List<Player> get undercovers => players.where((player) => player.role == PlayerRole.undercover).toList();

  Player? get mrWhite {
    final mrWhitePlayers = players.where((player) => player.role == PlayerRole.mrWhite);
    return mrWhitePlayers.isNotEmpty ? mrWhitePlayers.first : null;
  }

  bool get isGameActive => currentPhase != GamePhase.setup && currentPhase != GamePhase.gameEnd;

  bool get isGameEnded => currentPhase == GamePhase.gameEnd || result != null;

  int get totalPlayers => players.length;

  int get activePlayerCount => activePlayers.length;

  Player? get currentPlayer {
    if (currentPlayerIndex < 0 || currentPlayerIndex >= activePlayers.length) {
      return null;
    }
    return activePlayers[currentPlayerIndex];
  }

  @override
  String toString() {
    return 'GameSession{sessionId: $sessionId, phase: $currentPhase, round: $currentRound, players: ${players.length}, active: ${activePlayerCount}}';
  }
}