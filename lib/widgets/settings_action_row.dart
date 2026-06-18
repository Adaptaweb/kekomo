import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adaptive_widgets.dart';
import 'leading_icon_box.dart';

class SettingsActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool destructive;
  final bool isLast;

  const SettingsActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.destructive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.primary;

    return AdaptiveListTile(
      leading: LeadingIconBox(icon: icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: destructive ? color : null,
        ),
      ),
      trailing: Icon(
        CupertinoIcons.chevron_forward,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
      isLast: isLast,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
