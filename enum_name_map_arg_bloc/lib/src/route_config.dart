import 'package:flutter/material.dart';

import 'constants.dart';
import 'route_transition.dart';
import 'transition_builder_delegate.dart';

class RouteConfig {
  final Map<String, Type>? requiredArguments;
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
  });
}
