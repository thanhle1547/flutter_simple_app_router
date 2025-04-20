import 'package:flutter/material.dart';

import 'transition_builder.dart';

abstract class SautRouteTransition {
  SautRouteTransition._();

  static const PageTransitionsBuilder fadeIn = FadeInTransition();
  static const PageTransitionsBuilder rightToLeft = RightToLeftTransition();
  static const PageTransitionsBuilder rightToLeftWithFade = RightToLeftWithFadeTransition();
  static const PageTransitionsBuilder downToUp = DownToUpTransition();

  /// Similar to the one provided by Android O
  ///
  /// Slides the page upwards and fades it in, starting
  /// from 1/4 screen below the top.
  static const PageTransitionsBuilder fadeUpwards = FadeUpwardsPageTransitionsBuilder();

  /// Similar to the one provided by Android P
  static const PageTransitionsBuilder openUpwards = OpenUpwardsPageTransitionsBuilder();

  /// Similar to the one provided by Android Q
  ///
  /// Zooms and fades a new page in, zooming out the previous page.
  static const PageTransitionsBuilder zoom = ZoomPageTransitionsBuilder();

  static const PageTransitionsBuilder none = NoTransition();
}
