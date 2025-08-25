import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/localization_service.dart';
import '../../data/models/game_session.dart';
import '../../data/models/player.dart';
import '../../data/repositories/game_service.dart';
import '../widgets/buttons/primary_button.dart';

class DiscussionPhaseScreen extends StatefulWidget {
  final GameSession gameSession;

  const DiscussionPhaseScreen({
    super.key,
    required this.gameSession,
  });

  @override
  State<DiscussionPhaseScreen> createState() => _DiscussionPhaseScreenState();
}

class _DiscussionPhaseScreenState extends State<DiscussionPhaseScreen> {
  late GameSession _currentSession;
  final List<String> _phaseHistory = [];

  @override
  void initState() {
    super.initState();
    _currentSession = widget.gameSession;
    _addToHistory(LocalizationService().translate('discussion_phase_started'));
  }

  void _addToHistory(String event) {
    final timestamp = DateTime.now();
    final timeString = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    _phaseHistory.add('[$timeString] $event');
  }

  void _navigateToVoting() {
    // Update the session to move to voting phase
    final gameService = GameService.instance;
    gameService.nextPhase(GamePhase.voting);
    
    Navigator.of(context).pushReplacementNamed(
      Routes.voting,
      arguments: gameService.currentSession,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService().translate('discussion_phase_app_bar')),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            tooltip: LocalizationService().translate('discussion_phase_home_tooltip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildPlayerList(),
                      const SizedBox(height: 16),
                      _buildDiscussionInfoCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              PrimaryButton(
                text: LocalizationService().translate('discussion_phase_call_vote'),
                onPressed: _navigateToVoting,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscussionInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.forum,
              size: 48,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 12),
            Text(
              LocalizationService().translate('discussion_phase_title'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              LocalizationService().translate('discussion_phase_instructions'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService().translate('discussion_phase_tips'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LocalizationService().translate('discussion_phase_tip_list'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerList() {
    return Card(
      child: IntrinsicWidth( // Makes card width match content but allows expansion
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill width
            children: [
              Text(
                LocalizationService().translate('discussion_phase_players_count', placeholders: {
                  'count': _currentSession.activePlayers.length.toString()
                }),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentSession.players.map((player) {
                  final isActive = !player.isEliminated;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Role indicator icon
                        _getPlayerRoleIcon(player),
                        const SizedBox(width: 8),
                        Text(
                          player.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? Colors.green
                                : Colors.grey,
                            decoration: isActive
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                        if (!isActive) ...[
                          const SizedBox(width: 6),
                          _getEliminatedPlayerRoleIndicator(player),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPlayerRoleIcon(Player player) {
    return Icon(
      Icons.person,
      size: 16,
      color: !player.isEliminated ? Colors.green : Colors.grey,
    );
  }

  Widget _getEliminatedPlayerRoleIndicator(Player player) {
    // Define colors for each role
    Color roleColor = Colors.grey;
    IconData roleIcon = Icons.help_outline;
    
    switch (player.role) {
      case PlayerRole.civilian:
        roleColor = Colors.blue;
        roleIcon = Icons.people;
        break;
      case PlayerRole.undercover:
        roleColor = Colors.red;
        roleIcon = Icons.person_search;
        break;
      case PlayerRole.mrWhite:
        roleColor = Colors.purple;
        roleIcon = Icons.psychology;
        break;
    }
    
    return Icon(
      roleIcon,
      size: 14,
      color: roleColor,
    );
  }
}