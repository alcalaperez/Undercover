import '../../core/constants/enums.dart';

class WordPair {
  final String civilianWord;
  final String undercoverWord;
  final String category;
  final DifficultyLevel difficulty;

  WordPair({
    required this.civilianWord,
    required this.undercoverWord,
    required this.category,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() {
    return {
      'civilianWord': civilianWord,
      'undercoverWord': undercoverWord,
      'category': category,
      'difficulty': difficulty.name,
    };
  }

  factory WordPair.fromJson(Map<String, dynamic> json) {
    return WordPair(
      civilianWord: json['civilianWord'],
      undercoverWord: json['undercoverWord'],
      category: json['category'],
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WordPair &&
        other.civilianWord == civilianWord &&
        other.undercoverWord == undercoverWord &&
        other.category == category &&
        other.difficulty == difficulty;
  }

  @override
  int get hashCode {
    return civilianWord.hashCode ^
        undercoverWord.hashCode ^
        category.hashCode ^
        difficulty.hashCode;
  }

  @override
  String toString() {
    return 'WordPair{civilianWord: $civilianWord, undercoverWord: $undercoverWord, category: $category, difficulty: $difficulty}';
  }
}