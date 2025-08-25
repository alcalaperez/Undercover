import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/routes.dart';
import '../../core/utils/preferences_service.dart';
import '../../core/utils/localization_service.dart';
import '../../data/models/player.dart';
import '../../data/models/game_settings.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';
import '../widgets/buttons/icon_button_custom.dart';
import '../widgets/cards/player_card.dart';
import '../widgets/dialogs/quick_name_suggestions_dialog.dart';
import '../widgets/selectors/avatar_selector.dart';
import '../widgets/selectors/category_selector.dart';

class EnhancedGameSetupScreen extends StatefulWidget {
  const EnhancedGameSetupScreen({super.key});

  @override
  State<EnhancedGameSetupScreen> createState() => _EnhancedGameSetupScreenState();
}

class _EnhancedGameSetupScreenState extends State<EnhancedGameSetupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Player> _players = [];
  GameSettings _settings = GameSettings.defaultSettings();
  
  final TextEditingController _nameController = TextEditingController();
  int _selectedAvatarIndex = 0;
  bool _isStartingGame = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    await PreferencesService.instance.initialize();
    _loadSavedSettings();
    _loadSavedPlayers();
    setState(() {
      _isInitialized = true;
    });
  }

  void _loadSavedSettings() {
    final savedSettings = PreferencesService.instance.getGameSettings();
    setState(() {
      _settings = savedSettings;
    });
  }

  void _loadSavedPlayers() {
    final lastPlayers = PreferencesService.instance.getLastPlayers();
    if (lastPlayers.isNotEmpty) {
      setState(() {
        _players = lastPlayers.take(20).toList(); // Max 20 players
      });
    } else {
      _addInitialPlayers();
    }
  }

  void _addInitialPlayers() {
    for (int i = 0; i < 4; i++) {
      _addPlayer('Player ${i + 1}', i);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool _isNameValid(String name) {
    if (name.trim().isEmpty) return false;
    return !_players.any((player) => 
        player.name.toLowerCase() == name.trim().toLowerCase());
  }

  void _addPlayer(String name, int avatarIndex) {
    if (_players.length < 20 && _isNameValid(name)) {
      final usedAvatars = _players.map((p) => int.tryParse(p.avatarIndex) ?? 0).toList();
      
      // Find next available avatar if the selected one is taken
      int finalAvatarIndex = avatarIndex;
      while (usedAvatars.contains(finalAvatarIndex) && finalAvatarIndex < 20) {
        finalAvatarIndex++;
      }
      if (finalAvatarIndex >= 20) {
        finalAvatarIndex = 0;
        while (usedAvatars.contains(finalAvatarIndex) && finalAvatarIndex < 20) {
          finalAvatarIndex++;
        }
      }

      setState(() {
        _players.add(Player(
          id: '${DateTime.now().millisecondsSinceEpoch}_${_players.length}',
          name: name.trim(),
          avatarIndex: finalAvatarIndex.toString(),
        ));
      });

      // Save name to quick suggestions
      PreferencesService.instance.addQuickName(name.trim());
    }
  }

  void _removePlayer(int index) {
    if (_players.length > 4) {
      setState(() {
        _players.removeAt(index);
      });
    }
  }

  void _editPlayer(int index) {
    final player = _players[index];
    _nameController.text = player.name;
    _selectedAvatarIndex = int.tryParse(player.avatarIndex) ?? 0;
    
    _showPlayerDialog(isEdit: true, editIndex: index);
  }

  void _showPlayerDialog({bool isEdit = false, int? editIndex}) {
    if (!isEdit) {
      _nameController.clear();
      _selectedAvatarIndex = _getNextAvailableAvatar();
    }

    final localization = LocalizationService();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit 
                            ? localization.translate('game_setup_enhanced_edit_dialog_title') 
                            : localization.translate('game_setup_enhanced_add_dialog_title'),
                        style: AppTextStyles.h3,
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Scrollable content
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Name input with quick suggestions
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: localization.translate('game_setup_enhanced_player_name_label'),
                                    hintText: localization.translate('game_setup_enhanced_player_name_hint'),
                                    errorText: _nameController.text.isNotEmpty && 
                                               !_isNameValid(_nameController.text) 
                                        ? _getNameLocalizedError(_nameController.text, localization)
                                        : null,
                                  ),
                                  autofocus: !isEdit,
                                  onChanged: (value) => setDialogState(() {}),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () => _showQuickNameSuggestions(setDialogState),
                                icon: const Icon(Icons.lightbulb_outline),
                                tooltip: localization.translate('game_setup_enhanced_quick_names_tooltip'),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Avatar selection
                          AvatarSelector(
                            selectedAvatarIndex: _selectedAvatarIndex,
                            onAvatarSelected: (index) {
                              setDialogState(() {
                                _selectedAvatarIndex = index;
                              });
                            },
                            unavailableAvatars: isEdit 
                                ? _players.where((p) => p != _players[editIndex!])
                                         .map((p) => int.tryParse(p.avatarIndex) ?? 0)
                                         .toList()
                                : _players.map((p) => int.tryParse(p.avatarIndex) ?? 0)
                                         .toList(),
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  
                  // Actions (always visible at bottom)
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          text: localization.translate('game_setup_enhanced_cancel_button'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton(
                          text: isEdit 
                              ? localization.translate('game_setup_enhanced_update_button') 
                              : localization.translate('game_setup_enhanced_add_button'),
                          onPressed: _nameController.text.isNotEmpty && 
                                    _isNameValid(_nameController.text)
                              ? () {
                                  if (isEdit && editIndex != null) {
                                    setState(() {
                                      _players[editIndex] = _players[editIndex].copyWith(
                                        name: _nameController.text.trim(),
                                        avatarIndex: _selectedAvatarIndex.toString(),
                                      );
                                    });
                                  } else {
                                    _addPlayer(_nameController.text.trim(), _selectedAvatarIndex);
                                  }
                                  Navigator.of(context).pop();
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickNameSuggestions(StateSetter setDialogState) {
    showDialog(
      context: context,
      builder: (context) => QuickNameSuggestionsDialog(
        onNameSelected: (name) {
          _nameController.text = name;
          setDialogState(() {});
        },
        existingNames: _players.map((p) => p.name).toList(),
      ),
    );
  }

  String _getNameLocalizedError(String name, LocalizationService localization) {
    if (name.trim().isEmpty) return localization.translate('game_setup_enhanced_name_empty_error');
    if (_players.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      return localization.translate('game_setup_enhanced_name_exists_error');
    }
    return '';
  }

  int _getNextAvailableAvatar() {
    final usedAvatars = _players.map((p) => int.tryParse(p.avatarIndex) ?? 0).toList();
    for (int i = 0; i < 20; i++) {
      if (!usedAvatars.contains(i)) return i;
    }
    return 0;
  }

  Future<void> _saveSettings() async {
    await PreferencesService.instance.saveGameSettings(_settings);
    await PreferencesService.instance.saveLastPlayers(_players);
  }

  void _startGame() async {
    if (_isStartingGame) return;
    
    setState(() {
      _isStartingGame = true;
    });

    await _saveSettings();

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
    final localization = LocalizationService();
    
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.translate('game_setup_enhanced_players_count', placeholders: {'count': _players.length.toString()}),
                    style: AppTextStyles.h3,
                  ),
                  Text(
                    localization.translate('game_setup_enhanced_players_requirement'),
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButtonCustom(
                    icon: Icons.shuffle,
                    onPressed: _shufflePlayers,
                    tooltip: localization.translate('game_setup_enhanced_shuffle_tooltip'),
                    size: 40,
                  ),
                  const SizedBox(width: 8),
                  IconButtonCustom(
                    icon: Icons.add,
                    onPressed: _players.length < 20 ? () => _showPlayerDialog() : null,
                    tooltip: localization.translate('game_setup_enhanced_add_player_tooltip'),
                  ),
                ],
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: AppColors.primary,
                      onPressed: () => _editPlayer(index),
                      tooltip: localization.translate('game_setup_enhanced_edit_player_tooltip'),
                    ),
                    if (_players.length > 4)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        color: AppColors.danger,
                        onPressed: () => _removePlayer(index),
                        tooltip: localization.translate('game_setup_enhanced_remove_player_tooltip'),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _shufflePlayers() {
    setState(() {
      _players.shuffle();
    });
  }

  Widget _buildSettingsTab() {
    final localization = LocalizationService();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.translate('game_setup_enhanced_configuration_title'),
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 24),

          // Roles Configuration
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.translate('game_setup_enhanced_roles_title'),
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Undercover Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localization.translate('game_setup_enhanced_undercover_count'),
                        style: AppTextStyles.bodyMedium,
                      ),
                      DropdownButton<int>(
                        value: _settings.undercoverCount,
                        items: [1, 2, 3].map((count) {
                          return DropdownMenuItem(
                            value: count,
                            child: Text('$count'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _settings = _settings.copyWith(undercoverCount: value);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mr. White Toggle
                  SwitchListTile(
                    title: Text(localization.translate('game_setup_enhanced_include_mr_white')),
                    subtitle: Text(localization.translate('game_setup_enhanced_mr_white_description')),
                    value: _settings.includeMrWhite,
                    onChanged: (value) {
                      setState(() {
                        _settings = _settings.copyWith(includeMrWhite: value);
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  // Mr. White First Draw Setting
                  if (_settings.includeMrWhite)
                    SwitchListTile(
                      title: Text(localization.translate('game_setup_enhanced_prevent_mr_white_first')),
                      subtitle: Text(localization.translate('game_setup_enhanced_mr_white_first_description')),
                      value: _settings.mrWhiteFirstDraw,
                      onChanged: (value) {
                        setState(() {
                          _settings = _settings.copyWith(mrWhiteFirstDraw: value);
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Timer Configuration
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.translate('game_setup_enhanced_timer_settings'),
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  Column(
                    children: [30, 60, 90, 0].map((seconds) {
                      return RadioListTile<int>(
                        title: Text(seconds == 0 
                            ? localization.translate('game_setup_enhanced_no_timer') 
                            : localization.translate('game_setup_enhanced_timer_seconds', placeholders: {'seconds': seconds.toString()})),
                        value: seconds,
                        groupValue: _settings.descriptionTimeLimit,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _settings = _settings.copyWith(descriptionTimeLimit: value);
                            });
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Word Configuration
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localization.translate('game_setup_enhanced_word_configuration'),
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 16),
                  
                  // Difficulty
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localization.translate('game_setup_enhanced_difficulty_level'),
                        style: AppTextStyles.bodyMedium,
                      ),
                      DropdownButton<DifficultyLevel>(
                        value: _settings.wordDifficulty,
                        items: DifficultyLevel.values.map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(difficulty.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _settings = _settings.copyWith(wordDifficulty: value);
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Category Selection
                  CategorySelector(
                    selectedCategories: _settings.selectedCategories,
                    onSelectionChanged: (categories) {
                      setState(() {
                        _settings = _settings.copyWith(selectedCategories: categories);
                      });
                    },
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
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final localization = LocalizationService();

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('game_setup_enhanced_title')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.people), 
              text: localization.translate('game_setup_enhanced_players_tab'),
            ),
            Tab(
              icon: const Icon(Icons.settings), 
              text: localization.translate('game_setup_enhanced_settings_tab'),
            ),
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
                flex: 7,
                child: SecondaryButton(
                  text: localization.translate('game_setup_enhanced_cancel_button'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 10,
                child: PrimaryButton(
                  text: localization.translate('game_setup_enhanced_start_game'),
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