import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/animations.dart';
import '../../../core/constants/enums.dart';
import '../../../data/models/player.dart';
import '../selectors/avatar_selector.dart';

class PlayerCard extends StatefulWidget {
  final Player player;
  final bool isSelected;
  final bool isCurrentPlayer;
  final bool showRole;
  final bool showWord;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PlayerCard({
    super.key,
    required this.player,
    this.isSelected = false,
    this.isCurrentPlayer = false,
    this.showRole = false,
    this.showWord = false,
    this.onTap,
    this.trailing,
  });

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: AppAnimations.scaleNormal,
      end: AppAnimations.scaleMin,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppAnimations.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getRoleColor() {
    if (widget.player.isEliminated) {
      return AppColors.eliminated;
    }
    
    switch (widget.player.role) {
      case PlayerRole.civilian:
        return AppColors.civilian;
      case PlayerRole.undercover:
        return AppColors.undercover;
      case PlayerRole.mrWhite:
        return AppColors.mrWhite;
    }
  }

  String _getRoleText() {
    switch (widget.player.role) {
      case PlayerRole.civilian:
        return 'Civilian';
      case PlayerRole.undercover:
        return 'Undercover';
      case PlayerRole.mrWhite:
        return 'Mr. White';
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roleColor = _getRoleColor();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: AppAnimations.medium,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected 
                      ? AppColors.primary
                      : widget.isCurrentPlayer
                          ? AppColors.secondary
                          : Colors.transparent,
                  width: widget.isSelected || widget.isCurrentPlayer ? 2 : 0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: roleColor,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              AvatarSelector.getAvatarEmoji(int.tryParse(widget.player.avatarIndex) ?? 0),
                              style: const TextStyle(
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Player info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.player.name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: widget.player.isEliminated
                                            ? theme.disabledColor
                                            : null,
                                        decoration: widget.player.isEliminated
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (widget.player.isEliminated)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.eliminated.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Eliminated',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.eliminated,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              
                              if (widget.showRole) ...[
                                const SizedBox(height: 4),
                                Text(
                                  _getRoleText(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: roleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              
                              if (widget.showWord && widget.player.assignedWord.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.player.assignedWord,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                              
                              if (widget.player.votesReceived > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.how_to_vote,
                                      size: 16,
                                      color: AppColors.danger,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.player.votesReceived} votes',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        if (widget.trailing != null) ...[
                          const SizedBox(width: 8),
                          widget.trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}