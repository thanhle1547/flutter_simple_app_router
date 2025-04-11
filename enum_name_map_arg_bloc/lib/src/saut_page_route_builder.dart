import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'transition_builder_delegate.dart';

class SautPageRouteBuilder<T> extends PageRouteBuilder<T> {
  SautPageRouteBuilder({
    RouteSettings? settings,
    required RoutePageBuilder pageBuilder,
    required this.transitionBuilderDelegate,
    required Duration transitionDuration,
    this.curve,
    required bool opaque,
    required bool fullscreenDialog,
    required this.createdFromSautPage,
  }) : super(
          settings: settings,
          pageBuilder: pageBuilder,
          transitionDuration: transitionDuration,
          opaque: opaque,
          fullscreenDialog: fullscreenDialog,
        );

  final TransitionBuilderDelegate transitionBuilderDelegate;
  final Curve? curve;
  final bool createdFromSautPage;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return transitionBuilderDelegate.buildTransition(
      this,
      context,
      animation,
      secondaryAnimation,
      curve,
      child,
    );
  }

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    // Suppress previous route from transitioning if this is a fullscreenDialog route.
    //
    // From Flutter 3.29.0
    // https://github.com/flutter/flutter/pull/159312
    return previousRoute is PageRoute && !fullscreenDialog;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    final bool nextRouteIsNotFullscreen =
        (nextRoute is! PageRoute<T>) || !nextRoute.fullscreenDialog;

    return nextRouteIsNotFullscreen &&
        (nextRoute is MaterialRouteTransitionMixin || nextRoute is CupertinoRouteTransitionMixin);
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: super.buildPage(context, animation, secondaryAnimation),
    );
  }
}
