import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/utils/localization_service.dart';
import '../../core/utils/audio_service.dart';

class StrategyTipsScreen extends StatefulWidget {
  const StrategyTipsScreen({super.key});

  @override
  State<StrategyTipsScreen> createState() => _StrategyTipsScreenState();
}

class _StrategyTipsScreenState extends State<StrategyTipsScreen>
    with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<StrategyTip> _tips = [
    StrategyTip(
      titleKey: 'General Tips',
      contentKey: 'strategy_tip_1',
      icon: Icons.lightbulb,
      color: Colors.amber,
    ),
    StrategyTip(
      titleKey: 'Observation',
      contentKey: 'strategy_tip_2',
      icon: Icons.visibility,
      color: Colors.blue,
    ),
    StrategyTip(
      titleKey: 'Undercover Strategy',
      contentKey: 'strategy_tip_3',
      icon: Icons.masks,
      color: Colors.orange,
    ),
    StrategyTip(
      titleKey: 'Mr. White Strategy',
      contentKey: 'strategy_tip_4',
      icon: Icons.help_outline,
      color: Colors.grey,
    ),
    StrategyTip(
      titleKey: 'Civilian Strategy',
      contentKey: 'strategy_tip_5',
      icon: Icons.group,
      color: Colors.green,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(localization.translate('strategy_tips_title')),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1),
                      const Color(0xFF6366F1).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.psychology,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localization.translate('strategy_tips_title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Master the art of deception and deduction',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Strategy Tips
              ...List.generate(_tips.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < _tips.length - 1 ? 16 : 0,
                  ),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.3 + (index * 0.1)),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        index * 0.1,
                        1.0,
                        curve: Curves.easeOut,
                      ),
                    )),
                    child: _buildStrategyTipCard(_tips[index], localization),
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Role-specific strategies
              _buildRoleStrategiesCard(localization),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyTipCard(StrategyTip tip, LocalizationService localization) {
    return GestureDetector(
      onTap: () => _audioService.lightVibration(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: tip.color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: tip.color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tip.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    tip.icon,
                    color: tip.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    tip.titleKey,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tip.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              localization.translate(tip.contentKey),
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF1E293B).withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleStrategiesCard(LocalizationService localization) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people_alt,
                  color: const Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Role-Specific Strategies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildRoleStrategy(
            role: localization.civilian,
            strategies: [
              'Work together to identify suspicious behavior',
              'Share information but be careful not to help enemies',
              'Vote strategically to eliminate threats',
              'Pay attention to vague or contradictory descriptions',
            ],
            color: Colors.green,
            icon: Icons.shield,
          ),
          const SizedBox(height: 16),
          
          _buildRoleStrategy(
            role: localization.undercover,
            strategies: [
              'Blend in with civilian descriptions',
              'Use context clues from others to learn the real word',
              'Be specific enough to seem legitimate',
              'Coordinate with other undercovers subtly',
            ],
            color: Colors.orange,
            icon: Icons.masks,
          ),
          const SizedBox(height: 16),
          
          _buildRoleStrategy(
            role: localization.mrWhite,
            strategies: [
              'Stay quiet and let others reveal information',
              'Ask clarifying questions without being obvious',
              'Make educated guesses based on category hints',
              'Save your guess for when you have the most information',
            ],
            color: Colors.grey,
            icon: Icons.help_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleStrategy({
    required String role,
    required List<String> strategies,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                role,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...strategies.map((strategy) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strategy,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF1E293B).withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class StrategyTip {
  final String titleKey;
  final String contentKey;
  final IconData icon;
  final Color color;

  const StrategyTip({
    required this.titleKey,
    required this.contentKey,
    required this.icon,
    required this.color,
  });
}