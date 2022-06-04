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
  /// To provide an existing bloc to a new page.
  ///
  /// * [blocProviders]
  ///
  /// To provide existing blocs to a new page.
  ///
  /// * [debugPreventDuplicates]
  ///
  /// Prevent navigate to the same page.
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
  /// Return a [Future]. The Future resolves when back to previous page
  /// and the [Future]'s value is the [back] method's `result` parameter.
  Future<T?> toPage<T extends Object?, B extends BlocBase<Object?>>(
    Enum page, {
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
          getCurrentNavigatorRouteName() == name) {
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

  /// [blocValue]: To provide an existing bloc to a new page.
  ///
  /// __Warning__: `SAUT` won't automatically handle closing the bloc.
  ///
  /// * [duration]
  ///
  /// The duration the transition going forwards.
  ///
  /// Return a [Future]. The Future resolves when back to previous page
  /// and the [Future]'s value is the [back] method's `result` parameter.
  Future<T?>? replaceWithPage<T extends Object?, B extends BlocBase<Object?>>(
    Enum page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<BlocProviderSingleChildWidget>? blocProviders,
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
    );
  }

  /// * [duration]
  ///
  /// The duration the transition going forwards.
  ///
  /// Return a [Future]. The Future resolves when back to previous page
  /// and the [Future]'s value is the [back] method's `result` parameter.
  Future<T?>?
      replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
    Enum page, {
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

  void back<T>({T? result}) => pop(result);

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

  void backToPage(dynamic page) => backToPageName(
        effectiveRouteNameBuilder(page),
      );

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  Route? getCurrentNavigatorRoute() {
    Route? currentRoute;
    popUntil((route) {
      currentRoute = route;
      return true;
    });
    return currentRoute;
  }

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  String? getCurrentNavigatorRouteName() =>
      getCurrentNavigatorRoute()!.settings.name;
}
