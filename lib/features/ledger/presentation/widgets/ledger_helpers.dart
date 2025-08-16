import 'package:flutter/material.dart';

Color getTypeColor(String type) => switch (type) {
  'sale' => const Color(0xFF4CAF50),
  'interest' => const Color(0xFFFF9800),
  'equity' => const Color(0xFF2196F3),
  'asset' => const Color(0xFF9C27B0),
  'purchase' => const Color(0xFFF44336),
  'expense' => const Color(0xFFE91E63),
  _ => Colors.grey,
};

IconData getTypeIcon(String type) => switch (type) {
  'sale' => Icons.point_of_sale,
  'interest' => Icons.percent,
  'equity' => Icons.account_balance_wallet,
  'asset' => Icons.account_balance,
  'purchase' => Icons.shopping_cart,
  'expense' => Icons.money_off,
  _ => Icons.help_outline,
};

String formatAmount(double amount, String type) {
  final prefix = switch (type) {
    'expense' || 'purchase' => '-',
    _ => '+',
  };
  return '$prefix\$${amount.toStringAsFixed(2)}';
}

String formatMonth(DateTime date) {
  final months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String formatDateShort(DateTime date) {
  return '${date.day} ${formatMonth(date).substring(0, 3)}';
}
