import '../../core/constants/enums.dart';

class Player {
  final String id;
  final String name;
  final String avatarIndex;
  PlayerRole role;
  String assignedWord;
  bool isEliminated;
  int votesReceived;

  Player({
    required this.id,
    required this.name,
    required this.avatarIndex,
    this.role = PlayerRole.civilian,
    this.assignedWord = '',
    this.isEliminated = false,
    this.votesReceived = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarIndex': avatarIndex,
      'role': role.name,
      'assignedWord': assignedWord,
      'isEliminated': isEliminated,
      'votesReceived': votesReceived,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      avatarIndex: json['avatarIndex'],
      role: PlayerRole.values.firstWhere((e) => e.name == json['role']),
      assignedWord: json['assignedWord'] ?? '',
      isEliminated: json['isEliminated'] ?? false,
      votesReceived: json['votesReceived'] ?? 0,
    );
  }

  Player copyWith({
    String? id,
    String? name,
    String? avatarIndex,
    PlayerRole? role,
    String? assignedWord,
    bool? isEliminated,
    int? votesReceived,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      role: role ?? this.role,
      assignedWord: assignedWord ?? this.assignedWord,
      isEliminated: isEliminated ?? this.isEliminated,
      votesReceived: votesReceived ?? this.votesReceived,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Player{id: $id, name: $name, role: $role, isEliminated: $isEliminated}';
  }
}