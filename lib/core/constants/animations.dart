import 'package:flutter/animation.dart';

class AppAnimations {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 1000);
  
  // Specific animation durations
  static const Duration splash = Duration(milliseconds: 2000);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration cardFlip = Duration(milliseconds: 600);
  static const Duration reveal = Duration(milliseconds: 800);
  static const Duration elimination = Duration(milliseconds: 1200);
  static const Duration celebration = Duration(milliseconds: 1500);
  
  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.bounceOut;
  static const Curve elasticCurve = Curves.elasticOut;
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;
  
  // Scale animation values
  static const double scaleMin = 0.8;
  static const double scaleMax = 1.2;
  static const double scaleNormal = 1.0;
  
  // Rotation angles (in radians)
  static const double quarterTurn = 1.5708; // π/2
  static const double halfTurn = 3.14159;   // π
  static const double fullTurn = 6.28318;   // 2π
  
  // Slide animation distances
  static const double slideDistance = 100.0;
  static const double slideDistanceLarge = 200.0;
}