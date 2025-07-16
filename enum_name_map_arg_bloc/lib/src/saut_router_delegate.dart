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

  final List<Page<dynamic>> _pages = [];

  late final List<NavigatorObserver> _navigatorObservers;

  /// The number of requests from the operating system that
  /// the current route be popped.
  int _willPopCount = 0;

  /// The number of requests from [Saut.back], [Saut.backToPage], ... API that
  /// the current route is popped.
  int _didPopCount = 0;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey, // needed to enable Android system Back button
      observers: _navigatorObservers,
      transitionDelegate: const DefaultTransitionDelegate<dynamic>(),
      pages: List.unmodifiable(_pages),
      onPopPage: _onPopPage,
    );
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    // using didPopCountModified as a flag to fix the issue (when using Flutter 3.7.12) that described below:
    // - Show a dialog by using imperative api (e.g. `showDialog`, `Navigator.of(context).push`)
    // - Back to the previous screen (by using Android back button or tap the barrier)
    // - Navigate to a new screen by using Saut api
    // - Back to the previous screen by using Android back button
    // - The same screen replaced the old one instead of showing the previous screen
    bool didPopCountModified = false;

    if (_didPopCount > 0) {
      didPopCountModified = true;
      _didPopCount--;
    }

    if (_willPopCount > 0) {
      _willPopCount--;
      _removeLastPage(result);
    } else if (!didPopCountModified) {
      // The request might come from [Navigator.pop] API
      _removeLastPage(result);
    }

    return route.didPop(result);
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
  Future<bool> popRoute() {
    final result = super.popRoute();

    _willPopCount++;

    return result;
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

  @protected
  LocalKey? getExistingPageKey(Enum page) {
    for (final e in _pages) {
      final pageKey = e.key;

      if (pageKey is SautPageKey) {
        final givenKey = pageKey.key;

        if (givenKey.value == page) {
          return pageKey;
        }
      } else if (pageKey is ValueKey && pageKey.value == page) {
        return pageKey;
      }
    }

    return null;
  }

  @protected
  void updateAddedPage(Page page) {
    _pages.add(page);
  }

  @protected
  void updateRemovedPageWhen(bool Function(Page element) test) {
    removeWhen(test);
  }

  @protected
  void setPages(Iterable<SautPage> pages) {
    // Convert [pages] to a [List]
    // in cases where [getExistingPageKey]
    // being call when creating this Iterable parameter,
    // it won't loop through the empty [_pages]
    final newPages = pages.toList();

    _pages
      ..clear()
      ..addAll(newPages);

    notifyListeners();
  }

  @protected
  void addPage(SautPage page) {
    _pages.add(page);

    notifyListeners();
  }

  @protected
  void replacePages(bool Function(Page element)? test, SautPage page) {
    if (test == null) {
      _pages.clear();
    } else {
      _removeUntil(test);
    }

    _pages.add(page);

    notifyListeners();
  }

  /// `TO` is the type of the return value of the old page (route).
  @protected
  void replaceLastPage<TO extends Object?>(SautPage page, TO value) {
    _removeLastPage(value);

    _pages.add(page);

    notifyListeners();
  }

  @protected
  void removeWhen(bool Function(Page element) test) {
    final oldPages = List.of(_pages);

    for (var i = oldPages.length - 1; i != -1; i--) {
      if (test(oldPages[i])) {
        final removed = _pages.removeAt(i);

        if (removed is SautPage) {
          removed.completeWith(null);
        }

        _didPopCount++;

        // print(_pages);

        notifyListeners();

        return;
      }
    }
  }

  @protected
  void removeUntil(bool Function(Page element) test) {
    bool hasAnyPageBeingRemoved = _removeUntil(test);

    if (hasAnyPageBeingRemoved) {
      notifyListeners();
    }
  }

  bool _removeUntil(bool Function(Page element) test) {
    final oldPages = List.of(_pages /* .value */);

    for (var i = oldPages.length - 1; i != -1; i--) {
      if (test(oldPages[i])) {
        return true;
      } else {
        final removed = _pages.removeAt(i);

        if (removed is SautPage) {
          removed.completeWith(null);
        }

        _didPopCount++;

        // print(_pages);
      }
    }

    return false;
  }

  @protected
  void removeLastPage<T extends Object?>(T value) {
    _removeLastPage(value);

    _didPopCount++;

    notifyListeners();
  }

  void _removeLastPage<T extends Object?>(T value) {
    final removed = _pages.removeLast();

    if (removed is SautPage) {
      removed.completeWith(value);
    }
  }
}

class _PagelessNavigatorObserver extends NavigatorObserver {
  _PagelessNavigatorObserver(this.routerDelegate);

  final SautRouterDelegate routerDelegate;

  /// The [Navigator] pushed `route`.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is AbstractSautPageRouteBuilder && route.createdFromSautPage) {
      return;
    }

    if (route.settings is SautPage) {
      return;
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
    if (route is AbstractSautPageRouteBuilder && route.createdFromSautPage) {
      return;
    }

    if (route.settings is SautPage) {
      return;
    }

    routerDelegate.updateRemovedPageWhen((e) {
      final bool isSautPageless = e is SautPageless;
      final bool match = isSautPageless ? e.route == route : e == route.settings;
      return match;
    });
  }
}
