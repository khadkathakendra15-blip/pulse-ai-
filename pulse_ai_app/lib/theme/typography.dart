import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Three families, matching the mockup:
///  - Manrope      → body / UI text
///  - Space Grotesk → numbers, scores, headings (the "display" face)
///  - Mukta        → Nepali (Devanagari) text  (the `.np` class in the HTML)
class F {
  F._();

  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Space Grotesk — the display face used for every number and most titles.
  static TextStyle display({
    double size = 14,
    FontWeight weight = FontWeight.w700,
    Color? color,
    double? height,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Devanagari face for Nepali strings.
  static TextStyle np({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.mukta(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Body text that automatically uses the Devanagari face when [nepali] is
  /// true — mirrors the `class="{{ briefFont }}"` switch in the mockup.
  static TextStyle briefed(
    bool nepali, {
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
    double letterSpacing = 0,
  }) =>
      nepali
          ? np(size: size, weight: weight, color: color, height: height, letterSpacing: letterSpacing)
          : body(size: size, weight: weight, color: color, height: height, letterSpacing: letterSpacing);
}
