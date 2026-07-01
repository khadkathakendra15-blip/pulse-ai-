import 'package:flutter/material.dart';

/// Exact palette lifted from the Pulse AI mockup (`Pulse AI App - Standalone`).
/// Names mirror how the design uses each value so screens read declaratively.
class C {
  C._();

  // Surfaces
  static const bodyBg = Color(0xFF04060A); // outermost page
  static const screenBg = Color(0xFF070A0E); // phone screen background
  static const card = Color(0xFF0F1318); // standard card
  static const cardDark = Color(0xFF090D12); // twin / future-module card
  static const cardDarker = Color(0xFF090C11);

  // Accents
  static const accent = Color(0xFF2BE3A0); // mint — primary
  static const blue = Color(0xFF4DB6FF);
  static const purple = Color(0xFF7C6BFF);
  static const purpleSoft = Color(0xFFB98BFF);
  static const amber = Color(0xFFF5B342);
  static const coral = Color(0xFFFF6B72);

  // Text
  static const textHi = Color(0xFFEEF1F2); // primary headings
  static const text2 = Color(0xFFDCE2E8);
  static const text3 = Color(0xFFCDD3D8);
  static const dim1 = Color(0xFF9AA3AB);
  static const dim2 = Color(0xFF8C949B);
  static const dim3 = Color(0xFF7C858D);
  static const dim4 = Color(0xFF6B747C);
  static const dim5 = Color(0xFF5B636B);
  static const dim6 = Color(0xFF4E5760);
  static const dim7 = Color(0xFF404850); // very dim labels / "off" nav
  static const dim8 = Color(0xFF363D44);

  // Hairlines
  static const line = Color(0x12FFFFFF); // rgba(255,255,255,.07)
  static const lineSoft = Color(0x0DFFFFFF); // rgba(255,255,255,.05)
  static const lineFaint = Color(0x0AFFFFFF); // rgba(255,255,255,.04)

  // Tints used repeatedly
  static Color accentT(double o) => accent.withValues(alpha: o);
  static Color blueT(double o) => blue.withValues(alpha: o);
  static Color amberT(double o) => amber.withValues(alpha: o);
  static Color coralT(double o) => coral.withValues(alpha: o);
  static Color purpleT(double o) => purple.withValues(alpha: o);
  static Color whiteT(double o) => Colors.white.withValues(alpha: o);
}
