import 'package:flutter/material.dart';

/// Reusable button for call controls (mute, video, end call, etc.)
class CallControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final String? tooltip;
  final bool isActive;

  const CallControlButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 56.0,
    this.tooltip,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBgColor = isActive
        ? theme.colorScheme.primary.withOpacity(0.2)
        : theme.colorScheme.error.withOpacity(0.2);
    final defaultIconColor = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withOpacity(0.4);

    final button = Material(
      color: backgroundColor ?? defaultBgColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: iconColor ?? defaultIconColor,
            size: size * 0.4,
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Special button for ending calls (red background)
class EndCallButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double size;

  const EndCallButton({
    Key? key,
    required this.onPressed,
    this.size = 64.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CallControlButton(
      icon: Icons.call_end,
      onPressed: onPressed,
      backgroundColor: Colors.red,
      iconColor: Colors.white,
      size: size,
      tooltip: 'End call',
    );
  }
}
