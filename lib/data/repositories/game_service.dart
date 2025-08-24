import 'dart:math';
import '../models/player.dart';
import '../models/game_session.dart';
import '../models/word_pair.dart';
import '../models/game_settings.dart';
import '../../core/constants/enums.dart';
import 'word_repository.dart';

class GameService {
  static GameService? _instance;
  static GameService get instance => _instance ??= GameService._();
  
  GameService._();

  final WordRepository _wordRepository = WordRepository.instance;
  final Random _random = Random();

  GameSession? _currentSession;
  List<PlayerRole>? _shuffledRoles;

  GameSession? get currentSession => _currentSession;

  Future<GameSession> initializeGame(
    List<Player> playerList,
    GameSettings settings,
  ) async {
    if (playerList.length < 4 || playerList.length > 20) {
      throw Exception('Game requires 4-20 players');
    }

    await _wordRepository.initialize();

    final sessionId = _generateSessionId();
    
    final wordPair = _wordRepository.getRandomWordPair(
      categories: settings.selectedCategories,
      difficulty: settings.wordDifficulty,
    );

    if (wordPair == null) {
      throw Exception('No word pairs available for selected criteria');
    }

    _currentSession = GameSession(
      sessionId: sessionId,
      players: List.from(playerList),
      currentWordPair: wordPair,
      currentPhase: GamePhase.setup,
      currentRound: 1,
      currentPlayerIndex: 0,
      settings: settings,
      createdAt: DateTime.now(),
    );

    await assignRoles(playerList.length, settings.undercoverCount, settings.includeMrWhite ? 1 : 0);
    
    // Apply Mr. White first draw setting BEFORE assigning words
    if (settings.mrWhiteFirstDraw && settings.includeMrWhite) {
      _preventMrWhiteFirst();
    }
    
    assignWords(_currentSession!.players, wordPair);

    return _currentSession!;
  }

  // New method for card selection system
  Future<GameSession> initializeGameWithoutRoles(
    List<Player> playerList,
    GameSettings settings,
  ) async {
    if (playerList.length < 4 || playerList.length > 20) {
      throw Exception('Game requires 4-20 players');
    }

    await _wordRepository.initialize();

    final sessionId = _generateSessionId();
    
    final wordPair = _wordRepository.getRandomWordPair(
      categories: settings.selectedCategories,
      difficulty: settings.wordDifficulty,
    );

    if (wordPair == null) {
      throw Exception('No word pairs available for selected criteria');
    }

    _currentSession = GameSession(
      sessionId: sessionId,
      players: List.from(playerList),
      currentWordPair: wordPair,
      currentPhase: GamePhase.setup,
      currentRound: 1,
      currentPlayerIndex: 0,
      settings: settings,
      createdAt: DateTime.now(),
    );

    // Generate shuffled roles but don't assign them yet
    _generateShuffledRoles(playerList.length, settings.undercoverCount, settings.includeMrWhite ? 1 : 0);

    return _currentSession!;
  }

  void _generateShuffledRoles(int playerCount, int undercoverCount, int mrWhiteCount) {
    if (undercoverCount + mrWhiteCount >= playerCount) {
      throw Exception('Too many non-civilian roles for player count');
    }

    final List<PlayerRole> roles = [];
    
    for (int i = 0; i < undercoverCount; i++) {
      roles.add(PlayerRole.undercover);
    }
    
    for (int i = 0; i < mrWhiteCount; i++) {
      roles.add(PlayerRole.mrWhite);
    }
    
    while (roles.length < playerCount) {
      roles.add(PlayerRole.civilian);
    }

    roles.shuffle(_random);
    _shuffledRoles = roles;
  }

  List<PlayerRole> getShuffledRoles() {
    return _shuffledRoles ?? [];
  }

  void assignPlayerRole(String playerId, int cardIndex) {
    if (_currentSession == null || _shuffledRoles == null) {
      throw Exception('Game not properly initialized for card selection');
    }

    if (cardIndex < 0 || cardIndex >= _shuffledRoles!.length) {
      throw Exception('Invalid card index');
    }

    final playerIndex = _currentSession!.players.indexWhere((p) => p.id == playerId);
    if (playerIndex == -1) {
      throw Exception('Player not found');
    }

    final assignedRole = _shuffledRoles![cardIndex];
    _currentSession!.players[playerIndex] = _currentSession!.players[playerIndex].copyWith(role: assignedRole);
  }

  void finalizeGameSetup() {
    if (_currentSession == null) {
      throw Exception('No active game session');
    }

    // Apply Mr. White first draw setting BEFORE assigning words
    if (_currentSession!.settings.mrWhiteFirstDraw && _currentSession!.settings.includeMrWhite) {
      _preventMrWhiteFirst();
    }
    
    // Assign words to all players based on their roles
    assignWords(_currentSession!.players, _currentSession!.currentWordPair!);
  }

  Future<void> assignRoles(int playerCount, int undercoverCount, int mrWhiteCount) async {
    if (_currentSession == null) throw Exception('No active game session');

    final players = _currentSession!.players;
    
    if (undercoverCount + mrWhiteCount >= playerCount) {
      throw Exception('Too many non-civilian roles for player count');
    }

    final List<PlayerRole> roles = [];
    
    for (int i = 0; i < undercoverCount; i++) {
      roles.add(PlayerRole.undercover);
    }
    
    for (int i = 0; i < mrWhiteCount; i++) {
      roles.add(PlayerRole.mrWhite);
    }
    
    while (roles.length < playerCount) {
      roles.add(PlayerRole.civilian);
    }

    roles.shuffle(_random);

    for (int i = 0; i < players.length; i++) {
      players[i] = players[i].copyWith(role: roles[i]);
    }
  }

  void assignWords(List<Player> players, WordPair wordPair) {
    for (int i = 0; i < players.length; i++) {
      String assignedWord;
      
      switch (players[i].role) {
        case PlayerRole.civilian:
          assignedWord = wordPair.civilianWord;
          break;
        case PlayerRole.undercover:
          assignedWord = wordPair.undercoverWord;
          break;
        case PlayerRole.mrWhite:
          assignedWord = '';
          break;
      }

      players[i] = players[i].copyWith(assignedWord: assignedWord);
    }
  }

  GameResult? calculateWinCondition() {
    if (_currentSession == null) return null;

    final activePlayers = _currentSession!.activePlayers;
    final activeCivilians = activePlayers.where((p) => p.role == PlayerRole.civilian).length;
    final activeUndercovers = activePlayers.where((p) => p.role == PlayerRole.undercover).length;
    final activeMrWhites = activePlayers.where((p) => p.role == PlayerRole.mrWhite).length;
    
    // Civilians win when ALL undercover agents are eliminated
    // (this includes both regular undercovers and Mr. White)
    if (activeUndercovers == 0 && activeMrWhites == 0) {
      return GameResult.civiliansWin;
    }
    
    // Undercovers win when their count is >= civilians count
    // (undercovers include both regular undercovers and Mr. White)
    final totalUndercovers = activeUndercovers + activeMrWhites;
    if (totalUndercovers >= activeCivilians) {
      return GameResult.undercoversWin;
    }
    
    // Draw condition - very rare scenario
    if (activePlayers.length <= 2 && totalUndercovers == activeCivilians) {
      return GameResult.draw;
    }
    
    // Game continues
    return null;
  }

  bool validateElimination(Player player) {
    if (_currentSession == null) return false;
    return _currentSession!.players.contains(player) && !player.isEliminated;
  }

  Player eliminatePlayer(String playerId) {
    if (_currentSession == null) throw Exception('No active game session');

    final playerIndex = _currentSession!.players.indexWhere((p) => p.id == playerId);
    if (playerIndex == -1) throw Exception('Player not found');

    final player = _currentSession!.players[playerIndex];
    if (player.isEliminated) throw Exception('Player already eliminated');

    _currentSession!.players[playerIndex] = player.copyWith(isEliminated: true);
    
    return _currentSession!.players[playerIndex];
  }

  void addVote(String voterId, String targetId) {
    if (_currentSession == null) throw Exception('No active game session');

    final voterIndex = _currentSession!.players.indexWhere((p) => p.id == voterId);
    final targetIndex = _currentSession!.players.indexWhere((p) => p.id == targetId);

    if (voterIndex == -1 || targetIndex == -1) {
      throw Exception('Player not found');
    }

    if (_currentSession!.players[voterIndex].isEliminated) {
      throw Exception('Eliminated player cannot vote');
    }

    // Removed restriction: players can now vote for themselves if they wish
    // if (voterId == targetId) {
    //   throw Exception('Player cannot vote for themselves');
    // }

    _currentSession!.players[targetIndex] = _currentSession!.players[targetIndex]
        .copyWith(votesReceived: _currentSession!.players[targetIndex].votesReceived + 1);
  }

  Player? getMostVotedPlayer() {
    if (_currentSession == null) return null;

    final activePlayers = _currentSession!.activePlayers;
    if (activePlayers.isEmpty) return null;

    int maxVotes = 0;
    Player? mostVoted;
    int playersWithMaxVotes = 0;

    for (final player in activePlayers) {
      if (player.votesReceived > maxVotes) {
        maxVotes = player.votesReceived;
        mostVoted = player;
        playersWithMaxVotes = 1;
      } else if (player.votesReceived == maxVotes && maxVotes > 0) {
        playersWithMaxVotes++;
      }
    }

    if (playersWithMaxVotes > 1 || maxVotes == 0) {
      return null;
    }

    return mostVoted;
  }

  void clearVotes() {
    if (_currentSession == null) return;

    for (int i = 0; i < _currentSession!.players.length; i++) {
      _currentSession!.players[i] = _currentSession!.players[i].copyWith(votesReceived: 0);
    }
  }

  void nextPhase(GamePhase nextPhase) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(currentPhase: nextPhase);

    if (nextPhase == GamePhase.gameEnd) {
      final result = calculateWinCondition();
      _currentSession = _currentSession!.copyWith(
        result: result,
        endedAt: DateTime.now(),
      );
    } else if (nextPhase == GamePhase.description && _currentSession!.startedAt == null) {
      _currentSession = _currentSession!.copyWith(startedAt: DateTime.now());
    }
  }

  void nextPlayer() {
    if (_currentSession == null) return;

    final activePlayers = _currentSession!.activePlayers;
    if (activePlayers.isEmpty) return;

    int nextIndex = (_currentSession!.currentPlayerIndex + 1) % activePlayers.length;
    
    if (nextIndex == 0) {
      _currentSession = _currentSession!.copyWith(
        currentPlayerIndex: nextIndex,
        currentRound: _currentSession!.currentRound + 1,
      );
    } else {
      _currentSession = _currentSession!.copyWith(currentPlayerIndex: nextIndex);
    }
  }

  bool handleMrWhiteGuess(String guess) {
    if (_currentSession?.currentWordPair == null) return false;

    final civilianWord = _currentSession!.currentWordPair!.civilianWord;
    final cleanGuess = guess.trim().toLowerCase();
    final cleanAnswer = civilianWord.toLowerCase();

    return cleanGuess == cleanAnswer || 
           cleanGuess.contains(cleanAnswer) || 
           cleanAnswer.contains(cleanGuess);
  }

  void endGame(GameResult result) {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      currentPhase: GamePhase.gameEnd,
      result: result,
      endedAt: DateTime.now(),
    );
  }

  void resetSession() {
    _currentSession = null;
    _shuffledRoles = null;
  }

  String _generateSessionId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  void _preventMrWhiteFirst() {
    if (_currentSession == null) return;
    
    final players = _currentSession!.players;
    if (players.isEmpty) return;
    
    // Check if the first player is Mr. White
    if (players[0].role != PlayerRole.mrWhite) return;
    
    // Find all non-Mr. White players to choose from randomly
    final availableIndices = <int>[];
    for (int i = 1; i < players.length; i++) {
      if (players[i].role != PlayerRole.mrWhite) {
        availableIndices.add(i);
      }
    }
    
    // If we found players to swap roles with, choose one randomly
    if (availableIndices.isNotEmpty) {
      final randomIndex = availableIndices[_random.nextInt(availableIndices.length)];
      final firstPlayerRole = players[0].role;
      final swapPlayerRole = players[randomIndex].role;
      
      // Swap only the roles, keeping players in their original positions
      players[0] = players[0].copyWith(role: swapPlayerRole);
      players[randomIndex] = players[randomIndex].copyWith(role: firstPlayerRole);
    }
  }

  GameSession? copySession() {
    return _currentSession != null 
        ? GameSession.fromJson(_currentSession!.toJson())
        : null;
  }

  Map<String, dynamic> getGameStatistics() {
    if (_currentSession == null) return {};

    final session = _currentSession!;
    final totalPlayers = session.players.length;
    final activePlayers = session.activePlayers.length;
    final eliminatedPlayers = session.eliminatedPlayers.length;
    
    final civilians = session.civilians.length;
    final undercovers = session.undercovers.length;
    final hasMrWhite = session.mrWhite != null;

    final activeCivilians = session.activePlayers.where((p) => p.role == PlayerRole.civilian).length;
    final activeUndercovers = session.activePlayers.where((p) => p.role == PlayerRole.undercover).length;
    final mrWhiteActive = session.activePlayers.any((p) => p.role == PlayerRole.mrWhite);

    return {
      'sessionId': session.sessionId,
      'currentPhase': session.currentPhase.name,
      'currentRound': session.currentRound,
      'totalPlayers': totalPlayers,
      'activePlayers': activePlayers,
      'eliminatedPlayers': eliminatedPlayers,
      'civilians': civilians,
      'undercovers': undercovers,
      'hasMrWhite': hasMrWhite,
      'activeCivilians': activeCivilians,
      'activeUndercovers': activeUndercovers,
      'mrWhiteActive': mrWhiteActive,
      'wordPair': session.currentWordPair?.toJson(),
      'isGameEnded': session.isGameEnded,
      'result': session.result?.name,
      'duration': session.startedAt != null 
          ? DateTime.now().difference(session.startedAt!).inMinutes 
          : null,
    };
  }
}