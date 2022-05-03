import 'package:flutter/material.dart';

import 'assert_funcs.dart';
import 'constants.dart';
import 'route_transition.dart';
import 'transition_builder_delegate.dart';

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
  final Map<String, Object>? requiredArguments;
  final Widget Function(Map<String, dynamic>? arguments) pageBuilder;
  final RouteTransition? transition;
  final TransitionBuilderDelegate? customTransitionBuilderDelegate;
  final Duration? transitionDuration;
  final Curve? curve;
  final bool opaque;
  final bool fullscreenDialog;
  final bool? preventDuplicates;

  RouteConfig({
    this.requiredArguments,
    required this.pageBuilder,
    this.transition,
    this.customTransitionBuilderDelegate,
    this.transitionDuration,
    this.curve,
    this.opaque = kOpaque,
    this.fullscreenDialog = kFullscreenDialog,
    this.preventDuplicates,
  }) : assert(
          assertRequiredArguments(requiredArguments),
          assertRequiredArgumentsFailed,
        );
}
