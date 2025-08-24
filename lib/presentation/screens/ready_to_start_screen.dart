import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/animations.dart';
import '../../core/utils/routes.dart';
import '../../data/models/player.dart';
import '../../data/models/game_settings.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/cards/player_card.dart';
import '../widgets/cards/game_info_card.dart';

class ReadyToStartScreen extends StatefulWidget {
  final List<Player> players;
  final GameSettings settings;

  const ReadyToStartScreen({
    super.key,
    required this.players,
    required this.settings,
  });

  @override
  State<ReadyToStartScreen> createState() => _ReadyToStartScreenState();
}

class _ReadyToStartScreenState extends State<ReadyToStartScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startGame() async {
    setState(() {
      _isStarting = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        Routes.roleReveal,
        arguments: {
          'players': widget.players,
          'settings': widget.settings,
        },
      );
    }
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  String _getGameSummary() {
    final playerCount = widget.players.length;
    final undercoverCount = widget.settings.undercoverCount;
    final hasMrWhite = widget.settings.includeMrWhite;
    final civilianCount = playerCount - undercoverCount - (hasMrWhite ? 1 : 0);

    String summary = '$civilianCount Civilians vs $undercoverCount Undercover';
    if (undercoverCount > 1) summary += 's';
    
    if (hasMrWhite) {
      summary += ' vs 1 Mr. White';
    }

    return summary;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready to Start'),
        automaticallyImplyLeading: false,
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Game Summary Cards
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text(
                            'Game Setup Complete!',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            _getGameSummary(),
                            style: AppTextStyles.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Game Info Cards
                          Row(
                            children: [
                              Expanded(
                                child: GameInfoCard(
                                  title: 'Players',
                                  value: '${widget.players.length}',
                                  icon: Icons.people,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GameInfoCard(
                                  title: 'Undercovers',
                                  value: '${widget.settings.undercoverCount}',
                                  icon: Icons.visibility_off,
                                  color: AppColors.undercover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GameInfoCard(
                                  title: 'Mr. White',
                                  value: widget.settings.includeMrWhite ? '1' : '0',
                                  icon: Icons.help_outline,
                                  color: AppColors.mrWhite,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Settings Summary
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Timer:',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        widget.settings.descriptionTimeLimit == 0
                                            ? 'No Timer'
                                            : '${widget.settings.descriptionTimeLimit}s',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Difficulty:',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        widget.settings.wordDifficulty.name.toUpperCase(),
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Categories:',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${widget.settings.selectedCategories.length} selected',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Players Preview
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Players (${widget.players.length})',
                            style: AppTextStyles.labelLarge,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: widget.players.length,
                              itemBuilder: (context, index) {
                                return PlayerCard(
                                  player: widget.players[index],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Warning and Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.warning,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Make sure everyone is ready!',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Once the game starts, roles will be assigned and revealed to each player privately. Make sure everyone can see the screen clearly.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Back to Setup',
                  onPressed: _goBack,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  text: 'Start Game',
                  isLoading: _isStarting,
                  onPressed: _startGame,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}