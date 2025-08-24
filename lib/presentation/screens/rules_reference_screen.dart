import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';
import '../../core/utils/localization_service.dart';
import '../../core/utils/audio_service.dart';

class RulesReferenceScreen extends StatefulWidget {
  const RulesReferenceScreen({super.key});

  @override
  State<RulesReferenceScreen> createState() => _RulesReferenceScreenState();
}

class _RulesReferenceScreenState extends State<RulesReferenceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(localization.translate('rules_title')),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) => _audioService.buttonFeedback(),
          tabs: [
            Tab(
              icon: const Icon(Icons.settings),
              text: localization.translate('rules_setup'),
            ),
            Tab(
              icon: const Icon(Icons.play_arrow),
              text: localization.translate('rules_gameplay'),
            ),
            Tab(
              icon: const Icon(Icons.emoji_events),
              text: localization.translate('rules_winning'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSetupTab(localization),
          _buildGameplayTab(localization),
          _buildWinningTab(localization),
        ],
      ),
    );
  }

  Widget _buildSetupTab(LocalizationService localization) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            icon: Icons.group,
            title: localization.translate('rules_setup'),
            content: localization.translate('rules_setup_description'),
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          _buildRoleDistributionCard(localization),
          const SizedBox(height: 20),
          _buildCategoriesCard(localization),
        ],
      ),
    );
  }

  Widget _buildGameplayTab(LocalizationService localization) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            icon: Icons.play_circle,
            title: localization.translate('rules_gameplay'),
            content: localization.translate('rules_gameplay_description'),
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          _buildGamePhasesCard(localization),
          const SizedBox(height: 20),
          _buildVotingRulesCard(localization),
        ],
      ),
    );
  }

  Widget _buildWinningTab(LocalizationService localization) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            icon: Icons.flag,
            title: localization.translate('rules_winning'),
            content: localization.translate('rules_winning_description'),
            color: Colors.orange,
          ),
          const SizedBox(height: 20),
          _buildWinConditionsCard(localization),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
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

  Widget _buildRoleDistributionCard(LocalizationService localization) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Role Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildRoleDistribution(localization.civilian, '60-80%', Colors.green),
          const SizedBox(height: 8),
          _buildRoleDistribution(localization.undercover, '15-25%', Colors.orange),
          const SizedBox(height: 8),
          _buildRoleDistribution('${localization.mrWhite} (Optional)', '5-15%', Colors.grey),
        ],
      ),
    );
  }

  Widget _buildRoleDistribution(String role, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              role,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCard(LocalizationService localization) {
    final categories = [
      ('category_animals', Icons.pets),
      ('category_food', Icons.restaurant),
      ('category_objects', Icons.category),
      ('category_places', Icons.place),
      ('category_activities', Icons.sports),
      ('category_movies', Icons.movie),
      ('category_professions', Icons.work),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Word Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: categories.map((category) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.$2,
                      size: 16,
                      color: const Color(0xFF6366F1),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      localization.translate(category.$1),
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF6366F1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGamePhasesCard(LocalizationService localization) {
    final phases = [
      ('phase_word_reveal', Icons.visibility, Colors.blue),
      ('phase_description', Icons.chat, Colors.green),
      ('phase_discussion', Icons.group, Colors.orange),
      ('phase_voting', Icons.how_to_vote, Colors.red),
      ('phase_results', Icons.assessment, Colors.purple),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Game Phases',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ...phases.asMap().entries.map((entry) {
            final index = entry.key;
            final phase = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < phases.length - 1 ? 12 : 0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: phase.$3.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: phase.$3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(phase.$2, color: phase.$3, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localization.translate(phase.$1),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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

  Widget _buildVotingRulesCard(LocalizationService localization) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.how_to_vote, color: Colors.red, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Voting Rules',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildVotingRule('Majority wins', 'Player with most votes is eliminated'),
          const SizedBox(height: 8),
          _buildVotingRule('Tie votes', 'Vote again or random elimination'),
          const SizedBox(height: 8),
          _buildVotingRule('Self voting', 'Players cannot vote for themselves'),
        ],
      ),
    );
  }

  Widget _buildVotingRule(String rule, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rule,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF1E293B).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWinConditionsCard(LocalizationService localization) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Win Conditions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildWinCondition(
            localization.civilians_win,
            'Eliminate all Undercovers and Mr. White',
            Colors.green,
            Icons.shield,
          ),
          const SizedBox(height: 12),
          _buildWinCondition(
            localization.undercovers_win,
            'Survive until only 1 Civilian remains',
            Colors.orange,
            Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _buildWinCondition(
            localization.mr_white_wins,
            'Correctly guess the Civilian word when eliminated',
            Colors.grey,
            Icons.lightbulb_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildWinCondition(
    String title,
    String description,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF1E293B).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}