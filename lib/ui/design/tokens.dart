import 'package:flutter/material.dart';

/// Basic design tokens used across the UI.
class T {
  static const double s16 = 16.0;
  static const double s24 = 24.0;

  static const double r16 = 16.0;

  static const Color bg = Colors.black;
  static const Color blue = Colors.blueAccent;

  // Tap target sizes (we keep ≥44 on touch)
  static const double btnSizeTouch = 44;
  static const double btnSizeMouse = 40;

  // Vertical gap between rows (min..max)
  static const double stackGapMin = 4;
  static const double stackGapMed = 6;
  static const double stackGapMax = 10;

  // Spacing inside a row (icon ↔ count)
  static const double rowGap = 6;

  static const double stackSidePad = 18;
  static const double stackTopHeadroom = 80;
  static const double stackBottomReserve =
      120; // Create button footprint
  /// Max width for narrow content sheets and overlays on large screens.
  static const double maxCaptionW = 600.0;
}
