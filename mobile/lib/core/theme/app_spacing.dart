import 'package:flutter/material.dart';

/// Predictable Rhythmic Spacing and Radius Tokens
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Insets
  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0);
  static const EdgeInsets card = EdgeInsets.all(16.0);
  static const EdgeInsets compact = EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
}

class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 18.0;
  static const double pill = 999.0;

  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(pill));
}
