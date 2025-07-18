import 'dart:collection';

import 'package:flutter/material.dart';

import 'constants.dart';
import 'route_config.dart';

class AppConfig {
  static Enum? initialPage;

  static String? initialPageName;

  static PageTransitionsBuilder? defaultTransitionsBuilder;

  static Duration? defaultTransitionDuration;

  static Curve? defaultTransitionCurve;

  /// Prevent (accidentally) from navigating to the same page on `debug mode`.
  static bool shouldPreventDuplicates = kDebugPreventDuplicates;

  static String Function(Enum page)? routeNameBuilder;

  static Map<Enum, RouteConfig> routes = HashMap(
    equals: (key0, key1) => key0 == key1,
    hashCode: (key) => key.hashCode,
  );

  static Map<Object, List<Enum>> stackedPages = HashMap(
    equals: (key0, key1) => key0 == key1,
    hashCode: (key) => key.hashCode,
  );

  static bool didPreventBackButtonToGoBack = false;
}
