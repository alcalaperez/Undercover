import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/utils/localization_service.dart';
import '../../core/utils/audio_service.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/buttons/secondary_button.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final PageController _pageController = PageController();
  final AudioService _audioService = AudioService();
  int _currentIndex = 0;
  
  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      titleKey: 'tutorial_welcome_title',
      descriptionKey: 'tutorial_welcome_description',
      icon: Icons.waving_hand,
      color: Colors.blue,
    ),
    TutorialStep(
      titleKey: 'tutorial_objective_title',
      descriptionKey: 'tutorial_objective_description',
      icon: Icons.flag,
      color: Colors.green,
    ),
    TutorialStep(
      titleKey: 'tutorial_roles_title',
      descriptionKey: 'tutorial_roles_description',
      icon: Icons.people,
      color: Colors.orange,
    ),
    TutorialStep(
      titleKey: 'tutorial_phases_title',
      descriptionKey: 'tutorial_phases_description',
      icon: Icons.timeline,
      color: Colors.purple,
    ),
    TutorialStep(
      titleKey: 'tutorial_voting_title',
      descriptionKey: 'tutorial_voting_description',
      icon: Icons.how_to_vote,
      color: Colors.red,
    ),
    TutorialStep(
      titleKey: 'tutorial_mr_white_title',
      descriptionKey: 'tutorial_mr_white_description',
      icon: Icons.lightbulb,
      color: Colors.amber,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    _audioService.buttonFeedback();
    if (_currentIndex < _tutorialSteps.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishTutorial();
    }
  }

  void _previousStep() {
    _audioService.buttonFeedback();
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipTutorial() {
    _audioService.buttonFeedback();
    Navigator.pop(context);
  }

  void _finishTutorial() {
    _audioService.buttonFeedback();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(localization.tutorial),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _skipTutorial,
            child: Text(
              localization.skip,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: List.generate(_tutorialSteps.length, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(
                      right: index < _tutorialSteps.length - 1 ? 8 : 0,
                    ),
                    decoration: BoxDecoration(
                      color: index <= _currentIndex
                          ? const Color(0xFF6366F1)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          
          // Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _tutorialSteps.length,
              itemBuilder: (context, index) {
                final step = _tutorialSteps[index];
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: step.color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step.icon,
                          size: 60,
                          color: step.color,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Title
                      Text(
                        localization.translate(step.titleKey),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        localization.translate(step.descriptionKey),
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFF1E293B).withOpacity(0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      
                      // Role examples for roles step
                      if (step.titleKey == 'tutorial_roles_title')
                        _buildRoleExamples(localization),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Previous button
                if (_currentIndex > 0)
                  Expanded(
                    child: SecondaryButton(
                      text: localization.previous,
                      onPressed: _previousStep,
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 16),
                
                // Next/Finish button
                Expanded(
                  child: PrimaryButton(
                    text: _currentIndex == _tutorialSteps.length - 1
                        ? localization.finish
                        : localization.next,
                    onPressed: _nextStep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleExamples(LocalizationService localization) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildRoleCard(
            localization.civilian,
            'Word: Apple',
            Colors.green,
            Icons.person,
          ),
          const SizedBox(height: 8),
          _buildRoleCard(
            localization.undercover,
            'Word: Orange',
            Colors.orange,
            Icons.person_outline,
          ),
          const SizedBox(height: 8),
          _buildRoleCard(
            localization.mrWhite,
            'Word: ???',
            Colors.grey,
            Icons.help_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(String role, String word, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            '$role: $word',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialStep {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;

  const TutorialStep({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
  });
}