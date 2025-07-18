import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart' show SingleChildWidget;

import 'app_config.dart';
import 'global.dart' as global;
import 'internal.dart';
import 'route_config.dart';
import 'saut_page.dart';
import 'saut_router_delegate.dart';

extension SautRouterDelegateExtension on SautRouterDelegate {
  /// Remove all the pages with new pages
  void setPageStack(
    BuildContext context,
    Object stackName, {
    Map<String, dynamic>? arguments,
  }) {
    if (AppConfig.stackedPages[stackName] == null) {
      throw StateError("Stack name: $stackName not found");
    }

    clearAndAppendPages(
      context,
      AppConfig.stackedPages[stackName]!,
      arguments: arguments,
    );
  }

  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to the new page.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to the new page.
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
    BuildContext context,
    Enum page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<SingleChildWidget>? blocProviders,
    bool? debugPreventDuplicates,
  }) {
    final RouteConfig routeConfig = getRouteConfig(page).copyWith(
      debugPreventDuplicates: debugPreventDuplicates,
    );

    final String name = getRouteName(page);

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
      context: context,
      name: name,
      page: maybeWrapWithBlocProviders(
        page: getPage(routeConfig, arguments),
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
  /// The `T` type argument is the type of the return value of the new route,
  /// and `TO` is the type of the return value of the old route.
  @optionalTypeArgs
  Future<T?> replaceWithPage<T extends Object?, B extends BlocBase<Object?>, TO extends Object?>(
    BuildContext context,
    Enum page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<SingleChildWidget>? blocProviders,
    TO? result,
  }) {
    final RouteConfig routeConfig = getRouteConfig(page);

    final pageRoute = SautPage<T>(
      key: SautPageKey(page),
      context: context,
      name: getRouteName(page),
      page: maybeWrapWithBlocProviders(
        page: getPage(routeConfig, arguments),
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
  /// The T type argument is the type of the return value of the new route.
  @optionalTypeArgs
  Future<T?> replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
    BuildContext context,
    Enum page, {
    PagePredicate? predicate,
    Map<String, dynamic>? arguments,
  }) {
    final RouteConfig routeConfig = getRouteConfig(page);

    final pageRoute = SautPage<T>(
      key: SautPageKey(page),
      context: context,
      name: getRouteName(page),
      page: getPage(routeConfig, arguments),
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
  void backToPage(Enum page) {
    backToPageName(
      getRouteName(page),
    );
  }

  String? getCurrentPageName() => lastPageName;
}

extension InternalSautRouterDelegateExtension on SautRouterDelegate {
  void clearAndAppendPages(
    BuildContext? context,
    List<Enum> pageNames, {
    Map<String, dynamic>? arguments,
  }) {
    // ignore: invalid_use_of_protected_member
    setPages(pageNames.map((e) {
      final RouteConfig routeConfig = getRouteConfig(e);

      return SautPage(
        // ignore: invalid_use_of_protected_member
        key: getExistingPageKey(e) ?? SautPageKey(e),
        context: context,
        name: getRouteName(e),
        page: getPage(routeConfig, arguments),
        arguments: arguments,
        routeConfig: routeConfig,
      );
    }));
  }

  Future<T?> add<T extends Object?>(SautPage<T> page) {
    // ignore: invalid_use_of_protected_member
    addPage(page);

    return page.completed;
  }
}
