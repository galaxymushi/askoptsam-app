import 'package:flutter/material.dart';

import 'eye_ui.dart';

/// Large home action, rendered as the blue card from the Eye design.
class BigButton extends StatelessWidget {
  const BigButton({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.onPressed,
    this.number,
  });

  final IconData icon;
  final String label;
  final String hint;
  final String? number;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final callback = onPressed;
    if (callback == null) {
      return Opacity(
        opacity: 0.45,
        child: EyeActionCard(
          icon: icon,
          title: label,
          hint: hint,
          onPressed: () {},
        ),
      );
    }
    return EyeActionCard(
      icon: icon,
      title: label,
      hint: hint,
      onPressed: callback,
    );
  }
}
