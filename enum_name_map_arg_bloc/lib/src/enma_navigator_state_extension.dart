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
  /// * [preventDuplicates]
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
    bool? preventDuplicates,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) {
    checkRouteType(page);

    final RouteConfig routeConfig = getRouteConfig(page);

    if ((preventDuplicates ?? AppConfig.shouldPreventDuplicates) &&
        widget.pages.isNotEmpty &&
        widget.pages.last.name == page.name) {
      duplicatedPage(page.name.runtimeType.toString());
    }

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
    checkRouteType(page);

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
    bool Function(Route<dynamic>)? predicate,
    Map<String, dynamic>? arguments,
    RouteTransition? transition,
    TransitionBuilderDelegate? customTransitionBuilderDelegate,
    Curve? curve,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) {
    checkRouteType(page);

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
}
