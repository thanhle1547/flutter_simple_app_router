import 'package:flutter/material.dart';

import 'constants.dart';

class RouteConfig {
  /// The key is the name of argument.
  ///
  /// The value is the type of argument. It's can be anything but [dynamic].
  ///
  /// Example:
  /// ```dart
  /// requiredArguments: {
  ///   'val_1': int,
  ///   'val_2': String,
  ///   'val_3': List,
  ///   'val_4': 'List<int>',
  ///   'val_5': 9,
  /// }
  /// ```
  /// In above example:
  ///
  ///  * 'val_4'` has value of `'List<int>'` (a String),
  /// not `List<int>`, because dart analysis will show error:
  /// `This requires the 'constructor-tearoffs' language feature to be enabled.`
  ///
  ///  * `'val_5'` has value of `9` (a spcific number), this value will
  /// be treat as `runtimeType`
  final Map<String, Object>? debugRequiredArguments;

  /// A builder for custom [Route]
  final Route<T> Function<T>(
    BuildContext context,
    RouteConfig resolvedConfig,
    RouteSettings settings,
    Widget page,
  )? routeBuilder;
  final Widget Function(Map<String, dynamic>? arguments) pageBuilder;
  final PageTransitionsBuilder? transitionsBuilder;
  final Duration? transitionDuration;
  final bool opaque;
  final bool fullscreenDialog;

  /// Prevent (accidentally) from navigating to the same page on `debug mode`.
  final bool? debugPreventDuplicates;

  bool get useRouteBuilder => routeBuilder != null;

  RouteConfig({
    this.debugRequiredArguments,
    this.routeBuilder,
    required this.pageBuilder,
    this.transitionsBuilder,
    this.transitionDuration,
    this.opaque = kOpaque,
    this.fullscreenDialog = kFullscreenDialog,
    this.debugPreventDuplicates,
  }) : assert(
          _assertRequiredArguments(debugRequiredArguments),
          'A value of type dynamic can not be defined',
        );

  RouteConfig copyWith({
    Route<T> Function<T>(
      BuildContext context,
      RouteConfig resolvedConfig,
      RouteSettings settings,
      Widget page,
    )? routeBuilder,
    Widget Function(Map<String, dynamic>? arguments)? pageBuilder,
    PageTransitionsBuilder? transitionsBuilder,
    Duration? transitionDuration,
    bool? opaque,
    bool? fullscreenDialog,
    bool? debugPreventDuplicates,
  }) {
    return RouteConfig(
      debugRequiredArguments: debugRequiredArguments,
      routeBuilder: routeBuilder ?? this.routeBuilder,
      pageBuilder: pageBuilder ?? this.pageBuilder,
      transitionsBuilder: transitionsBuilder ?? this.transitionsBuilder,
      transitionDuration: transitionDuration ?? this.transitionDuration,
      opaque: opaque ?? this.opaque,
      fullscreenDialog: fullscreenDialog ?? this.fullscreenDialog,
      debugPreventDuplicates:
          debugPreventDuplicates ?? this.debugPreventDuplicates,
    );
  }
}

bool _assertRequiredArguments(Map<String, Object>? requiredArguments) {
  assert(() {
    if (requiredArguments == null) return true;

    for (final MapEntry<String, Object> item in requiredArguments.entries) {
      if (item.value.toString() == 'dynamic') return false;
    }

    return true;
  }());

  return true;
}
