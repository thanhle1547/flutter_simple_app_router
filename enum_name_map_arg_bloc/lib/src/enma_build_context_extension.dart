import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;

import 'app_config.dart';
import 'enma_saut_router_delegate_extension.dart';
import 'global.dart' as global;
import 'internal.dart';
import 'route_config.dart';
import 'saut_page.dart';

extension EnmaBuildContextExtension on BuildContext {
  /// Remove all the pages with new pages
  void setPageStack(Object stackName, Map<String, dynamic>? arguments) {
    assert(debugAssertRouterDelegateExist());

    global.currentRouterDelegate.setPageStack(
      AppConfig.stackedPages[stackName]!,
      arguments,
    );
  }

  /// This function use [ModalRoute.of(context)?.settings.arguments] internally
  ///
  /// See also:
  /// https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#2-create-a-widget-that-extracts-the-arguments
  Object? extractArguments() => ModalRoute.of(this)?.settings.arguments;

  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to the new page.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to the new page.
  ///
  /// * [transitionsBuilder]
  ///
  /// Used to build the route's transition animation.
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
  @optionalTypeArgs
  Future<T?> toPage<T extends Object?, B extends BlocBase<Object?>>(
    Enum page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<BlocProviderSingleChildWidget>? blocProviders,
    PageTransitionsBuilder? transitionsBuilder,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
    bool? debugPreventDuplicates,
  }) {
    if (global.useRouter) {
      return global.currentRouterDelegate.toPage(
        this,
        page,
        arguments: arguments,
        blocValue: blocValue,
        blocProviders: blocProviders,
        transitionsBuilder: transitionsBuilder,
        duration: duration,
        opaque: opaque,
        fullscreenDialog: fullscreenDialog,
        debugPreventDuplicates: debugPreventDuplicates,
      );
    }

    final navigator = Navigator.maybeOf(this) ?? global.currentNavigatorState!;

    return navigator._toPage(
      this,
      page,
      arguments: arguments,
      blocValue: blocValue,
      blocProviders: blocProviders,
      transitionsBuilder: transitionsBuilder,
      duration: duration,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
      debugPreventDuplicates: debugPreventDuplicates,
    );
  }

  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to the new page.
  ///
  /// __Warning__: `SAUT` won't automatically handle closing the bloc.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to the new page.
  ///
  /// * [result]
  ///
  /// If non-null, `result` will be used as the result of the route that is removed;
  /// the future that had been returned from pushing that old route
  /// will complete with result. The type of `result`, if provided,
  /// must match the type argument of the class of the old route (`TO`).
  ///
  /// * [transitionsBuilder]
  ///
  /// Used to build the route's transition animation.
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
  @optionalTypeArgs
  Future<T?> replaceWithPage<T extends Object?, B extends BlocBase<Object?>, TO extends Object?>(
    Enum page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<BlocProviderSingleChildWidget>? blocProviders,
    TO? result,
    PageTransitionsBuilder? transitionsBuilder,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) {
    if (global.useRouter) {
      return global.currentRouterDelegate.replaceWithPage(
        this,
        page,
        arguments: arguments,
        blocValue: blocValue,
        blocProviders: blocProviders,
        result: result,
        transitionsBuilder: transitionsBuilder,
        duration: duration,
        opaque: opaque,
        fullscreenDialog: fullscreenDialog,
      );
    }

    final navigator = global.currentNavigatorState ?? Navigator.of(this);

    return navigator._replaceWithPage(
      this,
      page,
      arguments: arguments,
      blocValue: blocValue,
      blocProviders: blocProviders,
      result: result,
      transitionsBuilder: transitionsBuilder,
      duration: duration,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
    );
  }

  /// [routePredicate]
  ///
  /// The predicate may be applied to the same route more than once if
  /// [Route.willHandlePopInternally] is true.
  ///
  /// To remove routes until a route with a certain name,
  /// use the [RoutePredicate] returned from [Saut.getModalRoutePredicate].
  ///
  /// To remove all the routes the replaced route,
  /// simply let [routePredicate] null,
  /// or use a [RoutePredicate] that always returns false
  /// (e.g. `(Route<dynamic> route) => false`).
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
  /// * [transitionsBuilder]
  ///
  /// Used to build the route's transition animation.
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
  @optionalTypeArgs
  Future<T?> replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
    Enum page, {
    RoutePredicate? routePredicate,
    PagePredicate? pagePredicate,
    Map<String, dynamic>? arguments,
    PageTransitionsBuilder? transitionsBuilder,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) {
    if (global.useRouter) {
      return global.currentRouterDelegate.replaceAllWithPage(
        this,
        page,
        predicate: pagePredicate,
        arguments: arguments,
        transitionsBuilder: transitionsBuilder,
        duration: duration,
        opaque: opaque,
        fullscreenDialog: fullscreenDialog,
      );
    }

    final navigator = global.currentNavigatorState ?? Navigator.of(this);

    return navigator._replaceAllWithPage(
      this,
      page,
      predicate: routePredicate,
      arguments: arguments,
      transitionsBuilder: transitionsBuilder,
      duration: duration,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
    );
  }

  /// The [name], [page] parameters are used to
  /// create [RouteSettings.name] and the page key.
  Future<T?> toUnconfiguredPage<T extends Object?>({
    required BuildContext context,
    String? name,
    Enum? page,
    required RouteConfig routeConfig,
  }) {
    assert(name != null || page != null);

    final SautPage<T> sautPage = SautPage(
      key: SautPageKey(page ?? name),
      context: context,
      pageBuilder: () => routeConfig.pageBuilder(null),
      name: name ?? effectiveRouteNameBuilder(page!),
      routeConfig: routeConfig,
    );

    if (global.useRouter) {
      return global.currentRouterDelegate.add<T>(sautPage);
    }

    final navigator = Navigator.maybeOf(this) ?? global.currentNavigatorState!;

    return navigator.push<T>(
      sautPage.createRoute(context),
    );
  }

  /// The `T` type argument is the type of the return value of the popped route.
  ///
  /// The type of `result`, if provided,
  /// must match the type argument of the class of the popped route (`T`).
  ///
  /// See [Navigator.pop] for more details of the semantics of popping a route.
  @optionalTypeArgs
  void back<T extends Object?>({T? result}) {
    if (global.useRouter) {
      global.currentRouterDelegate.back(result: result);
    }

    final navigator = Navigator.maybeOf(this) ?? global.currentNavigatorState!;

    navigator.pop<T>(result);
  }

  /// Calls [back] repeatedly until found the page with a certain name.
  void backToPageName(String name) {
    if (global.useRouter) {
      global.currentRouterDelegate.backToPageName(name);
    }

    final navigator = Navigator.maybeOf(this) ?? global.currentNavigatorState!;

    navigator.popUntil((route) {
      if (route is DialogRoute) return false;

      final String? routeName = route.settings.name;

      return routeName == name ||
          (AppConfig.initialPageName != null && routeName == AppConfig.initialPageName);
    });
  }

  /// Calls [back] repeatedly until found the page.
  void backToPage(Enum page) {
    if (global.useRouter) {
      global.currentRouterDelegate.backToPage(page);
    }

    backToPageName(
      effectiveRouteNameBuilder(page),
    );
  }

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  Route? getCurrentRoute() {
    final navigator = Navigator.maybeOf(this) ?? global.currentNavigatorState!;

    return navigator._getCurrentRoute();
  }

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  String? getCurrentRouteName() {
    final navigator = Navigator.maybeOf(this) ?? global.currentNavigatorState!;

    return navigator._getCurrentRouteName();
  }
}

extension on NavigatorState {
  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to the new page.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to the new page.
  ///
  /// * [transitionsBuilder]
  ///
  /// Used to build the route's transition animation.
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
  @optionalTypeArgs
  Future<T?> _toPage<T extends Object?, B extends BlocBase<Object?>>(
    BuildContext context,
    Enum page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<BlocProviderSingleChildWidget>? blocProviders,
    PageTransitionsBuilder? transitionsBuilder,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
    bool? debugPreventDuplicates,
  }) {
    assert(debugAssertRouteTypeIsValid(page));

    final RouteConfig routeConfig = getRouteConfig(page).copyWith(
      transitionsBuilder: transitionsBuilder,
      transitionDuration: duration,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
      debugPreventDuplicates: debugPreventDuplicates,
    );

    final String name = effectiveRouteNameBuilder(page);

    assert(() {
      if ((debugPreventDuplicates ??
              routeConfig.debugPreventDuplicates ??
              AppConfig.shouldPreventDuplicates) &&
          _getCurrentRouteName() == name) {
        final String runtimeType = objectRuntimeType(page, 'String');

        throw StateError("Duplicated Page: $runtimeType");
      }

      return true;
    }());

    return push<T>(
      createRoute<T>(
        pageBuilder: resolvePageBuilderWithBloc(
          pageBuilder: getPageBuilder(routeConfig, arguments),
          blocValue: blocValue,
          blocProviders: blocProviders,
        ),
        config: routeConfig,
        settings: RouteSettings(
          name: name,
          arguments: arguments,
        ),
        context: context,
      ),
    );
  }

  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to the new page.
  ///
  /// __Warning__: `SAUT` won't automatically handle closing the bloc.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to the new page.
  ///
  /// * [result]
  ///
  /// If non-null, `result` will be used as the result of the route that is removed;
  /// the future that had been returned from pushing that old route
  /// will complete with result. The type of `result`, if provided,
  /// must match the type argument of the class of the old route (`TO`).
  ///
  /// * [transitionsBuilder]
  ///
  /// Used to build the route's transition animation.
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
  @optionalTypeArgs
  Future<T?> _replaceWithPage<T extends Object?, B extends BlocBase<Object?>, TO extends Object?>(
    BuildContext context,
    Enum page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<BlocProviderSingleChildWidget>? blocProviders,
    TO? result,
    PageTransitionsBuilder? transitionsBuilder,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) {
    assert(debugAssertRouteTypeIsValid(page));

    final RouteConfig routeConfig = getRouteConfig(page).copyWith(
      transitionsBuilder: transitionsBuilder,
      transitionDuration: duration,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
    );

    return pushReplacement(
      createRoute<T>(
        pageBuilder: resolvePageBuilderWithBloc(
          pageBuilder: getPageBuilder(routeConfig, arguments),
          blocValue: blocValue,
          blocProviders: blocProviders,
        ),
        config: routeConfig,
        settings: RouteSettings(
          name: effectiveRouteNameBuilder(page),
          arguments: arguments,
        ),
        context: context,
      ),
      result: result,
    );
  }

  /// [predicate]
  ///
  /// The predicate may be applied to the same route more than once if
  /// [Route.willHandlePopInternally] is true.
  ///
  /// To remove routes until a route with a certain name,
  /// use the [RoutePredicate] returned from [Saut.getModalRoutePredicate].
  ///
  /// To remove all the routes the replaced route,
  /// simply let [routePredicate] null,
  /// or use a [RoutePredicate] that always returns false
  /// (e.g. `(Route<dynamic> route) => false`).
  ///
  /// * [transitionsBuilder]
  ///
  /// Used to build the route's transition animation.
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
  @optionalTypeArgs
  Future<T?> _replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
    BuildContext context,
    Enum page, {
    RoutePredicate? predicate,
    Map<String, dynamic>? arguments,
    PageTransitionsBuilder? transitionsBuilder,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) {
    assert(debugAssertRouteTypeIsValid(page));

    final RouteConfig routeConfig = getRouteConfig(page).copyWith(
      transitionsBuilder: transitionsBuilder,
      transitionDuration: duration,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
    );

    return pushAndRemoveUntil(
      createRoute<T>(
        pageBuilder: getPageBuilder(routeConfig, arguments),
        config: routeConfig,
        settings: RouteSettings(
          name: effectiveRouteNameBuilder(page),
          arguments: arguments,
        ),
        context: context,
      ),
      predicate ?? (Route<dynamic> _) => false,
    );
  }

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  Route? _getCurrentRoute() {
    Route? currentRoute;

    popUntil((route) {
      currentRoute = route;
      return true;
    });

    return currentRoute;
  }

  String? _getCurrentRouteName() {
    return _getCurrentRoute()?.settings.name;
  }
}
