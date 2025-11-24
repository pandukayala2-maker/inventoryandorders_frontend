// lib/widgets/header_bar.dart

import 'package:flutter/material.dart';
import '../theme.dart';

class HeaderBar extends StatelessWidget {
  final String title;
  final Widget? action;

  const HeaderBar({
    super.key,
    required this.title,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkText,
            ),
          ),
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}
