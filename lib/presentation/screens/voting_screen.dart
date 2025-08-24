import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/themes/app_theme.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../data/models/game_session.dart';
import '../../data/models/player.dart';
import '../../data/repositories/game_service.dart';
import '../widgets/buttons/primary_button.dart';

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
  bool _showingResults = false;
  
  late AnimationController _selectionController;
  late AnimationController _resultController;
  late Animation<double> _selectionAnimation;
  late Animation<double> _resultAnimation;
  
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
    _resultController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    );
    
    _resultAnimation = CurvedAnimation(
      parent: _resultController,
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
      _selectedPlayer = player;
    });
    
    _selectionController.forward().then((_) {
      _selectionController.reverse();
    });
    
    HapticFeedback.mediumImpact();
    _addToHistory('Selected ${player.name} for voting');
  }

  void _confirmVote() {
    if (_selectedPlayer == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildVoteConfirmationDialog(),
    );
  }

  Widget _buildVoteConfirmationDialog() {
    return AlertDialog(
      title: const Text('Confirm Vote'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.how_to_vote,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Are you sure you want to vote to eliminate:',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.danger),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedPlayer!.avatarIndex,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedPlayer!.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This action cannot be undone!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.danger,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _submitVote();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm Vote'),
        ),
      ],
    );
  }

  void _submitVote() {
    if (_selectedPlayer == null) return;
    
    try {
      final gameService = GameService.instance;
      // For now, use first active player as voter - in full implementation,
      // this would be the current voting player in turn-based voting
      final activePlayer = _currentSession.activePlayers.first;
      gameService.addVote(activePlayer.id, _selectedPlayer!.id);
      
      setState(() {
        _isVotingComplete = true;
      });
      
      _addToHistory('Vote cast for ${_selectedPlayer!.name}');
      HapticFeedback.heavyImpact();
      
      // Show voting complete message
      _showVotingCompleteDialog();
      
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showVotingCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Vote Submitted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 48,
              color: AppColors.success,
            ),
            const SizedBox(height: 16),
            Text(
              'Your vote has been recorded.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pass the phone to the next player or proceed to see results.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _proceedToResults();
            },
            child: const Text('See Results'),
          ),
        ],
      ),
    );
  }

  void _proceedToResults() {
    setState(() {
      _showingResults = true;
    });
    
    _resultController.forward();
    _addToHistory('Proceeding to vote results');
    
    // For now, navigate to result screen - in full implementation,
    // this would show the vote counting and elimination process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(
        Routes.result,
        arguments: _currentSession,
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
        color: AppColors.primary.withOpacity(0.1),
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
                Icons.how_to_vote,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voting Phase',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Select who you want to eliminate',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedPlayer != null) ...[
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _selectionAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_selectionAnimation.value * 0.05),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedPlayer!.avatarIndex,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selected: ${_selectedPlayer!.name}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
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
        final isSelected = _selectedPlayer?.id == player.id;
        
        return GestureDetector(
          onTap: () => _selectPlayer(player),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.1)
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
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
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
                    child: Text(
                      player.avatarIndex,
                      style: TextStyle(
                        fontSize: 24,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
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

  Widget _buildResultsView() {
    return AnimatedBuilder(
      animation: _resultAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _resultAnimation.value,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Counting Votes...',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Please wait while we tally the results',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

  @override
  Widget build(BuildContext context) {
    if (_showingResults) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildResultsView(),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting'),
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
              _buildVotingHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Who do you think is the Undercover or Mr. White?',
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
                      ? 'Select a Player to Vote'
                      : 'Vote to Eliminate ${_selectedPlayer!.name}',
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