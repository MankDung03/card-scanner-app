import 'package:flutter/material.dart';

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 10.0;
  static const double lg = 12.0;
  static const double xl = 14.0;
  static const double xxl = 16.0;
  static const double r18Value = 18.0;
  static const double card = 24.0;

  static const BorderRadius r4 = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius r8 = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius r10 = BorderRadius.all(Radius.circular(md));
  static const BorderRadius r12 = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius r14 = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius r16 = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius r18 = BorderRadius.all(Radius.circular(r18Value));
  static const BorderRadius r24 = BorderRadius.all(Radius.circular(card));
}
