import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/preferences_service.dart';
import '../../data/models/player.dart';
import '../../data/models/game_settings.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/buttons/icon_button_custom.dart';
import '../widgets/cards/player_card.dart';
import '../widgets/dialogs/quick_name_suggestions_dialog.dart';
import '../widgets/selectors/avatar_selector.dart';
import '../widgets/selectors/category_selector.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Player> _players = [];
  GameSettings _settings = GameSettings.defaultSettings();
  
  final TextEditingController _nameController = TextEditingController();
  int _selectedAvatarIndex = 0;
  bool _isStartingGame = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _addInitialPlayers();
  }

  void _addInitialPlayers() {
    // Add 4 default players
    for (int i = 0; i < 4; i++) {
      _addPlayer('Player ${i + 1}', i.toString());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer(String name, String avatarIndex) {
    if (_players.length < 20) {
      setState(() {
        _players.add(Player(
          id: '${DateTime.now().millisecondsSinceEpoch}_${_players.length}',
          name: name,
          avatarIndex: avatarIndex,
        ));
      });
    }
  }

  void _removePlayer(int index) {
    if (_players.length > 4) {
      setState(() {
        _players.removeAt(index);
      });
    }
  }

  void _showAddPlayerDialog() {
    _nameController.clear();
    _selectedAvatarIndex = _players.length % 10;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Player'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Player Name',
                  hintText: 'Enter player name',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Avatar:'),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          _selectedAvatarIndex = index;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _selectedAvatarIndex == index
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: _selectedAvatarIndex == index
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            index.toString(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _selectedAvatarIndex == index
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_nameController.text.trim().isNotEmpty) {
                  _addPlayer(_nameController.text.trim(), _selectedAvatarIndex.toString());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame() async {
    if (_isStartingGame) return;
    
    setState(() {
      _isStartingGame = true;
    });

    // Navigate to role reveal screen with players and settings
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      Navigator.of(context).pushNamed(
        Routes.roleReveal,
        arguments: {
          'players': _players,
          'settings': _settings,
        },
      );
    }

    setState(() {
      _isStartingGame = false;
    });
  }

  Widget _buildPlayersTab() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Players (${_players.length})',
                style: AppTextStyles.h3,
              ),
              IconButtonCustom(
                icon: Icons.add,
                onPressed: _players.length < 20 ? _showAddPlayerDialog : null,
                tooltip: 'Add Player',
              ),
            ],
          ),
        ),

        // Players list
        Expanded(
          child: ListView.builder(
            itemCount: _players.length,
            itemBuilder: (context, index) {
              return PlayerCard(
                player: _players[index],
                trailing: _players.length > 4
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.danger,
                        onPressed: () => _removePlayer(index),
                      )
                    : null,
              );
            },
          ),
        ),

        // Footer info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Text(
            '4-20 players required • Minimum 4 players to start',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Settings',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 24),

          // Undercover Count
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Number of Undercovers',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [1, 2, 3].map((count) {
                      return Expanded(
                        child: RadioListTile<int>(
                          title: Text('$count'),
                          value: count,
                          groupValue: _settings.undercoverCount,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _settings = _settings.copyWith(undercoverCount: value);
                              });
                            }
                          },
                          dense: true,
                          toggleable: true,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Mr. White
          Card(
            child: SwitchListTile(
              title: const Text('Include Mr. White'),
              subtitle: const Text('Mr. White doesn\'t know any word'),
              value: _settings.includeMrWhite,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(includeMrWhite: value);
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Timer Setting
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description Timer',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: [30, 60, 90, 0].map((seconds) {
                      return RadioListTile<int>(
                        title: Text(seconds == 0 ? 'No Timer' : '${seconds}s'),
                        value: seconds,
                        groupValue: _settings.descriptionTimeLimit,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _settings = _settings.copyWith(descriptionTimeLimit: value);
                            });
                          }
                        },
                        dense: true,
                        toggleable: true,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Difficulty
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Word Difficulty',
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: DifficultyLevel.values.map((difficulty) {
                      return RadioListTile<DifficultyLevel>(
                        title: Text(difficulty.name.toUpperCase()),
                        value: difficulty,
                        groupValue: _settings.wordDifficulty,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _settings = _settings.copyWith(wordDifficulty: value);
                            });
                          }
                        },
                        dense: true,
                        toggleable: true,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Setup'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Players'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlayersTab(),
          _buildSettingsTab(),
        ],
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
                  text: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  text: 'Start Game',
                  isLoading: _isStartingGame,
                  onPressed: _players.length >= 4 ? _startGame : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}