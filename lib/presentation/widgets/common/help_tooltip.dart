import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/localization_service.dart';
import '../../../core/utils/audio_service.dart';

class HelpTooltip extends StatelessWidget {
  final String messageKey;
  final Widget child;
  final String? title;
  final TooltipTriggerMode? triggerMode;
  final Duration? waitDuration;
  final bool showHelp;

  const HelpTooltip({
    super.key,
    required this.messageKey,
    required this.child,
    this.title,
    this.triggerMode,
    this.waitDuration,
    this.showHelp = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showHelp) {
      return child;
    }

    final localization = LocalizationService();
    final audioService = AudioService();

    return Tooltip(
      message: localization.translate(messageKey),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.all(8),
      preferBelow: true,
      triggerMode: triggerMode ?? TooltipTriggerMode.longPress,
      waitDuration: waitDuration ?? const Duration(milliseconds: 500),
      onTriggered: () {
        audioService.lightVibration();
      },
      child: child,
    );
  }
}

class HelpIconButton extends StatelessWidget {
  final String messageKey;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const HelpIconButton({
    super.key,
    required this.messageKey,
    this.onPressed,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();
    final audioService = AudioService();

    return IconButton(
      icon: Icon(
        Icons.help_outline,
        size: size,
        color: color ?? const Color(0xFF6366F1).withOpacity(0.7),
      ),
      onPressed: onPressed ?? () {
        audioService.lightVibration();
        _showHelpDialog(context, localization);
      },
      tooltip: 'Help',
    );
  }

  void _showHelpDialog(BuildContext context, LocalizationService localization) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Color(0xFF6366F1),
            ),
            SizedBox(width: 8),
            Text('Help'),
          ],
        ),
        content: Text(
          localization.translate(messageKey),
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localization.close,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpBottomSheet extends StatelessWidget {
  final String titleKey;
  final List<HelpItem> items;

  const HelpBottomSheet({
    super.key,
    required this.titleKey,
    required this.items,
  });

  static void show(
    BuildContext context, {
    required String titleKey,
    required List<HelpItem> items,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HelpBottomSheet(
        titleKey: titleKey,
        items: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: const Color(0xFF6366F1),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localization.translate(titleKey),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Help items
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildHelpItem(item, localization);
              },
            ),
          ),
          
          // Bottom padding
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHelpItem(HelpItem item, LocalizationService localization) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  color: const Color(0xFF6366F1),
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  item.titleKey != null
                      ? localization.translate(item.titleKey!)
                      : item.title ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          if (item.contentKey != null || item.content != null) ...[
            const SizedBox(height: 8),
            Text(
              item.contentKey != null
                  ? localization.translate(item.contentKey!)
                  : item.content ?? '',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF1E293B).withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class HelpItem {
  final String? titleKey;
  final String? title;
  final String? contentKey;
  final String? content;
  final IconData? icon;

  const HelpItem({
    this.titleKey,
    this.title,
    this.contentKey,
    this.content,
    this.icon,
  });
}

class GamePhaseHelp extends StatelessWidget {
  final String currentPhase;
  final String instructionsKey;
  final List<HelpItem> tips;

  const GamePhaseHelp({
    super.key,
    required this.currentPhase,
    required this.instructionsKey,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF6366F1),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                currentPhase,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6366F1),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HelpBottomSheet.show(
                    context,
                    titleKey: 'Phase Help',
                    items: tips,
                  );
                },
                child: Icon(
                  Icons.help_outline,
                  color: const Color(0xFF6366F1),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            LocalizationService().translate(instructionsKey),
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF6366F1).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}