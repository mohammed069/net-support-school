import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon:
          isLoading
              ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(backgroundColor: backgroundColor),
    );
  }
}
