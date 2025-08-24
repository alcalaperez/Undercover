import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../data/models/game_session.dart';
import '../../data/models/player.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/selectors/avatar_selector.dart';

class ResultScreen extends StatefulWidget {
  final GameSession gameSession;

  const ResultScreen({
    super.key,
    required this.gameSession,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late GameSession _gameSession;
  late AnimationController _winnersAnimationController;
  late AnimationController _revealAnimationController;
  late Animation<double> _winnersAnimation;
  late Animation<double> _revealAnimation;
  
  bool _showRoleReveal = false;
  bool _showWordReveal = false;

  @override
  void initState() {
    super.initState();
    _gameSession = widget.gameSession;
    _setupAnimations();
    _startAnimationSequence();
  }

  @override
  void dispose() {
    _winnersAnimationController.dispose();
    _revealAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _winnersAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _revealAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _winnersAnimation = CurvedAnimation(
      parent: _winnersAnimationController,
      curve: Curves.elasticOut,
    );
    
    _revealAnimation = CurvedAnimation(
      parent: _revealAnimationController,
      curve: Curves.easeInOut,
    );
  }

  void _startAnimationSequence() {
    _winnersAnimationController.forward();
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _showRoleReveal = true;
        });
        _revealAnimationController.forward();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _showWordReveal = true;
        });
      }
    });
  }

  String _getWinnerTitle() {
    switch (_gameSession.result) {
      case GameResult.civiliansWin:
        return 'Civilians Win!';
      case GameResult.undercoversWin:
        return 'Undercovers Win!';
      case GameResult.mrWhiteWins:
        return 'Mr. White Wins!';
      case GameResult.draw:
        return 'It\'s a Draw!';
      default:
        return 'Game Over';
    }
  }

  String _getWinnerSubtitle() {
    switch (_gameSession.result) {
      case GameResult.civiliansWin:
        return 'All threats have been eliminated!';
      case GameResult.undercoversWin:
        return 'The undercovers have infiltrated successfully!';
      case GameResult.mrWhiteWins:
        return 'Mr. White guessed the word correctly!';
      case GameResult.draw:
        return 'No clear winner this time!';
      default:
        return '';
    }
  }

  Color _getWinnerColor() {
    switch (_gameSession.result) {
      case GameResult.civiliansWin:
        return AppColors.civilian;
      case GameResult.undercoversWin:
        return AppColors.undercover;
      case GameResult.mrWhiteWins:
        return AppColors.mrWhite;
      case GameResult.draw:
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }

  IconData _getWinnerIcon() {
    switch (_gameSession.result) {
      case GameResult.civiliansWin:
        return Icons.shield;
      case GameResult.undercoversWin:
        return Icons.masks;
      case GameResult.mrWhiteWins:
        return Icons.psychology;
      case GameResult.draw:
        return Icons.balance;
      default:
        return Icons.emoji_events;
    }
  }

  List<Player> _getWinners() {
    switch (_gameSession.result) {
      case GameResult.civiliansWin:
        return _gameSession.players.where((p) => p.role == PlayerRole.civilian).toList();
      case GameResult.undercoversWin:
        return _gameSession.players.where((p) => p.role == PlayerRole.undercover).toList();
      case GameResult.mrWhiteWins:
        return _gameSession.players.where((p) => p.role == PlayerRole.mrWhite).toList();
      case GameResult.draw:
        return _gameSession.players; // Everyone in a draw
      default:
        return [];
    }
  }

  void _shareResults() {
    final winners = _getWinners();
    final winnerNames = winners.map((p) => p.name).join(', ');
    final wordPair = _gameSession.currentWordPair;
    
    final shareText = '''
🎭 Undercover Game Results 🎭

${_getWinnerTitle()}
Winners: $winnerNames

📝 Words:
• Civilian word: ${wordPair?.civilianWord ?? 'Unknown'}
• Undercover word: ${wordPair?.undercoverWord ?? 'Unknown'}

🎮 Game Stats:
• Players: ${_gameSession.players.length}
• Duration: ${_getGameDuration()}

Play Undercover Game!
    ''';
    
    Share.share(shareText);
  }

  String _getGameDuration() {
    if (_gameSession.endedAt == null || _gameSession.startedAt == null) return 'Unknown';
    
    final duration = _gameSession.endedAt!.difference(_gameSession.startedAt!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return '${minutes}m ${seconds}s';
  }

  void _playAgain() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.gameSetup,
      (route) => route.isFirst,
    );
  }

  Widget _buildWinnerAnnouncement() {
    return AnimatedBuilder(
      animation: _winnersAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _winnersAnimation.value,
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _getWinnerColor(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getWinnerColor().withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _getWinnerIcon(),
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _getWinnerTitle(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getWinnerColor(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _getWinnerSubtitle(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleReveal() {
    if (!_showRoleReveal) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _revealAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _revealAnimation.value,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role Reveal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...PlayerRole.values.map((role) {
                    final playersWithRole = _gameSession.players
                        .where((p) => p.role == role)
                        .toList();
                    
                    if (playersWithRole.isEmpty) return const SizedBox.shrink();
                    
                    return _buildRoleGroup(role, playersWithRole);
                  }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleGroup(PlayerRole role, List<Player> players) {
    String roleTitle;
    Color roleColor;
    
    switch (role) {
      case PlayerRole.civilian:
        roleTitle = 'Civilians';
        roleColor = AppColors.civilian;
        break;
      case PlayerRole.undercover:
        roleTitle = 'Undercovers';
        roleColor = AppColors.undercover;
        break;
      case PlayerRole.mrWhite:
        roleTitle = 'Mr. White';
        roleColor = AppColors.mrWhite;
        break;
    }
    
    // Check if this role won the game
    final winners = _getWinners();
    final isWinningRole = winners.any((winner) => winner.role == role);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$roleTitle (${players.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: roleColor,
                ),
              ),
              if (isWinningRole) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'WINNERS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: players.map((player) {
              final isWinner = winners.contains(player);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isWinner 
                      ? Colors.green.withValues(alpha: 0.2) 
                      : roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isWinner 
                        ? Colors.green 
                        : roleColor.withValues(alpha: 0.3)
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarSelector.getAvatarIcon(
                      int.tryParse(player.avatarIndex) ?? 0,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      player.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isWinner 
                            ? Colors.green.shade700 
                            : roleColor,
                        fontSize: 14,
                      ),
                    ),
                    if (player.isEliminated) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.cancel,
                        size: 16,
                        color: Colors.red.shade400,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWordReveal() {
    if (!_showWordReveal) return const SizedBox.shrink();
    
    final wordPair = _gameSession.currentWordPair;
    if (wordPair == null) return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Word Reveal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWordCard(
                    'Civilian Word',
                    wordPair.civilianWord,
                    AppColors.civilian,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWordCard(
                    'Undercover Word',
                    wordPair.undercoverWord,
                    AppColors.undercover,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Category: ${wordPair.category}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordCard(String title, String word, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGameSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Game Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getWinnerColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getWinnerColor().withOpacity(0.3)),
                  ),
                  child: Text(
                    _getWinnerTitle(),
                    style: TextStyle(
                      color: _getWinnerColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Duration', _getGameDuration(), Icons.timer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Players', '${_gameSession.players.length}', Icons.group),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Rounds', '${_gameSession.currentRound}', Icons.replay),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Eliminated', 
                    '${_gameSession.players.where((p) => p.isEliminated).length}', 
                    Icons.cancel
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Remaining', 
                    '${_gameSession.players.where((p) => !p.isEliminated).length}', 
                    Icons.check_circle
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Difficulty', 
                    _gameSession.currentWordPair?.difficulty.name ?? 'Unknown', 
                    Icons.speed
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'Play Again',
                onPressed: _playAgain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareResults,
                icon: const Icon(Icons.share),
                label: const Text('Share Results'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Main Menu'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Results'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildWinnerAnnouncement(),
              const SizedBox(height: 24),
              _buildGameSummary(),
              const SizedBox(height: 24),
              _buildRoleReveal(),
              const SizedBox(height: 16),
              _buildWordReveal(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}