import 'package:flutter/material.dart';

BoxDecoration glassCardDecoration({
  double opacity = 0.85,
  double borderRadius = 16,
  double borderWidth = 1.4,
}) =>
    BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: const Color(0xFF7B3FE4).withOpacity(0.18),
        width: borderWidth,
      ),
    );