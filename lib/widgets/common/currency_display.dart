import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyDisplay extends StatelessWidget {
  final double amount;
  final double fontSize;
  final Color? color;
  final bool compact;
  
  const CurrencyDisplay({
    super.key,
    required this.amount,
    this.fontSize = 16,
    this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: compact ? 1 : 2,
    );
    
    String displayValue;
    if (compact && amount >= 1000000) {
      displayValue = '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (compact && amount >= 1000) {
      displayValue = '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      displayValue = formatter.format(amount);
    }
    
    return Text(
      displayValue,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color ?? Colors.black,
      ),
    );
  }
}