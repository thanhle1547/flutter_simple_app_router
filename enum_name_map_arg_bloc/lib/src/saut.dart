import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;

import 'app_config.dart';
import 'enma_build_context_extension.dart';
import 'enma_navigator_state_extension.dart';
import 'navigator_state_extension.dart';
import 'route.dart';
import 'route_config.dart';
import 'route_transition.dart';
import 'saut_route_observer.dart';
import 'transition_builder_delegate.dart';

class Saut {
  /// [routeTypes]: For checking page has been defined each time navigating.
  ///
  /// [initialPage]: The page that will be used when failed to find defined page.
  ///
  /// [routeNameBuilder]: Transform the enum into the string that will shown
  /// in debug console/debug log.
  ///
  /// [preventDuplicates]: Prevent navigate to the same page.
  static void setDefaultConfig({
    List<Type>? routeTypes,
    Map<Enum, RouteConfig>? routes,
    required Enum initialPage,
    String Function(Enum page)? routeNameBuilder,
    RouteTransition? transition = RouteTransition.rightToLeft,
    Curve? transitionCurve = Curves.easeOutQuad,
    Duration? transitionDuration = const Duration(milliseconds: 320),
    bool preventDuplicates = true,
  }) {
    if (routeTypes != null) AppConfig.routeTypes = routeTypes;

    if (routes != null) AppConfig.routes.addAll(routes);

    AppConfig.routeNameBuilder = routeNameBuilder;

    AppConfig.initialPage = initialPage;
    AppConfig.initialPageName = AppConfig.initialPage == null
        ? null
        : effectiveRouteNameBuilder(initialPage);

    AppConfig.defaultTransition = transition;
    AppConfig.defaultTransitionCurve = transitionCurve;
    AppConfig.defaultTransitionDuration = transitionDuration;

    AppConfig.shouldPreventDuplicates = preventDuplicates;
  }

  // ignore: avoid_setters_without_getters
  static set routeTypes(List<Type> routes) => routeTypes = routes;

  /// * [debugRequiredArguments] If used, [AppRouter] will check this before navigate
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
  ///
  /// * For example:
  /// ```
  /// AppRouter.define(
  ///   page: Enum.home,
  ///   requiredArgument: {
  ///     'id': int,
  ///     'name': String,
  ///   },
  ///   pageBuilder: (args) {
  ///     // ...
  ///   },
  /// );
  /// ```
  void define({
    required Enum page,
    Map<String, Object>? debugRequiredArguments,
    required Widget Function(Map<String, dynamic>? arguments) pageBuilder,
    RouteTransition? transition,
    TransitionBuilderDelegate? customTransitionBuilderDelegate,
    Duration? transitionDuration,
    Curve? curve,
    bool opaque = true,
    bool fullscreenDialog = false,
    bool? debugPreventDuplicates,
  }) {
    assert(debugAssertRouteTypeIsValid(page));

    AppConfig.routes.putIfAbsent(
      page,
      () => RouteConfig(
        debugRequiredArguments: debugRequiredArguments,
        pageBuilder: pageBuilder,
        transition: transition,
        customTransitionBuilderDelegate: customTransitionBuilderDelegate,
        transitionDuration: transitionDuration,
        curve: curve,
        opaque: opaque,
        fullscreenDialog: fullscreenDialog,
        debugPreventDuplicates: debugPreventDuplicates,
      ),
    );
  }

  static GlobalKey<NavigatorState>? _navigatorKey;

  static GlobalKey<NavigatorState> createNavigatorKeyIfNotExisted() =>
      _navigatorKey ??= GlobalKey<NavigatorState>();

  static NavigatorState? get currentNavigator => _navigatorKey?.currentState;
  static NavigatorState get navigator {
    try {
      return _navigatorKey!.currentState!;
    } catch (e) {
      throw StateError(
        "${e.toString()}. Maybe you did not call createNavigatorKeyIfNotExisted",
      );
    }
  }

  static SautRouteObserver? _routeObserver;

  static SautRouteObserver createRouteObserverIfNotExisted() =>
      _routeObserver ??= SautRouteObserver();

  static void subscribe(RouteAware routeAware, BuildContext context) {
    if (_routeObserver == null) routeObserverIsRequired();

    _routeObserver?.subscribe(routeAware, ModalRoute.of(context)!);
  }

  static void unsubscribe<R extends Route<dynamic>>(RouteAware routeAware) {
    if (_routeObserver == null) routeObserverIsRequired();

    _routeObserver?.unsubscribe(routeAware);
  }

  /// {@macro flutter.widgets.widgetsApp.onGenerateInitialRoutes}
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) => [
        createRouteFromName(initialRoute),
      ];

  /// {@macro flutter.widgets.widgetsApp.onUnknownRoute}
  static Route<dynamic>? onUnknownRoute(RouteSettings settings) =>
      createRouteFromName(settings.name, currentNavigator?.initialRoute);

  /// See also:
  /// https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#2-create-a-widget-that-extracts-the-arguments
  static Object? extractArguments(BuildContext context) =>
      context.extractArguments();

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
  static Future<T?> toPage<T extends Object?, B extends BlocBase<Object?>>(
    BuildContext context,
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
  }) =>
      (currentNavigator ?? Navigator.of(context)).toPage(
        page,
        arguments: arguments,
        blocValue: blocValue,
        blocProviders: blocProviders,
        transition: transition,
        customTransitionBuilderDelegate: customTransitionBuilderDelegate,
        curve: curve,
        duration: duration,
        opaque: opaque,
        fullscreenDialog: fullscreenDialog,
        debugPreventDuplicates: debugPreventDuplicates,
      );

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
  static Future<T?>?
      replaceWithPage<T extends Object?, B extends BlocBase<Object?>>(
    BuildContext context,
    Enum page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<BlocProviderSingleChildWidget>? blocProviders,
    TransitionBuilderDelegate? customTransitionBuilderDelegate,
    RouteTransition? transition,
    Curve? curve,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) =>
          (currentNavigator ?? Navigator.of(context)).replaceWithPage(
            page,
            arguments: arguments,
            blocValue: blocValue,
            blocProviders: blocProviders,
            transition: transition,
            customTransitionBuilderDelegate: customTransitionBuilderDelegate,
            curve: curve,
            duration: duration,
            opaque: opaque,
            fullscreenDialog: fullscreenDialog,
          );

  /// * [duration]
  ///
  /// The duration the transition going forwards.
  ///
  /// Return a [Future]. The Future resolves when back to previous page
  /// and the [Future]'s value is the [back] method's `result` parameter.
  static Future<T?>?
      replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
    BuildContext context,
    Enum page, {
    RoutePredicate? predicate,
    Map<String, dynamic>? arguments,
    RouteTransition? transition,
    TransitionBuilderDelegate? customTransitionBuilderDelegate,
    Curve? curve,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) =>
          (currentNavigator ?? Navigator.of(context)).replaceAllWithPage(
            page,
            predicate: predicate,
            arguments: arguments,
            transition: transition,
            customTransitionBuilderDelegate: customTransitionBuilderDelegate,
            curve: curve,
            duration: duration,
            opaque: opaque,
            fullscreenDialog: fullscreenDialog,
          );

  static RoutePredicate getModalRoutePredicate(Enum page) =>
      ModalRoute.withName(effectiveRouteNameBuilder(page));

  static void back<T>(
    BuildContext context, {
    T? result,
  }) =>
      (currentNavigator ?? Navigator.of(context)).back(result: result);

  static void backToPageName(BuildContext context, String name) =>
      (currentNavigator ?? Navigator.of(context)).backToPageName(name);

  static void backToPage(BuildContext context, Enum page) =>
      backToPageName(context, page.name);

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  static Route? getCurrentNavigatorRoute(BuildContext context) =>
      (currentNavigator ?? Navigator.of(context)).getCurrentNavigatorRoute();

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  static String? getCurrentNavigatorRouteName(BuildContext context) =>
      getCurrentNavigatorRoute(context)!.settings.name;
}
