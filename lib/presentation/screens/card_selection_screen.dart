import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/animations.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
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
    if (_isCardSelected || _usedCardIndices.contains(cardIndex)) return;

    setState(() {
      _selectedCardIndex = cardIndex;
      _isCardSelected = true;
    });

    HapticFeedback.mediumImpact();
    _cardController.forward();
  }

  void _revealRole() {
    if (!_isCardSelected || _selectedCardIndex == null) return;

    final gameService = GameService.instance;
    final currentPlayer = widget.players[_currentPlayerIndex];
    
    // Assign the role for this card selection
    gameService.assignPlayerRole(currentPlayer.id, _selectedCardIndex!);
    
    setState(() {
      _isRoleRevealed = true;
    });

    _revealController.forward();
    HapticFeedback.heavyImpact();
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setup Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to game setup
            },
            child: const Text('OK'),
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
        final isSelectable = !_isCardSelected && !isUsed;
        
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
                            ? _getRoleColor(index) 
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.close,
              size: 32,
              color: Colors.white70,
            ),
            SizedBox(height: 4),
            Text(
              'TAKEN',
              style: TextStyle(
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
    final role = _getCardRole(cardIndex);
    final roleIcon = _getRoleIcon(role);
    final roleName = _getRoleName(role);
    
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
              roleIcon,
              size: 32,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                roleName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            if (_isRoleRevealed && role != PlayerRole.mrWhite) ...[
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
                        _getPlayerWord(role),
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
        return AppColors.civilian;
      case PlayerRole.undercover:
        return AppColors.undercover;
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
    switch (role) {
      case PlayerRole.civilian:
        return 'Civilian';
      case PlayerRole.undercover:
        return 'Undercover\nAgent';
      case PlayerRole.mrWhite:
        return 'Mr. White';
    }
  }

  String _getPlayerWord(PlayerRole role) {
    final gameService = GameService.instance;
    final wordPair = gameService.currentSession?.currentWordPair;
    
    if (wordPair == null) return '';
    
    switch (role) {
      case PlayerRole.civilian:
        return wordPair.civilianWord;
      case PlayerRole.undercover:
        return wordPair.undercoverWord;
      case PlayerRole.mrWhite:
        return 'You don\'t know the word!';
    }
  }

  Widget _buildLargeRoleCard() {
    if (_selectedCardIndex == null) return const SizedBox();
    
    final role = _getCardRole(_selectedCardIndex!);
    final roleColor = _getRoleColor(_selectedCardIndex!);
    final roleIcon = _getRoleIcon(role);
    final roleName = _getRoleName(role).replaceAll('\n', ' ');
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Role icon
                Icon(
                  roleIcon,
                  size: 120,
                  color: Colors.white,
                ),
                
                const SizedBox(height: 24),
                
                // Role name
                Text(
                  'You are',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  roleName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Word section
                if (role != PlayerRole.mrWhite) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your word is:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          playerWord,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.visibility_off,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You don\'t know the word!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Listen carefully and try to blend in',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
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
    final currentPlayer = widget.players[_currentPlayerIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
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
                          ? 'Your role has been revealed!'
                          : _isCardSelected
                              ? 'Card selected - ready to reveal'
                              : 'Choose a card to discover your role',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Player ${_currentPlayerIndex + 1} of ${widget.players.length}',
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
                      ? 'Select a Card'
                      : !_isRoleRevealed
                          ? 'Reveal Your Role'
                          : _currentPlayerIndex < widget.players.length - 1
                              ? 'Pass to Next Player'
                              : 'Start Game',
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