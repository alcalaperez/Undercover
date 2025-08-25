import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/themes/app_theme.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/localization_service.dart';
import '../../data/models/game_session.dart';
import '../../data/models/player.dart';
import '../../data/repositories/game_service.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/selectors/avatar_selector.dart';

class VotingScreen extends StatefulWidget {
  final GameSession gameSession;

  const VotingScreen({
    super.key,
    required this.gameSession,
  });

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen>
    with TickerProviderStateMixin {
  late GameSession _currentSession;
  Player? _selectedPlayer;
  bool _isVotingComplete = false;
  
  late AnimationController _selectionController;
  late Animation<double> _selectionAnimation;
  
  final List<String> _voteHistory = [];

  @override
  void initState() {
    super.initState();
    _currentSession = widget.gameSession;
    _setupAnimations();
    _addToHistory('Voting phase started');
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    );
  }

  void _addToHistory(String event) {
    final timestamp = DateTime.now();
    final timeString = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    _voteHistory.add('[$timeString] $event');
  }

  void _selectPlayer(Player player) {
    if (player.isEliminated) return;
    
    setState(() {
      // Clear previous selection and set new one
      if (_selectedPlayer?.id == player.id) {
        // If clicking the same player, deselect them
        _selectedPlayer = null;
        _addToHistory('Deselected ${player.name} (ID: ${player.id})');
      } else {
        // Select the new player
        _selectedPlayer = Player(
          id: player.id,
          name: player.name,
          avatarIndex: player.avatarIndex,
          role: player.role,
          isEliminated: player.isEliminated,
        );
        _addToHistory('Selected ${player.name} (ID: ${player.id}) for voting');
      }
    });
    
    _selectionController.forward().then((_) {
      _selectionController.reverse();
    });
    
    HapticFeedback.mediumImpact();
  }

  void _confirmVote() {
    if (_selectedPlayer == null) return;
    
    // For collective voting, we don't need individual confirmation
    // Just submit the vote directly
    _submitVote();
  }

  Widget _buildVoteConfirmationDialog() {
    // Not used in collective voting system
    return Container();
  }

  void _submitVote() {
    if (_selectedPlayer == null) return;
    
    try {
      final gameService = GameService.instance;
      // In collective voting, we simulate a group decision by having all active players vote
      // for the selected player. This is a simplification - in a real implementation,
      // you might have a different mechanism.
      for (final player in _currentSession.activePlayers) {
        // Skip eliminated players
        if (player.isEliminated) continue;
        
        // Each active player votes for the selected player
        gameService.addVote(player.id, _selectedPlayer!.id);
      }
      
      setState(() {
        _isVotingComplete = true;
      });
      
      _addToHistory('Group decision: ${_selectedPlayer!.name} selected for elimination');
      HapticFeedback.heavyImpact();
      
      // Show voting complete message
      _proceedToResults();
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _proceedToResults() {
    _addToHistory('Proceeding to vote results');
    _processVotesAndElimination();
  }

  void _processVotesAndElimination() {
    final gameService = GameService.instance;
    
    // Get the most voted player
    final mostVoted = gameService.getMostVotedPlayer();
    
    if (mostVoted != null) {
      // Eliminate the most voted player
      gameService.eliminatePlayer(mostVoted.id);
      _addToHistory('${mostVoted.name} has been eliminated');
      
      // Show the eliminated player's role before proceeding
      _showEliminatedPlayerRole(mostVoted);
    } else {
      // No clear winner - tie or no votes
      _addToHistory('Vote was inconclusive - continuing game');
      gameService.clearVotes();
      gameService.nextPhase(GamePhase.description);
      _navigateToGameplay();
    }
  }

  void _showEliminatedPlayerRole(Player eliminatedPlayer) {
    // Get role name for display
    String roleName = '';
    Color roleColor = AppColors.civilian;
    
    switch (eliminatedPlayer.role) {
      case PlayerRole.civilian:
        roleName = 'Civilian';
        roleColor = AppColors.civilian;
        break;
      case PlayerRole.undercover:
        roleName = 'Undercover Agent';
        roleColor = AppColors.undercover;
        break;
      case PlayerRole.mrWhite:
        roleName = 'Mr. White';
        roleColor = AppColors.mrWhite;
        break;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('${eliminatedPlayer.name} was...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              eliminatedPlayer.role == PlayerRole.civilian 
                ? Icons.people
                : eliminatedPlayer.role == PlayerRole.undercover 
                  ? Icons.person_search
                  : Icons.psychology,
              size: 48,
              color: roleColor,
            ),
            const SizedBox(height: 16),
            Text(
              roleName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: roleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'has been eliminated from the game',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Check for Mr. White special case
              if (eliminatedPlayer.role == PlayerRole.mrWhite) {
                _handleMrWhiteElimination(eliminatedPlayer);
              } else {
                // Check win condition after elimination
                final gameService = GameService.instance;
                final winResult = gameService.calculateWinCondition();
                if (winResult != null) {
                  // Game ends
                  gameService.endGame(winResult);
                  _navigateToResults();
                } else {
                  // Continue game - clear votes and return to description phase
                  gameService.clearVotes();
                  gameService.nextPhase(GamePhase.description);
                  _navigateToGameplay();
                }
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _handleMrWhiteElimination(Player mrWhite) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Mr. White Eliminated!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              size: 48,
              color: AppColors.mrWhite,
            ),
            const SizedBox(height: 16),
            Text(
              '${mrWhite.name} was Mr. White! They now have a chance to guess the civilian word and win the game.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showMrWhiteGuessDialog();
            },
            child: const Text('Let Mr. White Guess'),
          ),
        ],
      ),
    );
  }

  void _showMrWhiteGuessDialog() {
    final TextEditingController guessController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Mr. White\'s Final Guess'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mr. White, what is the civilian word?',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: guessController,
              decoration: const InputDecoration(
                hintText: 'Enter your guess...',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final guess = guessController.text.trim();
              if (guess.isNotEmpty) {
                Navigator.of(context).pop();
                _processMrWhiteGuess(guess);
              }
            },
            child: const Text('Submit Guess'),
          ),
        ],
      ),
    );
  }

  void _processMrWhiteGuess(String guess) {
    final gameService = GameService.instance;
    final isCorrect = gameService.handleMrWhiteGuess(guess);
    
    if (isCorrect) {
      // Mr. White wins
      gameService.endGame(GameResult.mrWhiteWins);
      _showMrWhiteResult(true, guess);
    } else {
      // Mr. White guessed incorrectly - game continues
      // Civilians don't automatically win, the game proceeds normally
      _showMrWhiteResult(false, guess);
    }
  }

  void _showMrWhiteResult(bool isCorrect, String guess) {
    final wordPair = GameService.instance.currentSession?.currentWordPair;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? 'Correct!' : 'Wrong!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              size: 64,
              color: isCorrect ? AppColors.success : AppColors.danger,
            ),
            const SizedBox(height: 16),
            Text(
              'Guess: "$guess"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (isCorrect) {
                // Mr. White wins - go to results
                _navigateToResults();
              } else {
                // Mr. White guessed incorrectly - continue game
                _continueGameAfterMrWhite();
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _continueGameAfterMrWhite() {
    // After Mr. White guesses incorrectly, continue the game normally
    final gameService = GameService.instance;
    
    // Check win condition after Mr. White elimination
    final winResult = gameService.calculateWinCondition();
    if (winResult != null) {
      // Game ends
      gameService.endGame(winResult);
      _navigateToResults();
    } else {
      // Continue game - clear votes and return to description phase
      gameService.clearVotes();
      gameService.nextPhase(GamePhase.description);
      _navigateToGameplay();
    }
  }

  void _navigateToResults() {
    Future.delayed(const Duration(milliseconds: 200), () {
      Navigator.of(context).pushReplacementNamed(
        Routes.result,
        arguments: GameService.instance.currentSession,
      );
    });
  }

  void _navigateToGameplay() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context).pushReplacementNamed(
        Routes.description,
        arguments: GameService.instance.currentSession,
      );
    });
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voting Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.group,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocalizationService().translate('voting_header_title'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      LocalizationService().translate('voting_header_subtitle'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPlayerGrid() {
    final activePlayers = _currentSession.players
        .where((player) => !player.isEliminated)
        .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: activePlayers.length,
      itemBuilder: (context, index) {
        final player = activePlayers[index];
        final isSelected = _selectedPlayer != null && _selectedPlayer!.id == player.id;
        
        return GestureDetector(
          key: ValueKey('player_${player.id}'),
          onTap: () => _selectPlayer(player),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                    ? AppColors.primary
                    : Colors.grey.shade300,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected 
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.1),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AvatarSelector.getAvatarIcon(
                      int.tryParse(player.avatarIndex) ?? 0,
                      size: 24,
                      //color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primary : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().translate('voting_app_bar_title')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            tooltip: LocalizationService().translate('voting_home_tooltip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildVotingHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'As a group, discuss and decide who should be eliminated',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildPlayerGrid(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: _selectedPlayer == null 
                      ? LocalizationService().translate('voting_select_player_button')
                      : LocalizationService().translate('voting_eliminate_player_button', placeholders: {'player': _selectedPlayer!.name}),
                  onPressed: _selectedPlayer == null ? null : _confirmVote,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}