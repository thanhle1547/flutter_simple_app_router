import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;

import 'app_config.dart';
import 'constants.dart';
import 'enma_build_context_extension.dart';
import 'enma_navigator_state_extension.dart';
import 'global.dart' as global;
import 'navigator_state_extension.dart';
import 'route.dart';
import 'route_config.dart';
import 'route_transition.dart';
import 'saut_page.dart';
import 'saut_router_delegate.dart';
import 'transition_builder_delegate.dart';

class Saut {
  /// * [routeTypes]
  ///
  /// For checking page has been defined each time navigating.
  ///
  /// * [initialPage]
  ///
  /// The page that will be used when failed to find defined page.
  ///
  /// * [routeNameBuilder]
  ///
  /// Transform the enum into the string that will shown
  /// in debug console/debug log.
  ///
  /// * [transition]
  ///
  /// Used to build the route's transitions.
  ///
  /// * [customTransitionBuilderDelegate]
  ///
  /// Used to build your own custom route's transitions.
  ///
  /// * [transitionDuration]
  ///
  /// The duration the transition going forwards.
  ///
  /// * [transitionCurve]
  ///
  /// An parametric animation easing curve,
  /// i.e. a mapping of the unit interval to the unit interval.
  ///
  /// * [debugPreventDuplicates]
  ///
  /// Prevent (accidentally) from navigating to the same page on `debug mode`.
  ///
  /// See also:
  ///
  ///  * [Curve], the interface implemented by the constants available from the
  ///    [Curves] class.
  ///  * [Curves], a collection of common animation easing curves.
  static void setDefaultConfig({
    List<Type>? routeTypes,
    Map<Object, RouteConfig>? routes,
    Map<Object, List<Object>>? stackedPages,
    required Object initialPage,
    String Function(Object page)? routeNameBuilder,
    RouteTransition? transition = RouteTransition.rightToLeft,
    Duration? transitionDuration = const Duration(milliseconds: 320),
    Curve? transitionCurve = Curves.easeOutQuad,
    bool debugPreventDuplicates = true,
  }) {
    if (routeTypes != null) AppConfig.routeTypes = routeTypes;

    if (routes != null) {
      AppConfig.routes
        ..clear()
        ..addAll(routes);
    }
    if (stackedPages != null) {
      AppConfig.stackedPages
        ..clear()
        ..addAll(stackedPages);
    }

    AppConfig.routeNameBuilder = routeNameBuilder;

    AppConfig.initialPage = initialPage;
    AppConfig.initialPageName = AppConfig.initialPage == null
        ? null
        : effectiveRouteNameBuilder(initialPage);

    AppConfig.defaultTransition = transition;
    AppConfig.defaultTransitionCurve = transitionCurve;
    AppConfig.defaultTransitionDuration = transitionDuration;

    AppConfig.shouldPreventDuplicates = debugPreventDuplicates;
  }

  static void reset() {
    AppConfig.routeTypes.clear();
    AppConfig.routes.clear();
    AppConfig.stackedPages.clear();
    AppConfig.routeNameBuilder = null;
    AppConfig.initialPage = null;
    AppConfig.initialPageName = null;
    AppConfig.defaultTransition = null;
    AppConfig.defaultTransitionCurve = null;
    AppConfig.defaultTransitionDuration = null;
    AppConfig.shouldPreventDuplicates = kDebugPreventDuplicates;
    global.routeObserver = null;
    global.disposeNavigatorKey();
    global.disposeRouterDelegate();
  }

  /// * [debugRequiredArguments]
  ///
  /// If used, [AppRouter] will check this before navigating
  /// The key is the name of the argument.
  ///
  /// The value is the type of argument. It can be anything but [dynamic].
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
  ///  * Notice `'val_4'` has value of `'List<int>'` (a String), not `List<int>`.
  /// Because dart analysis will show this error if we pass `List<int>`:
  /// `This requires the 'constructor-tearoffs' language feature to be enabled.`
  ///
  ///  * `'val_5'` has value of `9` (a certain number), this value will
  /// be treat as `runtimeType`
  ///
  /// * For example:
  ///
  /// ```dart
  /// AppRouter.define(
  ///   page: Object.home,
  ///   requiredArgument: {
  ///     'id': int,
  ///     'name': String,
  ///   },
  ///   pageBuilder: (args) {
  ///     // ...
  ///   },
  /// );
  /// ```
  ///
  /// * [pageBuilder]
  ///
  /// Used build the route's primary contents.
  ///
  /// * [transition]
  ///
  /// Used to build the route's transitions.
  ///
  /// * [customTransitionBuilderDelegate]
  ///
  /// Used to build your own custom route's transitions.
  ///
  /// * [transitionDuration]
  ///
  /// The duration the transition going forwards.
  ///
  /// * [curve]
  ///
  /// An parametric animation easing curve, i.e. a mapping of the unit interval to
  /// the unit interval.
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
  /// See also:
  ///
  ///  * [Curve], the interface implemented by the constants available from the
  ///    [Curves] class.
  ///  * [Curves], a collection of common animation easing curves.
  void define({
    required Object page,
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

  static GlobalKey<NavigatorState> createNavigatorKeyIfNotExisted() =>
      global.createNavigatorKeyIfNotExisted();

  static NavigatorState? get currentNavigator => global.currentNavigatorState;
  static NavigatorState get navigator {
    try {
      return global.currentNavigatorState!;
    } catch (e) {
      throw StateError(
        "${e.toString()}. Maybe you did not call createNavigatorKeyIfNotExisted",
      );
    }
  }

  /// Subscribe [routeAware] to be informed about changes to [route].
  ///
  /// Going forward, [routeAware] will be informed about qualifying changes
  /// to [route], e.g. when [route] is covered by another route or when [route]
  /// is popped off the [Navigator] stack.
  static void subscribe(RouteAware routeAware, BuildContext context) {
    if (global.routeObserver == null) routeObserverIsRequired();

    global.routeObserver!.subscribe(routeAware, ModalRoute.of(context)!);
  }

  /// Unsubscribe [routeAware].
  ///
  /// [routeAware] is no longer informed about changes to its route. If the given argument was
  /// subscribed to multiple types, this will unregister it (once) from each type.
  static void unsubscribe<R extends Route<dynamic>>(RouteAware routeAware) {
    if (global.routeObserver == null) routeObserverIsRequired();

    global.routeObserver!.unsubscribe(routeAware);
  }

  /// Register [routeAware] to be informed about route changes.
  ///
  /// Going forward, [routeAware] will be informed via `didPushNext`.
  ///
  /// When a route is popped off the [Navigator] stack,
  /// [routeAware] will be informed via `didPopNext`
  static void addListener(RouteAware routeAware) {
    if (global.routeObserver == null) routeObserverIsRequired();

    global.routeObserver!.addListener(routeAware);
  }

  /// Remove a previously registered [routeAware].
  ///
  /// If the given listener is not registered, the call is ignored.
  static void removeListener(RouteAware routeAware) {
    if (global.routeObserver == null) routeObserverIsRequired();

    global.routeObserver!.removeListener(routeAware);
  }

  /// {@macro flutter.widgets.widgetsApp.onGenerateInitialRoutes}
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) => [
        createRouteFromName(initialRoute),
      ];

  /// {@macro flutter.widgets.widgetsApp.onUnknownRoute}
  static Route<dynamic>? onUnknownRoute(RouteSettings settings) =>
      createRouteFromName(settings.name, currentNavigator?.initialRoute);

  /// [navigatorObservers]
  ///
  /// {@macro flutter.widgets.widgetsApp.navigatorObservers}
  ///
  /// If [initialPage] is null, then the one passed to [setDefaultConfig]
  /// will be used instead.
  ///
  /// If [initialPageStackName] is not null and [arguments] is null, an empty
  /// [Map] will be created
  static SautRouterDelegate createRouterDelegateIfNotExisted({
    List<NavigatorObserver>? navigatorObservers,
    Object? initialPage,
    Object? initialPageStackName,
    Map<String, dynamic>? arguments,
  }) {
    if (global.routerDelegate == null) {
      assert(() {
        final initialPageStack = AppConfig.stackedPages[initialPageStackName];

        if (initialPageStack != null) return initialPageStack.isNotEmpty;

        return initialPage != null;
      }());

      global.initRouterDelegate(
        navigatorObservers: navigatorObservers,
      );

      if (initialPageStackName != null) {
        global.currentRouterDelegate.setPageStack(
          initialPageStackName,
          arguments ?? {},
        );
      } else {
        assert(initialPage == null || AppConfig.initialPage == null);

        global.currentRouterDelegate.toPage(
          initialPage ?? AppConfig.initialPage!,
          arguments: arguments,
        );
      }
    }

    return global.currentRouterDelegate;
  }

  /// Remove all the pages with new pages
  static void setPageStack(
    Object stackName,
    Map<String, dynamic>? arguments,
  ) {
    assert(debugAssertRouterDelegateExist());

    global.currentRouterDelegate.setPageStack(stackName, arguments);
  }

  /// Create [RouteSettings] for [showDialog], [showAboutDialog],
  /// [showGeneralDialog], ...
  ///
  /// There will be an exception from `widget library` (with content: `
  /// A page-based route should not be added using the imperative api.
  /// Provide a new list with the corresponding Page to Navigator.pages instead.
  /// `), but it won't affect navigating/routing.
  static RouteSettings createRouteSettings({
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return SautPageless(
      name: name,
      arguments: arguments,
      restorationId: restorationId,
    );
  }

  /// This function use [ModalRoute.of(context)?.settings.arguments] internally
  ///
  /// See also:
  /// https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#2-create-a-widget-that-extracts-the-arguments
  static Object? extractArguments(BuildContext context) =>
      context.extractArguments();

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
  static Future<T?> toPage<T extends Object?, B extends BlocBase<Object?>>(
    BuildContext context,
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
  static Future<T?>? replaceWithPage<T extends Object?,
          B extends BlocBase<Object?>, TO extends Object?>(
    BuildContext context,
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
  }) =>
      (currentNavigator ?? Navigator.of(context)).replaceWithPage(
        page,
        arguments: arguments,
        blocValue: blocValue,
        blocProviders: blocProviders,
        result: result,
        transition: transition,
        customTransitionBuilderDelegate: customTransitionBuilderDelegate,
        curve: curve,
        duration: duration,
        opaque: opaque,
        fullscreenDialog: fullscreenDialog,
      );

  /// [routePredicate]
  ///
  /// To remove routes until a route with a certain name,
  /// use the [RoutePredicate] returned from [Saut.getModalRoutePredicate].
  ///
  /// To remove all the routes the replaced route, simply let [routePredicate] null.
  ///
  /// [pagePredicate]
  ///
  /// To remove pages until a page with a certain name when created an app
  /// ([MaterialApp], [CupertinoApp]) that uses the [Router]
  /// instead of a [Navigator].
  ///
  /// Use the [PagePredicate] returned from [Saut.getPagePredicate].
  ///
  /// To remove all the pages the replaced page, simply let [pagePredicate] null.
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
  static Future<T?>?
      replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
    BuildContext context,
    Object page, {
    RoutePredicate? routePredicate,
    PagePredicate? pagePredicate,
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
            routePredicate: routePredicate,
            pagePredicate: pagePredicate,
            arguments: arguments,
            transition: transition,
            customTransitionBuilderDelegate: customTransitionBuilderDelegate,
            curve: curve,
            duration: duration,
            opaque: opaque,
            fullscreenDialog: fullscreenDialog,
          );

  /// Returns a predicate that's true if the route has the specified name and if
  /// popping the route will not yield the same route
  ///
  /// This function is typically used with [Saut.replaceAllWithPage()], [Navigator.popUntil()].
  ///
  /// This function use [ModalRoute.withName()] internally.
  static RoutePredicate getModalRoutePredicate(Object page) =>
      ModalRoute.withName(effectiveRouteNameBuilder(page));

  /// Returns a predicate that's true if the page has the specified name and if
  /// popping the page will not yield the same page
  ///
  /// This function is typically used with [Saut.replaceAllWithPage()], [Navigator.popUntil()].
  static PagePredicate getPagePredicate(Object page) {
    final pageName = effectiveRouteNameBuilder(page);

    return (Page<dynamic> page) {
      if (page is SautPageless) {
        return !page.route.willHandlePopInternally && page.name == pageName;
      }

      return page.name == pageName;
    };
  }

  /// The `T` type argument is the type of the return value of the popped route.
  ///
  /// The type of `result`, if provided,
  /// must match the type argument of the class of the popped route (`T`).
  ///
  /// See [Navigator.pop] for more details of the semantics of popping a route.
  @optionalTypeArgs
  static void back<T extends Object?>(
    BuildContext context, {
    T? result,
  }) =>
      (currentNavigator ?? Navigator.of(context)).back(result: result);

  /// Calls [back] repeatedly until found the page with a certain name.
  static void backToPageName(BuildContext context, String name) =>
      (currentNavigator ?? Navigator.of(context)).backToPageName(name);

  /// Calls [back] repeatedly until found the page.
  static void backToPage(BuildContext context, Object page) =>
      backToPageName(context, effectiveRouteNameBuilder(page));

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  static Route? getCurrentRoute(BuildContext context) =>
      (currentNavigator ?? Navigator.of(context)).getCurrentRoute();

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  static String? getCurrentRouteName(BuildContext context) =>
      getCurrentRoute(context)!.settings.name;
}
