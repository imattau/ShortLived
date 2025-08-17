import 'package:flutter/material.dart';

/// Basic design tokens used across the UI.
class T {
  static const double s16 = 16.0;
  static const double s24 = 24.0;

  static const double r16 = 16.0;

  static const Color bg = Colors.black;
  static const Color blue = Colors.blueAccent;

  static const double btnSize = 44; // min tap target (kept ≥44px)
  static const double btnGap = 10; // gap between icon and count
  static const double stackGapMin = 6; // ↓ new: tighter floor
  static const double stackGapMax = 14; // cap for tall screens
  static const double stackSidePad = 20; // right margin
  static const double stackSafeBottom =
      140; // space reserved for Create btn footprint
  static const double maxCaptionW = 520; // used elsewhere
}
