import 'package:flutter/material.dart';

class AppTextStyles {
  static const TextStyle code = TextStyle(
    fontFamily: 'monospace',
    fontSize: 14.0,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static const TextStyle lineNumbers = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12.0,
    color: Color(0xFF9E9E9E),
    height: 1.4,
  );

  static const TextStyle hexHeader = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle hexBytes = TextStyle(
    fontFamily: 'monospace',
    fontSize: 12.0,
    letterSpacing: 1.0,
  );
}

