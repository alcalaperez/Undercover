enum PlayerRole {
  civilian,
  undercover,
  mrWhite,
}

enum GamePhase {
  setup,
  roleReveal,
  description,
  discussion,
  voting,
  elimination,
  gameEnd,
}

enum DifficultyLevel {
  easy,
  medium,
  hard,
}

enum GameResult {
  civiliansWin,
  undercoversWin,
  mrWhiteWins,
  draw,
}