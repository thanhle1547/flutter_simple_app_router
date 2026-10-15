import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:saut_enma_bloc/src/constants.dart';

import 'global.dart' as global;
import 'saut_page.dart';
import 'saut_page_route_builder.dart';

typedef SystemRouteReportHandler = void Function(
  RouteInformation configuration, 
  VoidCallback update,
);

class SautRouterDelegate extends RouterDelegate<RouteInformation>
    with PopNavigatorRouterDelegateMixin<RouteInformation>, ChangeNotifier {
  SautRouterDelegate({
    List<NavigatorObserver>? navigatorObservers,
    this.onSetInitialRoutePath,
    this.onSetNewRoutePath,
    this.systemRouteReportHandler,
  }) {
    _navigatorObservers = [
      ...?navigatorObservers,
      _PagelessNavigatorObserver(this),
    ];
  }

  final ValueSetter<RouteInformation>? onSetInitialRoutePath;
  final ValueSetter<RouteInformation>? onSetNewRoutePath;
  final SystemRouteReportHandler? systemRouteReportHandler;

  final List<Page<dynamic>> _pages = [];

  /// Identifies the current app run session.
  /// Browser history entries can persist across reloads, so entries from
  /// previous runs must be ignored when matching pages in the current run.
  static final int _sessionId = DateTime.now().microsecondsSinceEpoch;

  int _nextSerial = 0;

  /// A unique, sequentially increasing serial number for each page added to [_pages].
  /// [Expando] does not retain strong references to its keys,
  /// so no manual cleanup is required when a page is removed.
  final Expando<int> _serials = Expando<int>();

  void _track(Page page) => _serials[page] = _nextSerial++;

  late final List<NavigatorObserver> _navigatorObservers;

  /// The number of requests from the operating system that
  /// the current route be popped.
  int _willPopCount = 0;

  /// The number of requests from [Saut.back], [Saut.backToPage],
  /// [Saut.replaceAllWithPage] APIs that the current route is popped.
  int _didPopCount = 0;

  /// The number of requests from [updateRemovedPageWhen] API that
  /// the current route is popped.
  int _didUpdatePopCount = 0;

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
    // using didPopBySautApi as a flag to fix the issue (from Flutter 3.7.12) that described below:
    // - Show a dialog by using imperative api (e.g. `showDialog`, `Navigator.of(context).push`)
    // - Back to the previous screen (by using Android back button or tap the barrier)
    // - Navigate to a new screen by using Saut api
    // - Back to the previous screen by using Android back button
    // - The same screen replaced the old one instead of showing the previous screen
    bool didPopBySautApi = false;

    if (_didPopCount > 0) {
      // instead of set didPopBySautApi to true,
      // checking the last page is a SautPage to able to fix issue below:
      // - Show a dialog by using Saut api
      // - Back to the previous screen by tapping the barrier
      // - Navigate to a new screen by using Saut api
      // - Back to the previous screen (by using Android back button or tap the barrier)
      // - The dialog appear
      // If the last page is a SautPage, didPopBySautApi will be false
      didPopBySautApi = _lastPageIsSautPage != true;
      _didPopCount--;
    }

    if (_didUpdatePopCount > 0) {
      // fix the issue (from Flutter 3.7.12) that described below: 
      // - Show a dialog by using imperative api (e.g. `showDialog`, `Navigator.of(context).push`)
      // - Back to the previous screen (by using Android back button or tap the barrier)
      // - Navigate to a new screen by using Saut api
      // - Back to the previous screen by using imperative api (`Navigator.of(context).pop`)
      //   or back button in the app bar
      // - Navigate to the same screen by using Saut api
      // - An error will shown in the debug console that "Bad state: Duplicated Page: AppPages" (`debugPreventDuplicates` must be set to `true` by default)
      // if we continue:
      // - Show a popup by using imperative api
      //   - Close the popup by using Android back button or tap the barrier
      //   - The old screen with Duplicated Page error being pushed
      // - Show a popup by using Saut api
      //   - The old screen with Duplicated Page error being pushed with the popup
      _didUpdatePopCount--;
      _removeLastPage(result);
    } else if (_willPopCount > 0) {
      _willPopCount--;
      _removeLastPage(result);
    } else if (!didPopBySautApi) {
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
  Future<void> setInitialRoutePath(RouteInformation configuration) {
    onSetInitialRoutePath?.call(configuration);

    // Called not only at app startup, but also when the Router is remounted,
    // for example, when the Widget Inspector is toggled (which wraps/unwraps 
    // its subtree). In this case, the provider supplies the last reported route 
    // information, allowing [setNewRoutePath] to recognize it via the history 
    // state and preserve the current page stack.
    return setNewRoutePath(configuration);
  }

  late RouteInformation _lastReceivedRouteConfiguration;

  @override
  SynchronousFuture<void> setNewRoutePath(RouteInformation configuration) {
    _lastReceivedRouteConfiguration = configuration;

    // On the web (multi-entry history), every browser back/forward,
    // including the iOS Safari swipe-back gesture, triggers this method
    // instead of [popRoute].
    // By the time this is called, the browser has already navigated to the target entry,
    // so we synchronize [_pages] to match that entry using the state provided 
    // by [currentConfiguration].
    final state = configuration.state;

    if (state is Map && state['session'] == _sessionId && _pages.isNotEmpty) {
      final pageCount = state['pageCount'] as int?;
      final serial = state['serial'] as int?;

      // Drop the pages that come after the entry the browser went back to,
      // but always keep at least one page to avoid a black screen.
      //
      // With the while loop below (stops when only 1 page is left):
      //   [A, B, C], pageCount = 1 → remove C → remove B → [A]
      //   [A, B, C], pageCount = 0 → remove C → remove B → [A] (root kept)
      if (pageCount != null) {
        while (_pages.length > pageCount && _pages.length > 1) {
          final removed = _pages.removeLast();

          if (removed is SautPage) {
            removed.completeWith(null);
          }
        }
      }

      // The top page corresponds to the route information previously reported, 
      // meaning the stack is already correct: we bypass hooks and do not rebuild 
      // from the URL. 
      // 
      // This situation occurs when:
      // - The browser navigates back/forward to an entry within the current session.
      // - The [Router] is remounted (e.g., toggling the Widget Inspector), replaying 
      //   the last reported route info through [setInitialRoutePath]; without this 
      //   check, the current page would be redundantly pushed.
      //
      // Since the [Router] automatically rebuilds the [Navigator] after this future 
      // completes, calling `notifyListeners()` is unnecessary.
      if (serial != null && _serials[_pages.last] == serial) {
        return SynchronousFuture(null);
      }
    }

    onSetNewRoutePath?.call(configuration);

    systemRouteReportHandler?.call(configuration, notifyListeners);

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
    final scheme = _lastReceivedRouteConfiguration.uri.scheme;
    final host = _lastReceivedRouteConfiguration.uri.host;
    return RouteInformation(
      uri: Uri(
        scheme: scheme.isEmpty ? null : scheme,
        host: host.isEmpty ? null : host,
        path: lastPageName,
        queryParameters: {
          ..._lastReceivedRouteConfiguration.uri.queryParameters,
          ...?_lastPageArgumentsAsQueryParametersAll,
        },
      ),
      // Stored in the browser history entry and sent back to
      // [setNewRoutePath] when the user navigates back/forward.
      state: <String, Object?>{
        'session': _sessionId,
        'serial': _pages.isEmpty ? null : _serials[_pages.last],
        'pageCount': _pages.length,
      },
    );
  }

  String? get lastPageName {
    if (_pages.isEmpty) return null;

    return _pages.last.name;
  }

  bool? get _lastPageIsSautPage {
    if (_pages.isEmpty) return null;

    return _pages.last is SautPage;
  }

  Map<String, String>? get _lastPageArgumentsAsQueryParametersAll {
    if (_pages.isEmpty) return null;

    final arguments = _pages.last.arguments;

    if (arguments is Map) {
      if (arguments.isEmpty) return null;

      if (arguments is Map<String, dynamic>) {
        final result = {};

        for (final entry in arguments.entries) {
          final value = entry.value;

          try {
            result[entry.key] = value.toString();
          } catch (e) {
            // CastMap.toString() iterates all entries via forEach, casting each
            // value to the declared type (String). The underlying map contains a
            // List<dynamic> where a String was expected, so the cast fails here.
            // We can't predict which entries will mismatch, so we guard the
            // toString() path rather than the cast itself.
          }
        }

        return Map.unmodifiable(result);
      }

      if (arguments is Map<String, String>) {
        return Map.unmodifiable(arguments);
      }
    }

    return null;
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
    _track(page);
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

    _pages.clear();
    addPages(newPages);
  }

  void addPages(Iterable<SautPage> pages) {
    for (final page in pages) {
      _pages.add(page);
      _track(page);
    }

    notifyListeners();
  }

  @protected
  void addPage(SautPage page) {
    _pages.add(page);
    _track(page);

    notifyListeners();
  }

  @protected
  void replacePages(bool Function(Page element)? test, SautPage page) {
    if (test == null) {
      _pages.clear();
    } else {
      _removeUntil(test);
    }

    addPage(page);
  }

  /// `TO` is the type of the return value of the old page (route).
  @protected
  void replaceLastPage<TO extends Object?>(SautPage page, TO value) {
    _removeLastPage(value);

    addPage(page);
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

        _didUpdatePopCount++;

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
    final bool hasNoPageLeft = _removeLastPage(value);

    if (hasNoPageLeft) return;

    _didPopCount++;

    notifyListeners();
  }

  /// Returns `true` if there are no pages left to remove, 
  /// or `false` if a page was successfully removed.
  bool _removeLastPage<T extends Object?>(T value) {
    if (_pages.isEmpty) return true;

    final removed = _pages.removeLast();

    if (removed is SautPage) {
      removed.completeWith(value);
    }

    return false;
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
