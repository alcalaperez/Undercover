import '../../core/constants/enums.dart';

class GameSettings {
  final int undercoverCount;
  final bool includeMrWhite;
  final int descriptionTimeLimit;
  final DifficultyLevel wordDifficulty;
  final List<String> selectedCategories;
  final bool soundEffectsEnabled;
  final bool vibrationEnabled;
  final bool mrWhiteFirstDraw;

  GameSettings({
    required this.undercoverCount,
    required this.includeMrWhite,
    required this.descriptionTimeLimit,
    required this.wordDifficulty,
    required this.selectedCategories,
    this.soundEffectsEnabled = true,
    this.vibrationEnabled = true,
    this.mrWhiteFirstDraw = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'undercoverCount': undercoverCount,
      'includeMrWhite': includeMrWhite,
      'descriptionTimeLimit': descriptionTimeLimit,
      'wordDifficulty': wordDifficulty.name,
      'selectedCategories': selectedCategories,
      'soundEffectsEnabled': soundEffectsEnabled,
      'vibrationEnabled': vibrationEnabled,
      'mrWhiteFirstDraw': mrWhiteFirstDraw,
    };
  }

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(
      undercoverCount: json['undercoverCount'],
      includeMrWhite: json['includeMrWhite'],
      descriptionTimeLimit: json['descriptionTimeLimit'],
      wordDifficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['wordDifficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
      selectedCategories: List<String>.from(json['selectedCategories']),
      soundEffectsEnabled: json['soundEffectsEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      mrWhiteFirstDraw: json['mrWhiteFirstDraw'] ?? true,
    );
  }

  GameSettings copyWith({
    int? undercoverCount,
    bool? includeMrWhite,
    int? descriptionTimeLimit,
    DifficultyLevel? wordDifficulty,
    List<String>? selectedCategories,
    bool? soundEffectsEnabled,
    bool? vibrationEnabled,
    bool? mrWhiteFirstDraw,
  }) {
    return GameSettings(
      undercoverCount: undercoverCount ?? this.undercoverCount,
      includeMrWhite: includeMrWhite ?? this.includeMrWhite,
      descriptionTimeLimit: descriptionTimeLimit ?? this.descriptionTimeLimit,
      wordDifficulty: wordDifficulty ?? this.wordDifficulty,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      mrWhiteFirstDraw: mrWhiteFirstDraw ?? this.mrWhiteFirstDraw,
    );
  }

  factory GameSettings.defaultSettings() {
    return GameSettings(
      undercoverCount: 1,
      includeMrWhite: false,
      descriptionTimeLimit: 60,
      wordDifficulty: DifficultyLevel.medium,
      selectedCategories: ['Animals', 'Food', 'Objects'],
      soundEffectsEnabled: true,
      vibrationEnabled: true,
      mrWhiteFirstDraw: true,
    );
  }

  @override
  String toString() {
    return 'GameSettings{undercoverCount: $undercoverCount, includeMrWhite: $includeMrWhite, descriptionTimeLimit: $descriptionTimeLimit, wordDifficulty: $wordDifficulty}';
  }
}