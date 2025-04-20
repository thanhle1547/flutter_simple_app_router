import 'package:flutter/material.dart';

import 'route_transition.dart';

const String source = 'SAUT';

const PageTransitionsBuilder kPageTransitionsBuilder = SautRouteTransition.none;

const Duration kTransitionDuration = Duration(milliseconds: 300);

/// {@macro flutter.widgets.TransitionRoute.opaque}
const bool kOpaque = true;

/// {@macro flutter.widgets.PageRoute.fullscreenDialog}
const bool kFullscreenDialog = false;

const bool kDebugPreventDuplicates = true;
