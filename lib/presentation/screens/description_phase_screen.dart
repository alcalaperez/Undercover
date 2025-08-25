import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../data/models/game_session.dart';
import '../../data/models/player.dart';
import '../../data/repositories/game_service.dart';
import '../widgets/buttons/primary_button.dart';

class DescriptionPhaseScreen extends StatefulWidget {
  final GameSession gameSession;

  const DescriptionPhaseScreen({
    super.key,
    required this.gameSession,
  });

  @override
  State<DescriptionPhaseScreen> createState() => _DescriptionPhaseScreenState();
}

class _DescriptionPhaseScreenState extends State<DescriptionPhaseScreen>
    with TickerProviderStateMixin {
  late GameSession _currentSession;
  Timer? _phaseTimer;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  bool _isTimerPaused = false;
  
  late AnimationController _timerController;
  late Animation<Color?> _timerColorAnimation;
  
  final List<String> _phaseHistory = [];
  int _currentPlayerTurn = 0;
  int _descriptionTimePerPlayer = 30; // seconds per player

  @override
  void initState() {
    super.initState();
    _currentSession = widget.gameSession;
    _setupAnimations();
    _startDescriptionPhase();
    _addToHistory('Description phase started');
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _timerController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _timerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _timerColorAnimation = ColorTween(
      begin: Colors.green,
      end: Colors.red,
    ).animate(_timerController);
  }

  void _startDescriptionPhase() {
    _currentPlayerTurn = 0;
    _descriptionTimePerPlayer = _currentSession.settings.descriptionTimeLimit > 0 
        ? _currentSession.settings.descriptionTimeLimit
        : 0; // 0 means no timer
    _remainingSeconds = _descriptionTimePerPlayer;
    _addToHistory('Description phase started - ${_getCurrentPlayer().name}\'s turn');
    
    if (_descriptionTimePerPlayer > 0) {
      _startTimer();
    }
  }

  void _startTimer() {
    // Cancel any existing timer
    _phaseTimer?.cancel();
    
    _isTimerRunning = true;
    _isTimerPaused = false;
    _timerController.forward();
    
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerPaused && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        
        double progress = 1.0 - (_remainingSeconds / _descriptionTimePerPlayer);
        _timerController.value = progress;
        
        if (_remainingSeconds == 10 || _remainingSeconds == 5) {
          HapticFeedback.mediumImpact();
        }
        
        if (_remainingSeconds == 0) {
          _onTimerExpired();
        }
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isTimerPaused = true;
    });
    _addToHistory('Timer paused by game master');
  }

  void _resumeTimer() {
    setState(() {
      _isTimerPaused = false;
    });
    _addToHistory('Timer resumed by game master');
  }

  void _onTimerExpired() {
    _phaseTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
    HapticFeedback.heavyImpact();
    _addToHistory('${_getCurrentPlayer().name}s time expired');
    // Automatically move to the next player after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      _nextPlayerTurn();
    });
  }

      void _addToHistory(String event) {
      final timestamp = DateTime.now();
      final timeString = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
      _phaseHistory.add('[$timeString] $event');
    }

    Player _getCurrentPlayer() {
      final activePlayers = _currentSession.activePlayers;
      return activePlayers[_currentPlayerTurn % activePlayers.length];
    }

    void _nextPlayerTurn() {
      final activePlayers = _currentSession.activePlayers;

      if (_currentPlayerTurn < activePlayers.length - 1) {
        setState(() {
          _currentPlayerTurn++;
          _remainingSeconds = _descriptionTimePerPlayer;
          _isTimerRunning = _descriptionTimePerPlayer > 0; // Restart timer if there's a time limit
          _isTimerPaused = false;
        });

        if (_descriptionTimePerPlayer > 0) {
          _timerController.reset();
          _startTimer(); // Restart the timer
        }

        _addToHistory('${_getCurrentPlayer().name}\'s turn to describe');

        HapticFeedback.mediumImpact();

      } else {
        // All players have had their turn
        _phaseTimer?.cancel();
        setState(() {
          _isTimerRunning = false;
        });

        HapticFeedback.heavyImpact();
        _addToHistory('All players completed description phase');

        _navigateToDiscussion();
      }
    }

    void _skipCurrentTurn() {
      // Stop the timer if it's running
      if (_isTimerRunning) {
        _phaseTimer?.cancel();
        setState(() {
          _isTimerRunning = false;
        });
      }

      _addToHistory('${_getCurrentPlayer().name}\'s turn skipped');
      _nextPlayerTurn();
    }

    void _navigateToDiscussion() {
      // Update the session to move to discussion phase
      final gameService = GameService.instance;
      gameService.nextPhase(GamePhase.discussion);

      Navigator.of(context).pushReplacementNamed(
        Routes.discussion,
        arguments: gameService.currentSession,
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Undercover'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              tooltip: 'Home',
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPhaseHeader(),
                const SizedBox(height: 16),
                _buildDescriptionInfoCard(),
                const SizedBox(height: 16),
                Expanded(child: Container()), // Pushes content to bottom
                _buildPhaseControls(),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildPhaseHeader() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Turn',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          _getCurrentPlayer().name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Player ${_currentPlayerTurn + 1} of ${_currentSession.activePlayers.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _skipCurrentTurn,
                  icon: const Icon(Icons.skip_next),
                  tooltip: 'Skip Turn',
                  color: Colors.blue,
                ),
              ],
            ),
            if (_descriptionTimePerPlayer > 0) ...[
              const SizedBox(height: 16),
              _buildTimer(),
            ],
          ],
        ),
      );
    }

    Widget _buildTimer() {
      final minutes = _remainingSeconds ~/ 60;
      final seconds = _remainingSeconds % 60;
      final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

      return AnimatedBuilder(
        animation: _timerColorAnimation,
        builder: (context, child) {
          return Column(
            children: [
              LinearProgressIndicator(
                value: 1.0 - (_remainingSeconds / _descriptionTimePerPlayer),
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _timerColorAnimation.value ?? Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    timeString,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _timerColorAnimation.value,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (_isTimerRunning) ...[
                        IconButton(
                          onPressed: _isTimerPaused ? _resumeTimer : _pauseTimer,
                          icon: Icon(
                            _isTimerPaused ? Icons.play_arrow : Icons.pause,
                            color: _timerColorAnimation.value,
                          ),
                          tooltip: _isTimerPaused ? 'Resume' : 'Pause',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (_isTimerPaused)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PAUSED',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }

    Widget _buildDescriptionInfoCard() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.description,
                size: 48,
                color: Colors.blue.shade600,
              ),
              const SizedBox(height: 12),
              Text(
                'Description Phase',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Each player will describe their word without being too obvious.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description Tips',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Be vague but not too cryptic\n• Don\'t directly mention your word\n• Try to relate your word to common concepts\n• Keep descriptions short and simple',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildPhaseControls() {
      return Column(
        children: [
          PrimaryButton(
            text: 'Start Discussion',
            onPressed: _navigateToDiscussion,
          ),
        ],
      );
    }
  }
