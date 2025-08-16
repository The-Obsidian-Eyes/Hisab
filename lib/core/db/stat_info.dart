import 'package:flutter/material.dart';

class StatInfo {
  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final bool showPercentage;

  StatInfo(
    this.title,
    this.value,
    this.icon,
    this.color, {
    this.showPercentage = false,
  });

  String get formattedValue =>
      showPercentage
          ? '${value.toStringAsFixed(1)}%'
          : value.toStringAsFixed(2);
}
