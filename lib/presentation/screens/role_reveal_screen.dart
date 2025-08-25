import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/animations.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/localization_service.dart';
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
    final localization = LocalizationService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.translate('role_reveal_setup_error')),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(localization.translate('role_reveal_back_to_setup')),
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
    final localization = LocalizationService();
    switch (_currentPlayer.role) {
      case PlayerRole.civilian:
        return localization.translate('role_reveal_civilian');
      case PlayerRole.undercover:
        return localization.translate('role_reveal_undercover');
      case PlayerRole.mrWhite:
        return localization.translate('role_reveal_mr_white');
    }
  }

  String _getRoleDescription() {
    final localization = LocalizationService();
    switch (_currentPlayer.role) {
      case PlayerRole.civilian:
        return localization.translate('role_reveal_civilian_desc');
      case PlayerRole.undercover:
        return localization.translate('role_reveal_undercover_desc');
      case PlayerRole.mrWhite:
        return localization.translate('role_reveal_mr_white_desc');
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
        // Use uniform color for both front and back to hide role information
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_cardFlipAnimation.value * 3.14159),
          child: Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: AppColors.primary, // Use uniform color instead of role color
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
    final localization = LocalizationService();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.theater_comedy,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          Text(
            localization.translate('role_reveal_card_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            localization.translate('role_reveal_tap_instruction'),
            style: const TextStyle(
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
          color: AppColors.primary, // Use uniform color instead of role color
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _textFadeAnimation,
              child: Column(
                children: [
                  // Show generic role text instead of role-specific text
                  Text(
                    LocalizationService().translate('role_reveal_your_role'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Show generic description instead of role-specific description
                  Text(
                    LocalizationService().translate('role_reveal_role_description'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Show word only for non-Mr. White players
                  if (_isWordVisible) ...[
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
                        style: const TextStyle(
                          color: AppColors.primary,
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
    final localization = LocalizationService();
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
                    localization.translate('role_reveal_hand_phone', placeholders: {'player': _currentPlayer.name}),
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the card to reveal your word',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  Text(
                    localization.translate('role_reveal_memorize'),
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localization.translate('role_reveal_warning'),
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
                          ? localization.translate('role_reveal_next_player')
                          : localization.translate('role_reveal_start_game'),
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