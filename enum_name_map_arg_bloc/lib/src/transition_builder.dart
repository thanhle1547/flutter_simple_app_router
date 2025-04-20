import 'package:flutter/material.dart';
import 'package:saut_enma_bloc/src/app_config.dart';

extension on Animatable {
  /// Returns a new [Animatable] whose value is determined by first evaluating
  /// the given parent and then evaluating this object.
  ///
  /// This allows [Tween]s to be chained before obtaining an [Animation].
  Animatable<T> chainWithCurve<T>(Curve? curve) {
    if (curve == null) return this as Animatable<T>;

    return chain(CurveTween(curve: curve)) as Animatable<T>;
  }
}

extension on Animation<double> {
  Animation<double> resolveWith({Curve? curve}) {
    if (curve == null) return this;

    return CurvedAnimation(parent: this, curve: curve);
  }
}

class NoTransition extends PageTransitionsBuilder {
  const NoTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class FadeInTransition extends PageTransitionsBuilder {
  const FadeInTransition({this.curve});

  final Curve? curve;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation.resolveWith(curve: curve ?? AppConfig.defaultTransitionCurve),
      child: child,
    );
  }
}

class RightToLeftTransition extends PageTransitionsBuilder {
  const RightToLeftTransition({this.curve});

  final Curve? curve;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animatable<Offset> tween = Tween(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).chainWithCurve(curve ?? AppConfig.defaultTransitionCurve);

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}

class RightToLeftWithFadeTransition extends PageTransitionsBuilder {
  const RightToLeftWithFadeTransition({this.curve});

  final Curve? curve;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animatable<Offset> tween = Tween(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).chainWithCurve(curve ?? AppConfig.defaultTransitionCurve);

    return SlideTransition(
      position: tween.animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

class DownToUpTransition extends PageTransitionsBuilder {
  const DownToUpTransition({this.curve});

  final Curve? curve;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final Animatable<Offset> tween = Tween(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).chainWithCurve(curve ?? AppConfig.defaultTransitionCurve);

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
