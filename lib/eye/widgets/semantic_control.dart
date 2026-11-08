import 'package:flutter/material.dart';

/// Wraps a control with explicit screen-reader semantics while hiding the
/// duplicate semantics of the visual child.
class SemanticControl extends StatelessWidget {
  const SemanticControl({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.toggled,
    this.selected,
    this.onTap,
  });

  final String label;
  final String? hint;
  final bool? toggled;
  final bool? selected;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      toggled: toggled,
      selected: selected,
      enabled: onTap != null,
      onTap: onTap,
      child: ExcludeSemantics(child: child),
    );
  }
}
