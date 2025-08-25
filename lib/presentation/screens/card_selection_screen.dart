import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/animations.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/localization_service.dart';
import '../../data/models/player.dart';
import '../../data/models/game_settings.dart';
import '../../data/repositories/game_service.dart';
import '../widgets/buttons/primary_button.dart';

class CardSelectionScreen extends StatefulWidget {
  final List<Player> players;
  final GameSettings settings;

  const CardSelectionScreen({
    super.key,
    required this.players,
    required this.settings,
  });

  @override
  State<CardSelectionScreen> createState() => _CardSelectionScreenState();
}

class _CardSelectionScreenState extends State<CardSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _revealController;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _revealAnimation;

  int _currentPlayerIndex = 0;
  bool _isGameInitialized = false;
  bool _isCardSelected = false;
  bool _isRoleRevealed = false;
  List<int> _availableCardIndices = [];
  final List<int> _usedCardIndices = [];
  int? _selectedCardIndex;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeGame();
  }

  void _setupAnimations() {
    _cardController = AnimationController(
      duration: AppAnimations.cardFlip,
      vsync: this,
    );

    _revealController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    _cardFlipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeInOut,
    ));

    _revealAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeIn,
    ));
  }

  Future<void> _initializeGame() async {
    try {
      final gameService = GameService.instance;
      await gameService.initializeGameWithoutRoles(widget.players, widget.settings);
      
      // Create shuffled card indices for all players
      _availableCardIndices = List.generate(widget.players.length, (index) => index);
      _availableCardIndices.shuffle();

      setState(() {
        _isGameInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _selectCard(int cardIndex) {
    // Allow changing the first selected card before role is revealed
    if (_usedCardIndices.contains(cardIndex)) return;

    setState(() {
      _selectedCardIndex = cardIndex;
      _isCardSelected = true;
    });

    _cardController.forward();
  }

  void _revealRole() {
    if (!_isCardSelected || _selectedCardIndex == null) return;

    final gameService = GameService.instance;
    final currentPlayer = widget.players[_currentPlayerIndex];
    
    // Check if this is the first player and Mr. White first draw prevention is enabled
    if (_currentPlayerIndex == 0 && 
        gameService.currentSession?.settings.mrWhiteFirstDraw == true &&
        gameService.currentSession?.settings.includeMrWhite == true) {
      
      final selectedRole = gameService.getShuffledRoles()[_selectedCardIndex!];
      
      if (selectedRole == PlayerRole.mrWhite) {
        // First player selected Mr. White and prevention is enabled - reshuffle!
        _handleMrWhiteFirstDrawPrevention();
        return;
      }
    }
    
    // Assign the role for this card selection
    gameService.assignPlayerRole(currentPlayer.id, _selectedCardIndex!);
    
    setState(() {
      _isRoleRevealed = true;
    });

    _revealController.forward();
  }

  void _handleMrWhiteFirstDrawPrevention() {
    // Show dialog explaining what happened
    final localization = LocalizationService();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.shuffle,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(localization.translate('card_selection_reshuffled_title')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              size: 64,
              color: AppColors.mrWhite,
            ),
            const SizedBox(height: 16),
            Text(
              localization.translate('card_selection_mr_white_prevented'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              localization.translate('card_selection_reshuffled_message'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reshuffleCards();
            },
            child: Text(localization.translate('card_selection_select_new_card')),
          ),
        ],
      ),
    );
  }

  void _reshuffleCards() {
    final gameService = GameService.instance;
    
    // Regenerate shuffled roles with Mr. White prevention
    gameService.reshuffleRolesWithMrWhitePrevention();
    
    // Reset card selection state
    setState(() {
      _isCardSelected = false;
      _isRoleRevealed = false;
      _selectedCardIndex = null;
    });
    
    // Reset animations
    _cardController.reset();
    _revealController.reset();
  }

  void _nextPlayer() {
    if (_currentPlayerIndex < widget.players.length - 1) {
      // Add the selected card to used cards
      if (_selectedCardIndex != null) {
        _usedCardIndices.add(_selectedCardIndex!);
      }
      
      setState(() {
        _currentPlayerIndex++;
        _isCardSelected = false;
        _isRoleRevealed = false;
        _selectedCardIndex = null;
      });
      
      _cardController.reset();
      _revealController.reset();
    } else {
      // All players have selected cards, proceed to game
      _proceedToGame();
    }
  }

  void _proceedToGame() {
    final gameService = GameService.instance;
    gameService.finalizeGameSetup();
    
    Navigator.of(context).pushReplacementNamed(
      Routes.description,
      arguments: gameService.currentSession,
    );
  }

  void _showErrorDialog(String error) {
    final localization = LocalizationService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('card_selection_setup_error')),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to game setup
            },
            child: Text(localization.translate('card_selection_ok_button')),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGrid() {
    final cardsToShow = _availableCardIndices.length;
    final crossAxisCount = cardsToShow <= 6 ? 3 : 4;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: cardsToShow,
      itemBuilder: (context, index) {
        final isSelected = _selectedCardIndex == index;
        final isUsed = _usedCardIndices.contains(index);
        // Allow selecting cards if not used and either no card is selected yet or role is not revealed
        final isSelectable = (!isUsed && (!_isCardSelected || !_isRoleRevealed)) || 
                            (isSelected && !_isRoleRevealed); // Allow changing selected card before reveal
        
        return GestureDetector(
          onTap: isSelectable ? () => _selectCard(index) : null,
          child: AnimatedBuilder(
            animation: _cardFlipAnimation,
            builder: (context, child) {
              final isFlipped = _cardFlipAnimation.value > 0.5 && isSelected;
              
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(isSelected ? _cardFlipAnimation.value * 3.14159 : 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isUsed 
                        ? Colors.grey.shade400
                        : isFlipped 
                            ? AppColors.primary // Use uniform primary color for all roles
                            : AppColors.cardBack,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary 
                          : isUsed 
                              ? Colors.grey.shade500
                              : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected 
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isUsed
                      ? _buildUsedCard()
                      : isFlipped
                          ? _buildRoleCard(index)
                          : _buildCardBack(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.help_outline,
              size: 32,
              color: Colors.white,
            ),
            SizedBox(height: 4),
            Text(
              '?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsedCard() {
    final localization = LocalizationService();
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.close,
              size: 32,
              color: Colors.white70,
            ),
            const SizedBox(height: 4),
            Text(
              localization.translate('card_selection_taken_card'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(int cardIndex) {
    // Don't show role information during card selection
    // Only show generic "Selected" text to maintain mystery
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159), // Flip the content back
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                LocalizationService().translate('card_selection_selected'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedBuilder(
              animation: _revealAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _revealAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      LocalizationService().translate('card_selection_word_assigned'),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  PlayerRole _getCardRole(int cardIndex) {
    final gameService = GameService.instance;
    final shuffledRoles = gameService.getShuffledRoles();
    return shuffledRoles[cardIndex];
  }

  Color _getRoleColor(int cardIndex) {
    final role = _getCardRole(cardIndex);
    switch (role) {
      case PlayerRole.civilian:
        return AppColors.cardBack;
      // For showing the card, we cannot disclose who are undercover
      case PlayerRole.undercover:
        return AppColors.cardBack;
      case PlayerRole.mrWhite:
        return AppColors.mrWhite;
    }
  }

  IconData _getRoleIcon(PlayerRole role) {
    switch (role) {
      case PlayerRole.civilian:
        return Icons.people;
      case PlayerRole.undercover:
        return Icons.person_search;
      case PlayerRole.mrWhite:
        return Icons.psychology;
    }
  }

  String _getRoleName(PlayerRole role) {
    final localization = LocalizationService();
    switch (role) {
      case PlayerRole.civilian:
        return localization.translate('card_selection_role_civilian');
      case PlayerRole.undercover:
        return localization.translate('card_selection_role_undercover');
      case PlayerRole.mrWhite:
        return localization.translate('card_selection_role_mr_white');
    }
  }

  String _getPlayerWord(PlayerRole role) {
    final localization = LocalizationService();
    final gameService = GameService.instance;
    final wordPair = gameService.currentSession?.currentWordPair;
    
    if (wordPair == null) return '';
    
    switch (role) {
      case PlayerRole.civilian:
        return wordPair.civilianWord;
      case PlayerRole.undercover:
        return wordPair.undercoverWord;
      case PlayerRole.mrWhite:
        return localization.translate('card_selection_mr_white_message');
    }
  }

  Widget _buildLargeRoleCard() {
    if (_selectedCardIndex == null) return const SizedBox();
    
    final localization = LocalizationService();
    final role = _getCardRole(_selectedCardIndex!);
    final roleColor = _getRoleColor(_selectedCardIndex!);
    final playerWord = _getPlayerWord(role);
    
    return AnimatedBuilder(
      animation: _revealAnimation,
      builder: (context, child) {
        return Center(
          child: Container(
            width: double.infinity,
            height: 400,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  roleColor,
                  roleColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: roleColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Role icon - generic for all roles to maintain mystery
                  Icon(
                    Icons.vpn_key,
                    size: 100,
                    color: Colors.white,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Generic message
                  Text(
                    localization.translate('card_selection_your_card'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Word section - this is what matters for gameplay
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: role != PlayerRole.mrWhite 
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                localization.translate('card_selection_your_word'),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                playerWord,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.visibility_off,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                localization.translate('card_selection_mr_white_message'),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                localization.translate('card_selection_mr_white_instruction'),
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPlayer = widget.players[_currentPlayerIndex];
    final localization = LocalizationService();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('card_selection_title')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Player info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      currentPlayer.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRoleRevealed
                          ? localization.translate('card_selection_role_revealed')
                          : _isCardSelected
                              ? localization.translate('card_selection_card_selected')
                              : localization.translate('card_selection_choose_card_instruction'),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      localization.translate('role_reveal_player_progress', placeholders: {
                        'current': (_currentPlayerIndex + 1).toString(),
                        'total': widget.players.length.toString(),
                      }),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Main content area
              Expanded(
                child: _isGameInitialized 
                    ? (_isRoleRevealed 
                        ? _buildLargeRoleCard() 
                        : _buildCardGrid())
                    : const Center(child: CircularProgressIndicator()),
              ),

              const SizedBox(height: 24),

              // Action button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: !_isCardSelected
                      ? localization.translate('card_selection_select_card_button')
                      : !_isRoleRevealed
                          ? localization.translate('card_selection_reveal_word_button')
                          : _currentPlayerIndex < widget.players.length - 1
                              ? localization.translate('card_selection_next_player_button')
                              : localization.translate('role_reveal_start_game'),
                  onPressed: !_isCardSelected
                      ? null
                      : !_isRoleRevealed
                          ? _revealRole
                          : _nextPlayer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _revealController.dispose();
    super.dispose();
  }
}