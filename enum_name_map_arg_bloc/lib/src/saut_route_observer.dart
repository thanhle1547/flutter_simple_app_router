import 'package:flutter/material.dart';

class SautRouteObserver extends RouteObserver<ModalRoute<Object?>> {
  late final Set<RouteAware> _listeners = <RouteAware>{};

  /// Register [routeAware] to be informed about route changes.
  ///
  /// Going forward, [routeAware] will be informed via `didPushNext`.
  ///
  /// When a route is popped off the [Navigator] stack,
  /// [routeAware] will be informed via `didPopNext`
  void addListener(RouteAware routeAware) {
    if (_listeners.add(routeAware)) {
      routeAware.didPush();
    }
  }

  /// Remove a previously registered [routeAware].
  ///
  /// If the given listener is not registered, the call is ignored.
  void removeListener(RouteAware routeAware) {
    _listeners.remove(routeAware);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    for (final RouteAware routeAware in _listeners) {
      routeAware.didPopNext();
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    for (final RouteAware routeAware in _listeners) {
      routeAware.didPushNext();
    }
  }
}
