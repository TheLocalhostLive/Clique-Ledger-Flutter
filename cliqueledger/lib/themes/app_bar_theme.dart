import 'package:flutter/material.dart';


class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const GradientAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color startColor = theme.colorScheme.primary;
    final Color endColor = theme.colorScheme.secondary;

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: theme.textTheme.titleSmall?.color,
          fontWeight: FontWeight.bold,
        ),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
