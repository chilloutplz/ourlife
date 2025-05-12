// lib/widgets/home/home_icon_button.dart
import 'package:flutter/material.dart';

class HomeIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String routeName;
  final Color? color;

  const HomeIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.routeName,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Ink(
          decoration: const ShapeDecoration(
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: () => Navigator.pushNamed(context, routeName),
            iconSize: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            color: color,
            ),
        ),
      ],
    );
  }
}
