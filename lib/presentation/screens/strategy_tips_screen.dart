import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/utils/localization_service.dart';

class StrategyTipsScreen extends StatefulWidget {
  const StrategyTipsScreen({super.key});

  @override
  State<StrategyTipsScreen> createState() => _StrategyTipsScreenState();
}

class _StrategyTipsScreenState extends State<StrategyTipsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<StrategyTip> _tips = [
    StrategyTip(
      icon: Icons.lightbulb,
      color: const Color(0xFFFFD700),
      titleKey: 'strategy_tip_1',
      contentKey: 'strategy_tip_1',
    ),
    StrategyTip(
      icon: Icons.hearing,
      color: const Color(0xFF4A90E2),
      titleKey: 'strategy_tip_2',
      contentKey: 'strategy_tip_2',
    ),
    StrategyTip(
      icon: Icons.shield,
      color: const Color(0xFF50C878),
      titleKey: 'strategy_tip_3',
      contentKey: 'strategy_tip_3',
    ),
    StrategyTip(
      icon: Icons.visibility,
      color: const Color(0xFF9370DB),
      titleKey: 'strategy_tip_4',
      contentKey: 'strategy_tip_4',
    ),
    StrategyTip(
      icon: Icons.group,
      color: const Color(0xFFFF6347),
      titleKey: 'strategy_tip_5',
      contentKey: 'strategy_tip_5',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
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
        title: Text(localization.strategy_tips_title),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.strategy_tips_title,
                style: AppTextStyles.h2.copyWith(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Master the art of deception and detection',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),
              ..._tips.map((tip) => Column(
                children: [
                  _buildStrategyTipCard(tip, localization),
                  const SizedBox(height: 20),
                ],
              )).toList(),
              _buildRoleStrategiesCard(localization),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStrategyTipCard(StrategyTip tip, LocalizationService localization) {
    return Container(
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
                  localization.translate(tip.titleKey),
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
                child: const Icon(
                  Icons.groups,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Role-Specific Strategies',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRoleStrategyItem(
            localization.civilian,
            localization.translate('strategy_tip_5'),
            const Color(0xFF50C878),
          ),
          const SizedBox(height: 12),
          _buildRoleStrategyItem(
            localization.undercover,
            localization.translate('strategy_tip_3'),
            const Color(0xFFFF6347),
          ),
          const SizedBox(height: 12),
          _buildRoleStrategyItem(
            localization.mrWhite,
            localization.translate('strategy_tip_4'),
            const Color(0xFF9370DB),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleStrategyItem(String role, String strategy, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strategy,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StrategyTip {
  final IconData icon;
  final Color color;
  final String titleKey;
  final String contentKey;

  StrategyTip({
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.contentKey,
  });
}