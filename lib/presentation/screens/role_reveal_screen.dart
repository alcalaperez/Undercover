import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/animations.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../data/models/player.dart';
import '../../data/models/game_settings.dart';
import '../../data/repositories/game_service.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/dialogs/pass_phone_dialog.dart';

class RoleRevealScreen extends StatefulWidget {
  final List<Player> players;
  final GameSettings settings;

  const RoleRevealScreen({
    super.key,
    required this.players,
    required this.settings,
  });

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _textController;
  late Animation<double> _cardFlipAnimation;
  late Animation<double> _textFadeAnimation;

  int _currentPlayerIndex = 0;
  bool _isCardRevealed = false;
  bool _isWordVisible = false;
  bool _isInitializingGame = true;

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

    _textController = AnimationController(
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

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
  }

  Future<void> _initializeGame() async {
    try {
      final gameService = GameService.instance;
      await gameService.initializeGame(widget.players, widget.settings);
      
      setState(() {
        _isInitializingGame = false;
      });
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Setup Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Setup'),
          ),
        ],
      ),
    );
  }

  Player get _currentPlayer => GameService.instance.currentSession!.players[_currentPlayerIndex];

  Color _getRoleColor() {
    switch (_currentPlayer.role) {
      case PlayerRole.civilian:
        return AppColors.civilian;
      case PlayerRole.undercover:
        return AppColors.undercover;
      case PlayerRole.mrWhite:
        return AppColors.mrWhite;
    }
  }

  String _getRoleText() {
    switch (_currentPlayer.role) {
      case PlayerRole.civilian:
        return 'CIVILIAN';
      case PlayerRole.undercover:
        return 'UNDERCOVER';
      case PlayerRole.mrWhite:
        return 'MR. WHITE';
    }
  }

  String _getRoleDescription() {
    switch (_currentPlayer.role) {
      case PlayerRole.civilian:
        return 'You know the word. Describe it without being too obvious.';
      case PlayerRole.undercover:
        return 'You have a different word. Try to blend in with the civilians.';
      case PlayerRole.mrWhite:
        return 'You don\'t know any word. Listen carefully and try to guess what everyone is talking about.';
    }
  }

  void _revealCard() {
    if (!_isCardRevealed) {
      setState(() {
        _isCardRevealed = true;
      });
      _cardController.forward();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _textController.forward();
          setState(() {
            _isWordVisible = true;
          });
        }
      });
    }
  }

  void _nextPlayer() {
    if (_currentPlayerIndex < widget.players.length - 1) {
      final nextPlayer = GameService.instance.currentSession!.players[_currentPlayerIndex + 1];
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PassPhoneDialog(
          currentPlayer: _currentPlayer,
          nextPlayer: nextPlayer,
          currentIndex: _currentPlayerIndex,
          totalPlayers: widget.players.length,
          onContinue: () {
            setState(() {
              _currentPlayerIndex++;
              _isCardRevealed = false;
              _isWordVisible = false;
            });
            _cardController.reset();
            _textController.reset();
          },
        ),
      );
    } else {
      // Show final dialog before starting game
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PassPhoneDialog(
          currentPlayer: _currentPlayer,
          nextPlayer: null,
          currentIndex: _currentPlayerIndex,
          totalPlayers: widget.players.length,
          onContinue: _startGame,
        ),
      );
    }
  }

  void _startGame() {
    final gameService = GameService.instance;
    gameService.nextPhase(GamePhase.description);
    
    Navigator.of(context).pushReplacementNamed(
      Routes.description,
      arguments: gameService.currentSession,
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text('Setting up game...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard() {
    return AnimatedBuilder(
      animation: _cardFlipAnimation,
      builder: (context, child) {
        final isShowingFront = _cardFlipAnimation.value < 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_cardFlipAnimation.value * 3.14159),
          child: Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: isShowingFront ? AppColors.primary : _getRoleColor(),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: isShowingFront ? _buildCardFront() : _buildCardBack(),
          ),
        );
      },
    );
  }

  Widget _buildCardFront() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.theater_comedy,
            size: 80,
            color: Colors.white,
          ),
          SizedBox(height: 20),
          Text(
            'UNDERCOVER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Tap to reveal your role',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(3.14159),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _getRoleColor(),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _textFadeAnimation,
              child: Column(
                children: [
                  Text(
                    _getRoleText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    _getRoleDescription(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  if (_isWordVisible && _currentPlayer.assignedWord.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _currentPlayer.assignedWord.toUpperCase(),
                        style: TextStyle(
                          color: _getRoleColor(),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializingGame) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              AppColors.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: (_currentPlayerIndex + 1) / widget.players.length,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                
                const SizedBox(height: 20),
                
                // Player info
                Text(
                  'Player ${_currentPlayerIndex + 1} of ${widget.players.length}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _currentPlayer.name,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Spacer(),
                
                // Role card
                GestureDetector(
                  onTap: _revealCard,
                  child: _buildRoleCard(),
                ),
                
                const Spacer(),
                
                // Instructions
                if (!_isCardRevealed) ...[
                  Text(
                    'Hand the phone to ${_currentPlayer.name}',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the card to reveal your role',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text(
                    'Memorize your role and word',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Don\'t let other players see!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.danger,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Continue button
                if (_isCardRevealed)
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: _currentPlayerIndex < widget.players.length - 1
                          ? 'Next Player'
                          : 'Start Game',
                      onPressed: _nextPlayer,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}