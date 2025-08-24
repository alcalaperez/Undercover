import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/constants/animations.dart';
import '../../core/utils/routes.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToGameSetup() {
    Navigator.of(context).pushNamed(Routes.gameSetup);
  }

  void _navigateToTutorial() {
    Navigator.of(context).pushNamed(Routes.tutorial);
  }

  void _navigateToSettings() {
    Navigator.of(context).pushNamed(Routes.settings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.primary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Header section
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.theater_comedy,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Title
                              Text(
                                'UNDERCOVER',
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.primary,
                                  fontSize: size.width > 600 ? 40 : 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'The Ultimate Party Game',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        // Menu buttons section
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  text: 'New Game',
                                  icon: Icons.play_arrow,
                                  onPressed: _navigateToGameSetup,
                                ),
                              ),

                              const SizedBox(height: 16),

                              SizedBox(
                                width: double.infinity,
                                child: SecondaryButton(
                                  text: 'Tutorial',
                                  icon: Icons.school,
                                  onPressed: _navigateToTutorial,
                                ),
                              ),

                              const SizedBox(height: 16),

                              SizedBox(
                                width: double.infinity,
                                child: SecondaryButton(
                                  text: 'Settings',
                                  icon: Icons.settings,
                                  onPressed: _navigateToSettings,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Footer section
                        Expanded(
                          flex: 1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Version 1.0.0',
                                style: AppTextStyles.caption.copyWith(
                                  color: theme.colorScheme.onBackground.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '4-20 Players • Offline Play',
                                style: AppTextStyles.caption.copyWith(
                                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}