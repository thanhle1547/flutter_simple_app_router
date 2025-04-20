import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;

import 'app_config.dart';
import 'global.dart' as global;
import 'internal.dart';
import 'route_config.dart';
import 'saut_page.dart';
import 'saut_router_delegate.dart';

extension EnmaNavigatorStateExtension on NavigatorState {
  /// Remove all the pages with new pages
  void setPageStack(Object stackName, Map<String, dynamic>? arguments) {
    assert(debugAssertRouterDelegateExist());

    if (AppConfig.stackedPages[stackName] == null) {
      throw StateError("Stack name: $stackName not found");
    }

    global.currentRouterDelegate._setPageStack(
      AppConfig.stackedPages[stackName]!,
      arguments,
    );
  }

  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to a new page.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to a new page.
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

    return _toPage(
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
  Future<T?>? replaceWithPage<T extends Object?, B extends BlocBase<Object?>,
      TO extends Object?>(
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

    return _replaceWithPage(
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
  Future<T?>?
      replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
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
        page,
        predicate: pagePredicate,
        arguments: arguments,
        transitionsBuilder: transitionsBuilder,
        duration: duration,
        opaque: opaque,
        fullscreenDialog: fullscreenDialog,
      );
    }

    return _replaceAllWithPage(
      page,
      predicate: routePredicate,
      arguments: arguments,
      transitionsBuilder: transitionsBuilder,
      duration: duration,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
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

    _back(result: result);
  }

  /// Calls [back] repeatedly until found the page with a certain name.
  void backToPageName(String name) {
    if (global.useRouter) {
      global.currentRouterDelegate.backToPageName(name);
    }

    _backToPageName(name);
  }

  /// Calls [back] repeatedly until found the page.
  void backToPage(Enum page) {
    if (global.useRouter) {
      global.currentRouterDelegate.backToPage(page);
    }

    _backToPage(page);
  }

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  Route? getCurrentRoute() => _getCurrentRoute();

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  String? getCurrentRouteName() => _getCurrentRouteName();
}

extension on NavigatorState {
  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to a new page.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to a new page.
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
          getCurrentRouteName() == name) {
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
  Future<T?>? _replaceWithPage<T extends Object?, B extends BlocBase<Object?>,
      TO extends Object?>(
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
  Future<T?>?
      _replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
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
  void _back<T extends Object?>({T? result}) => pop(result);

  /// Calls [back] repeatedly until found the page with a certain name.
  void _backToPageName(String name) => popUntil((route) {
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
  void _backToPage(Enum page) => backToPageName(
        effectiveRouteNameBuilder(page),
      );

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

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  String? _getCurrentRouteName() => getCurrentRoute()!.settings.name;
}

extension SautRouterDelegateExtension on SautRouterDelegate {
  /// Remove all the pages with new pages
  void setPageStack(Object stackName, Map<String, dynamic>? arguments) {
    if (AppConfig.stackedPages[stackName] == null) {
      throw StateError("Stack name: $stackName not found");
    }

    _setPageStack(AppConfig.stackedPages[stackName]!, arguments);
  }

  void _setPageStack(
    List<Enum> pageNames,
    Map<String, dynamic>? arguments,
  ) {
    // ignore: invalid_use_of_protected_member
    setPages(pageNames.map((e) {
      final RouteConfig routeConfig = getRouteConfig(e);

      return SautPage(
        // ignore: invalid_use_of_protected_member
        key: getExistingPageKey(e) ?? SautPageKey(e),
        name: effectiveRouteNameBuilder(e),
        pageBuilder: getPageBuilder(routeConfig, arguments),
        arguments: arguments,
        routeConfig: routeConfig,
      );
    }));
  }

  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to a new page.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to a new page.
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
          global.routerDelegate!.lastPageName == name) {
        final String runtimeType = objectRuntimeType(page, 'String');

        throw StateError("Duplicated Page: $runtimeType");
      }

      return true;
    }());

    final pageRoute = SautPage<T>(
      key: SautPageKey(page),
      name: name,
      pageBuilder: resolvePageBuilderWithBloc(
        pageBuilder: getPageBuilder(routeConfig, arguments),
        blocValue: blocValue,
        blocProviders: blocProviders,
      ),
      arguments: arguments,
      routeConfig: routeConfig,
    );

    // ignore: invalid_use_of_protected_member
    addPage(pageRoute);

    return pageRoute.completed;
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
  Future<T?>? replaceWithPage<T extends Object?, B extends BlocBase<Object?>,
      TO extends Object?>(
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

    final pageRoute = SautPage<T>(
      key: SautPageKey(page),
      name: effectiveRouteNameBuilder(page),
      pageBuilder: resolvePageBuilderWithBloc(
        pageBuilder: getPageBuilder(routeConfig, arguments),
        blocValue: blocValue,
        blocProviders: blocProviders,
      ),
      arguments: arguments,
      routeConfig: routeConfig,
    );

    // ignore: invalid_use_of_protected_member
    replaceLastPage(pageRoute, result);

    return pageRoute.completed;
  }

  /// [predicate]
  ///
  /// To remove pages until a page with a certain name,
  /// use the [PagePredicate] returned from [Saut.getPagePredicate].
  ///
  /// To remove all the pages the replaced page, simply let [predicate] null.
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
  Future<T?>?
      replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
    Enum page, {
    PagePredicate? predicate,
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

    final pageRoute = SautPage<T>(
      key: SautPageKey(page),
      name: effectiveRouteNameBuilder(page),
      pageBuilder: getPageBuilder(routeConfig, arguments),
      arguments: arguments,
      routeConfig: routeConfig,
    );

    // ignore: invalid_use_of_protected_member
    replacePages(predicate, pageRoute);

    return pageRoute.completed;
  }

  /// The `T` type argument is the type of the return value of the popped route.
  ///
  /// The type of `result`, if provided,
  /// must match the type argument of the class of the popped route (`T`).
  ///
  /// See [Navigator.pop] for more details of the semantics of popping a route.
  @optionalTypeArgs
  void back<T>({T? result}) {
    // ignore: invalid_use_of_protected_member
    removeLastPage(result);
  }

  /// Calls [back] repeatedly until found the page with a certain name.
  void backToPageName(String name) {
    // ignore: invalid_use_of_protected_member
    removeUntil((page) => page.name == name);
  }

  /// Calls [back] repeatedly until found the page.
  void backToPage(Enum page) => backToPageName(
        effectiveRouteNameBuilder(page),
      );

  String? getCurrentPageName() => lastPageName;
}
