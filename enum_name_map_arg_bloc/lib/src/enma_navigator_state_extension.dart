import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;

import 'app_config.dart';
import 'route.dart';
import 'route_config.dart';
import 'route_transition.dart';
import 'transition_builder_delegate.dart';

extension EnmaNavigatorStateExtension on NavigatorState {
  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to a new page.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to a new page.
  ///
  /// * [transition]
  ///
  /// Used to build the route's transitions.
  ///
  /// * [customTransitionBuilderDelegate]
  ///
  /// Used to build your own custom route's transitions.
  ///
  /// * [curve]
  ///
  /// An parametric animation easing curve, i.e. a mapping of the unit interval to
  /// the unit interval.
  ///
  /// * [duration]
  ///
  /// The duration the transition going forwards.
  ///
  /// * [opaque]
  ///
  /// {@macro flutter.widgets.TransitionRoute.opaque}
  ///
  /// * [fullscreenDialog]
  ///
  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  ///
  /// * [debugPreventDuplicates]
  ///
  /// Prevent (accidentally) from navigating to the same page on `debug mode`.
  ///
  /// Return a [Future]. The Future resolves when back to previous page
  /// and the [Future]'s value is the [back] method's `result` parameter.
  ///
  /// The `T` type argument is the type of the return value of the route.
  ///
  /// See also:
  ///
  ///  * [Curve], the interface implemented by the constants available from the
  ///    [Curves] class.
  ///  * [Curves], a collection of common animation easing curves.
  @optionalTypeArgs
  Future<T?> toPage<T extends Object?, B extends BlocBase<Object?>>(
    Object page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<BlocProviderSingleChildWidget>? blocProviders,
    RouteTransition? transition,
    TransitionBuilderDelegate? customTransitionBuilderDelegate,
    Curve? curve,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
    bool? debugPreventDuplicates,
  }) {
    assert(debugAssertRouteTypeIsValid(page));

    final RouteConfig routeConfig = getRouteConfig(page);

    assert(() {
      final String name = effectiveRouteNameBuilder(page);
      late final String runtimeType = objectRuntimeType(page, 'String');

      if ((debugPreventDuplicates ??
              routeConfig.debugPreventDuplicates ??
              AppConfig.shouldPreventDuplicates) &&
          getCurrentRouteName() == name) {
        throw StateError("Duplicated Page: $runtimeType");
      }

      return true;
    }());

    return push<T>(
      createRoute(
        pageBuilder: resolvePageBuilderWithBloc(
          pageBuilder: getPageBuilder(routeConfig, arguments),
          blocValue: blocValue,
          blocProviders: blocProviders,
        ),
        settings: RouteSettings(
          name: effectiveRouteNameBuilder(page),
          arguments: arguments,
        ),
        transitionBuilderDelegate:
            (transition ?? routeConfig.transition)?.builder ??
                customTransitionBuilderDelegate ??
                routeConfig.customTransitionBuilderDelegate,
        transitionDuration: duration ?? routeConfig.transitionDuration,
        curve: curve ?? routeConfig.curve,
        opaque: opaque ?? routeConfig.opaque,
        fullscreenDialog: fullscreenDialog ?? routeConfig.fullscreenDialog,
      ),
    );
  }

  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to a new page.
  ///
  /// __Warning__: `SAUT` won't automatically handle closing the bloc.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to a new page.
  ///
  /// * [result]
  ///
  /// If non-null, `result` will be used as the result of the route that is removed;
  /// the future that had been returned from pushing that old route
  /// will complete with result. The type of `result`, if provided,
  /// must match the type argument of the class of the old route (`TO`).
  ///
  /// * [transition]
  ///
  /// Used to build the route's transitions.
  ///
  /// * [customTransitionBuilderDelegate]
  ///
  /// Used to build your own custom route's transitions.
  ///
  /// * [curve]
  ///
  /// An parametric animation easing curve, i.e. a mapping of the unit interval to
  /// the unit interval.
  ///
  /// * [duration]
  ///
  /// The duration the transition going forwards.
  ///
  /// * [opaque]
  ///
  /// {@macro flutter.widgets.TransitionRoute.opaque}
  ///
  /// * [fullscreenDialog]
  ///
  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  ///
  /// The `T` type argument is the type of the return value of the new route,
  /// and `TO` is the type of the return value of the old route.
  ///
  /// See also:
  ///
  ///  * [Curve], the interface implemented by the constants available from the
  ///    [Curves] class.
  ///  * [Curves], a collection of common animation easing curves.
  @optionalTypeArgs
  Future<T?>? replaceWithPage<T extends Object?, B extends BlocBase<Object?>,
      TO extends Object?>(
    Object page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<BlocProviderSingleChildWidget>? blocProviders,
    TO? result,
    RouteTransition? transition,
    TransitionBuilderDelegate? customTransitionBuilderDelegate,
    Curve? curve,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) {
    assert(debugAssertRouteTypeIsValid(page));

    final RouteConfig routeConfig = getRouteConfig(page);

    return pushReplacement(
      createRoute(
        pageBuilder: resolvePageBuilderWithBloc(
          pageBuilder: getPageBuilder(routeConfig, arguments),
          blocValue: blocValue,
          blocProviders: blocProviders,
        ),
        settings: RouteSettings(
          name: effectiveRouteNameBuilder(page),
          arguments: arguments,
        ),
        transitionBuilderDelegate:
            (transition ?? routeConfig.transition)?.builder ??
                customTransitionBuilderDelegate ??
                routeConfig.customTransitionBuilderDelegate,
        transitionDuration: duration ?? routeConfig.transitionDuration,
        curve: curve ?? routeConfig.curve,
        opaque: opaque ?? routeConfig.opaque,
        fullscreenDialog: fullscreenDialog ?? routeConfig.fullscreenDialog,
      ),
      result: result,
    );
  }

  /// [predicate]
  ///
  /// To remove routes until a route with a certain name,
  /// use the [RoutePredicate] returned from [Saut.getModalRoutePredicate].
  ///
  /// To remove all the routes the replaced route, simply let [predicate] null.
  ///
  /// * [transition]
  ///
  /// Used to build the route's transitions.
  ///
  /// * [customTransitionBuilderDelegate]
  ///
  /// Used to build your own custom route's transitions.
  ///
  /// * [curve]
  ///
  /// An parametric animation easing curve, i.e. a mapping of the unit interval to
  /// the unit interval.
  ///
  /// * [duration]
  ///
  /// The duration the transition going forwards.
  ///
  /// * [opaque]
  ///
  /// {@macro flutter.widgets.TransitionRoute.opaque}
  ///
  /// * [fullscreenDialog]
  ///
  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  ///
  /// The T type argument is the type of the return value of the new route.
  ///
  /// See also:
  ///
  ///  * [Curve], the interface implemented by the constants available from the
  ///    [Curves] class.
  ///  * [Curves], a collection of common animation easing curves.
  @optionalTypeArgs
  Future<T?>?
      replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
    Object page, {
    RoutePredicate? predicate,
    Map<String, dynamic>? arguments,
    RouteTransition? transition,
    TransitionBuilderDelegate? customTransitionBuilderDelegate,
    Curve? curve,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) {
    assert(debugAssertRouteTypeIsValid(page));

    final RouteConfig routeConfig = getRouteConfig(page);

    return pushAndRemoveUntil(
      createRoute(
        pageBuilder: getPageBuilder(routeConfig, arguments),
        settings: RouteSettings(
          name: effectiveRouteNameBuilder(page),
          arguments: arguments,
        ),
        transitionBuilderDelegate:
            (transition ?? routeConfig.transition)?.builder ??
                customTransitionBuilderDelegate ??
                routeConfig.customTransitionBuilderDelegate,
        transitionDuration: duration ?? routeConfig.transitionDuration,
        curve: curve ?? routeConfig.curve,
        opaque: opaque ?? routeConfig.opaque,
        fullscreenDialog: fullscreenDialog ?? routeConfig.fullscreenDialog,
      ),
      predicate ?? (Route<dynamic> _) => false,
    );
  }

  /// The `T` type argument is the type of the return value of the popped route.
  ///
  /// The type of `result`, if provided,
  /// must match the type argument of the class of the popped route (`T`).
  ///
  /// See [Navigator.pop] for more details of the semantics of popping a route.
  @optionalTypeArgs
  void back<T extends Object?>({T? result}) => pop(result);

  /// Calls [back] repeatedly until found the page with a certain name.
  void backToPageName(String name) => popUntil((route) {
        if (route is DialogRoute) return false;

        String? routeName;

        if (route is MaterialPageRoute || route is PageRouteBuilder) {
          routeName = route.settings.name;
        }

        return routeName == name ||
            (AppConfig.initialPageName != null &&
                routeName == AppConfig.initialPageName);
      });

  /// Calls [back] repeatedly until found the page.
  void backToPage(Object page) => backToPageName(
        effectiveRouteNameBuilder(page),
      );

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  Route? getCurrentRoute() {
    Route? currentRoute;
    popUntil((route) {
      currentRoute = route;
      return true;
    });
    return currentRoute;
  }

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  String? getCurrentRouteName() => getCurrentRoute()!.settings.name;
}
