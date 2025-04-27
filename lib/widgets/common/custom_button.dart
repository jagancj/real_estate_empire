import 'package:flutter/material.dart';

enum ButtonType {
  primary,
  secondary,
  success,
  danger,
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    Color textColor;
    
    // Determine colors based on type
    switch (type) {
      case ButtonType.primary:
        buttonColor = Theme.of(context).primaryColor;
        textColor = Colors.white;
        break;
      case ButtonType.secondary:
        buttonColor = Colors.grey[200]!;
        textColor = Colors.black87;
        break;
      case ButtonType.success:
        buttonColor = Colors.green;
        textColor = Colors.white;
        break;
      case ButtonType.danger:
        buttonColor = Colors.red;
        textColor = Colors.white;
        break;
    }
    
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            else if (icon != null)
              Icon(icon, size: 20),
            if ((isLoading || icon != null) && label.isNotEmpty)
              const SizedBox(width: 8),
            if (label.isNotEmpty)
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}