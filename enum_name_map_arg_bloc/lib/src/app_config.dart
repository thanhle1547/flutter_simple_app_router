import 'dart:collection';

import 'package:flutter/animation.dart';

import 'constants.dart';
import 'route_config.dart';
import 'route_transition.dart';

class AppConfig {
  static Object? initialPage;

  static String? initialPageName;

  static RouteTransition? defaultTransition;

  static Curve? defaultTransitionCurve;

  static Duration? defaultTransitionDuration;

  /// Prevent (accidentally) from navigating to the same page on `debug mode`.
  static bool shouldPreventDuplicates = kDebugPreventDuplicates;

  static String Function(Object page)? routeNameBuilder;

  static List<Type> routeTypes = [];

  static Map<Object, RouteConfig> routes = HashMap(
    equals: (key0, key1) => key0 == key1,
    hashCode: (key) => key.hashCode,
  );

  static Map<Object, List<Object>> stackedPages = HashMap(
    equals: (key0, key1) => key0 == key1,
    hashCode: (key) => key.hashCode,
  );
}
