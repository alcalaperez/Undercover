import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class AvatarSelector extends StatelessWidget {
  final int selectedAvatarIndex;
  final Function(int) onAvatarSelected;
  final List<int> unavailableAvatars;

  const AvatarSelector({
    super.key,
    required this.selectedAvatarIndex,
    required this.onAvatarSelected,
    this.unavailableAvatars = const [],
  });

  static const List<String> _avatarEmojis = [
    '😀', '😃', '😄', '😁', '😊', '😇', '🙂', '🙃',
    '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚',
    '🤪', '🤨', '🧐', '🤓'
  ];

  static const List<Color> _avatarColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFF97316), // Orange
    Color(0xFFEC4899), // Pink
    Color(0xFF84CC16), // Lime
    Color(0xFF6366F1), // Indigo (repeat)
  ];

  Color _getAvatarColor(int index) {
    return _avatarColors[index % _avatarColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Avatar',
          style: AppTextStyles.labelLarge,
        ),
        const SizedBox(height: 12),
        Container(
          height: 160,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              final isSelected = index == selectedAvatarIndex;
              final isUnavailable = unavailableAvatars.contains(index);
              final avatarColor = _getAvatarColor(index);
              
              return GestureDetector(
                onTap: isUnavailable ? null : () => onAvatarSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isUnavailable
                        ? Colors.grey.withValues(alpha: 0.3)
                        : isSelected
                            ? avatarColor
                            : avatarColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? avatarColor
                          : isUnavailable
                              ? Colors.grey
                              : Colors.transparent,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        Text(
                          _avatarEmojis[index],
                          style: TextStyle(
                            fontSize: 24,
                            color: isUnavailable
                                ? Colors.grey
                                : isSelected
                                    ? Colors.white
                                    : avatarColor,
                          ),
                        ),
                        if (isUnavailable)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.block,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isSelectedAvatarUnavailable 
              ? 'Selected avatar is already taken'
              : 'Tap an avatar to select it',
          style: AppTextStyles.caption.copyWith(
            color: isSelectedAvatarUnavailable 
                ? AppColors.danger
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  bool get isSelectedAvatarUnavailable => 
      unavailableAvatars.contains(selectedAvatarIndex);

  static String getAvatarEmoji(int index) {
    if (index >= 0 && index < _avatarEmojis.length) {
      return _avatarEmojis[index];
    }
    return _avatarEmojis[0];
  }

  static Color getAvatarColor(int index) {
    return _avatarColors[index % _avatarColors.length];
  }

  static Widget getAvatarIcon(int index, {double size = 24, Color? color}) {
    if (index >= 0 && index < _avatarEmojis.length) {
      return Text(
        _avatarEmojis[index],
        style: TextStyle(
          fontSize: size,
          color: color,
        ),
      );
    }
    return Text(
      _avatarEmojis[0],
      style: TextStyle(
        fontSize: size,
        color: color,
      ),
    );
  }
}