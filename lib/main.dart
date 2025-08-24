import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'core/utils/routes.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/main_menu_screen.dart';
import 'presentation/screens/enhanced_game_setup_screen.dart';
import 'presentation/screens/role_reveal_screen.dart';
import 'presentation/screens/game_play_screen.dart';
import 'presentation/screens/voting_screen.dart';
import 'presentation/screens/result_screen.dart';
import 'presentation/screens/how_to_play_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'data/models/player.dart';
import 'data/models/game_settings.dart';
import 'data/models/game_session.dart';

void main() {
  runApp(const UndercoverApp());
}

class UndercoverApp extends StatelessWidget {
  const UndercoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Undercover Game',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _createRoute(const SplashScreen());
        
      case Routes.mainMenu:
        return _createRoute(const MainMenuScreen());
        
      case Routes.gameSetup:
        return _createRoute(const EnhancedGameSetupScreen());
        
      case Routes.roleReveal:
        final args = settings.arguments as Map<String, dynamic>;
        return _createRoute(RoleRevealScreen(
          players: args['players'] as List<Player>,
          settings: args['settings'] as GameSettings,
        ));
        
      case Routes.gamePlay:
        final gameSession = settings.arguments as GameSession;
        return _createRoute(GamePlayScreen(gameSession: gameSession));
        
      case Routes.voting:
        final gameSession = settings.arguments as GameSession;
        return _createRoute(VotingScreen(gameSession: gameSession));
        
      case Routes.result:
        return _createRoute(const ResultScreen());
        
      case Routes.howToPlay:
        return _createRoute(const HowToPlayScreen());
        
      case Routes.settings:
        return _createRoute(const SettingsScreen());
        
      default:
        return _createRoute(const MainMenuScreen());
    }
  }

  PageRoute _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}