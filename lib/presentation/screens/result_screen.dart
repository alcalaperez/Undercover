import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/localization_service.dart';
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
        return LocalizationService().translate('result_civilians_win');
      case GameResult.undercoversWin:
        return LocalizationService().translate('result_undercovers_win');
      case GameResult.mrWhiteWins:
        return LocalizationService().translate('result_mr_white_wins');
      case GameResult.draw:
        return LocalizationService().translate('result_draw');
      default:
        return LocalizationService().translate('result_game_over');
    }
  }

  String _getWinnerSubtitle() {
    switch (_gameSession.result) {
      case GameResult.civiliansWin:
        return LocalizationService().translate('result_civilians_subtitle');
      case GameResult.undercoversWin:
        return LocalizationService().translate('result_undercovers_subtitle');
      case GameResult.mrWhiteWins:
        return LocalizationService().translate('result_mr_white_subtitle');
      case GameResult.draw:
        return LocalizationService().translate('result_draw_subtitle');
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
    
    final shareText = LocalizationService().translate('result_share_text', placeholders: {
      'winner_title': _getWinnerTitle(),
      'winners': winnerNames,
      'civilian_word': wordPair?.civilianWord ?? LocalizationService().translate('result_unknown'),
      'undercover_word': wordPair?.undercoverWord ?? LocalizationService().translate('result_unknown'),
      'player_count': _gameSession.players.length.toString(),
      'duration': _getGameDuration()
    });
    
    Share.share(shareText);
  }

  String _getGameDuration() {
    if (_gameSession.endedAt == null || _gameSession.startedAt == null) {
      return LocalizationService().translate('result_unknown');
    }
    
    final duration = _gameSession.endedAt!.difference(_gameSession.startedAt!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return LocalizationService().translate('result_duration_format', placeholders: {
      'minutes': minutes.toString(),
      'seconds': seconds.toString()
    });
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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
                    LocalizationService().translate('result_role_reveal'),
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
        roleTitle = LocalizationService().translate('result_civilians');
        roleColor = AppColors.civilian;
        break;
      case PlayerRole.undercover:
        roleTitle = LocalizationService().translate('result_undercovers');
        roleColor = AppColors.undercover;
        break;
      case PlayerRole.mrWhite:
        roleTitle = LocalizationService().translate('result_mr_white');
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
                  child: Text(
                    LocalizationService().translate('result_winners_badge'),
                    style: const TextStyle(
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
              LocalizationService().translate('result_word_reveal'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWordCard(
                    LocalizationService().translate('result_civilian_word'),
                    wordPair.civilianWord,
                    AppColors.civilian,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWordCard(
                    LocalizationService().translate('result_undercover_word'),
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
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  LocalizationService().translate('result_category', placeholders: {
                    'category': wordPair.category
                  }),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
              fontSize: 11
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 19
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
                  LocalizationService().translate('result_game_summary'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    LocalizationService().translate('result_duration'),
                    _getGameDuration(),
                    Icons.timer
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    LocalizationService().translate('result_players'),
                    '${_gameSession.players.length}',
                    Icons.group
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    LocalizationService().translate('result_rounds'),
                    '${_gameSession.currentRound}',
                    Icons.replay
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    LocalizationService().translate('result_eliminated'), 
                    '${_gameSession.players.where((p) => p.isEliminated).length}', 
                    Icons.cancel
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    LocalizationService().translate('result_remaining'), 
                    '${_gameSession.players.where((p) => !p.isEliminated).length}', 
                    Icons.check_circle
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    LocalizationService().translate('result_difficulty'), 
                    _gameSession.currentWordPair?.difficulty.name ?? LocalizationService().translate('result_unknown'), 
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: 11
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
                text: LocalizationService().translate('result_play_again'),
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
                label: Text(LocalizationService().translate('result_share_results')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: Text(LocalizationService().translate('result_main_menu')),
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
        title: Text(LocalizationService().translate('result_title')),
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
              const SizedBox(height: 10),
              _buildWordReveal(),
              const SizedBox(height: 24),
              _buildRoleReveal(),
              const SizedBox(height: 16),
              _buildGameSummary(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}