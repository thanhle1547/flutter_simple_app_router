import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class AbstractSautPageRouteBuilder<T> extends PageRoute<T> {
  AbstractSautPageRouteBuilder({
    RouteSettings? settings,
    required this.pageBuilder,
    required this.pageTransitionsBuilder,
    required bool fullscreenDialog,
    required this.createdFromSautPage,
  }) : super(
          settings: settings,
          fullscreenDialog: fullscreenDialog,
        );

  final RoutePageBuilder pageBuilder;

  final PageTransitionsBuilder pageTransitionsBuilder;

  final bool createdFromSautPage;

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
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return pageTransitionsBuilder.buildTransitions(
      this,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

class SautPageRouteBuilder<T> extends AbstractSautPageRouteBuilder<T> {
  SautPageRouteBuilder({
    RouteSettings? settings,
    required RoutePageBuilder pageBuilder,
    required PageTransitionsBuilder pageTransitionsBuilder,
    required this.transitionDuration,
    required this.opaque,
    required bool fullscreenDialog,
    required bool createdFromSautPage,
  }) : super(
          settings: settings,
          pageBuilder: pageBuilder,
          pageTransitionsBuilder: pageTransitionsBuilder,
          fullscreenDialog: fullscreenDialog,
          createdFromSautPage: createdFromSautPage,
        );

  @override
  final Duration transitionDuration;

  @override
  final bool opaque;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: pageBuilder(context, animation, secondaryAnimation),
    );
  }
}
