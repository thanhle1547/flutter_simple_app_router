import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:saut_enma_bloc/src/constants.dart';

import 'global.dart' as global;
import 'saut_page.dart';
import 'saut_page_route_builder.dart';

class SautRouterDelegate extends RouterDelegate<RouteInformation>
    with PopNavigatorRouterDelegateMixin<RouteInformation>, ChangeNotifier {
  SautRouterDelegate({List<NavigatorObserver>? navigatorObservers}) {
    _navigatorObservers = [
      ...?navigatorObservers,
      _PagelessNavigatorObserver(this),
    ];
  }

  late final List<NavigatorObserver> _navigatorObservers;

  final TransitionDelegate _transitionDelegate =
      const DefaultTransitionDelegate<dynamic>();

  final List<Page<dynamic>> _pages = [];

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey, // needed to enable Android system Back button
      observers: _navigatorObservers,
      transitionDelegate: _transitionDelegate,
      pages: List.unmodifiable(_pages),
      onPopPage: _onPopPage,
    );
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    removeLastPage(result);

    return !route.didPop(result);
  }

  NavigatorState get navigator => global.currentNavigatorState!;

  @override
  GlobalKey<NavigatorState>? get navigatorKey =>
      global.createNavigatorKeyIfNotExisted();

  @override
  SynchronousFuture<void> setNewRoutePath(RouteInformation configuration) {
    return SynchronousFuture(null);
  }

  @override
  RouteInformation? get currentConfiguration {
    return RouteInformation(
      location: lastPageName,
    );
  }

  String? get lastPageName {
    if (_pages.isEmpty) return null;

    return _pages.last.name;
  }

  /// To optimize [_PagelessNavigatorObserver.didPush] method
  late List<Page<dynamic>> _pagesFromSetMethod = const [];

  @protected
  void setPages(Iterable<SautPage> pages) {
    _pages
      ..clear()
      ..addAll(pages);

    _pagesFromSetMethod = List.of(_pages);

    notifyListeners();
  }

  @protected
  void addPage(SautPage page) {
    _pages.add(page);

    notifyListeners();
  }

  @protected
  void updateAddedPage(Page page) {
    _pages.add(page);
  }

  @protected
  void replacePages(bool Function(Page element)? test, SautPage page) {
    if (test == null) {
      _pages.clear();
    } else {
      _pages.removeWhere(test);
    }

    _pages.add(page);

    notifyListeners();
  }

  @protected
  void replaceLastPage(SautPage page) {
    _pages
      ..removeLast()
      ..add(page);

    notifyListeners();
  }

  @protected
  void removeWhere(bool Function(Page element) test) {
    _removeWhere(test, onlyFirst: false);

    notifyListeners();
  }

  @protected
  void updateRemovedPageWhere(bool Function(Page element) test) {
    _removeWhere(test, onlyFirst: true);
  }

  void _removeWhere(
    bool Function(Page element) test, {
    required bool onlyFirst,
  }) {
    final oldPages = List.of(_pages);

    for (var i = oldPages.length - 1; i > 0; i--) {
      if (test(oldPages[i])) {
        _pages.removeAt(i);

        if (onlyFirst) return;
      }
    }
  }

  @protected
  void removeLastPage<T extends Object?>(T value) {
    final removed = _pages.removeLast();

    if (removed is SautPage) {
      removed.completeWith(value);
    }

    notifyListeners();
  }
}

class _PagelessNavigatorObserver extends NavigatorObserver {
  _PagelessNavigatorObserver(this.routerDelegate);

  final SautRouterDelegate routerDelegate;

  /// The [Navigator] pushed `route`.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is SautPageRouteBuilder && route.createdFromSautPage) {
      return;
    }

    final List<Page<dynamic>> pages = routerDelegate._pagesFromSetMethod;

    if (pages.isNotEmpty) {
      for (final Page page in routerDelegate._pages) {
        if (page == route.settings) {
          pages.remove(page);
          return;
        }

        pages.remove(page);
      }
    }

    if (route.settings is SautPageless) {
      final page = route.settings as SautPageless;
      page.route = route;

      routerDelegate.updateAddedPage(page);
    } else {
      if (kDebugMode) {
        log(
          'Warning!!! RouteSettings should be created '
          'from [Saut.createRouteSettings]. When you navigate to the next '
          'page (or screen), Flutter will throw an error.',
          name: source,
        );
      }

      routerDelegate.updateAddedPage(SautPageless(
        name: route.settings.name,
        arguments: route.settings.arguments,
        restorationId: route.restorationScopeId.value,
      )..route = route);
    }
  }

  /// The [Navigator] popped `route`.
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is SautPageRouteBuilder && route.createdFromSautPage) {
      return;
    }

    routerDelegate.updateRemovedPageWhere((e) {
      return e is SautPageless ? e.route == route : e == route.settings;
    });
  }
}
