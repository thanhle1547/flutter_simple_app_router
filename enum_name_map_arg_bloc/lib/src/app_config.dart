import 'dart:collection';

import 'package:flutter/animation.dart';

import 'route_config.dart';
import 'route_transition.dart';

class AppConfig {
  static Enum? initialPage;

  static String? initialPageName;

  static RouteTransition? defaultTransition;

  static Curve? defaultTransitionCurve;

  static Duration? defaultTransitionDuration;

  /// Prevent (accidentally) from navigating to the same page on `debug mode`.
  static bool shouldPreventDuplicates = true;

  static String Function(Enum page)? routeNameBuilder;

  static List<Type> routeTypes = [];

  static Map<Enum, RouteConfig> routes = HashMap(
    equals: (key0, key1) => key0 == key1,
    hashCode: (key) => key.hashCode,
  );
}
