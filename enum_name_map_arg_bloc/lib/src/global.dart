import 'package:flutter/widgets.dart';
import 'package:saut_enma_bloc/src/saut_router_delegate.dart';

import 'saut_route_observer.dart';

SautRouteObserver? routeObserver;

GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
GlobalKey<NavigatorState>? _navigatorKey;

NavigatorState? get currentNavigatorState => _navigatorKey?.currentState;

GlobalKey<NavigatorState> createNavigatorKeyIfNotExisted() =>
    _navigatorKey ??= GlobalKey<NavigatorState>();

void disposeNavigatorKey() {
  _navigatorKey = null;
}

SautRouterDelegate? get routerDelegate => _routerDelegate;
SautRouterDelegate? _routerDelegate;

SautRouterDelegate get currentRouterDelegate => _routerDelegate!;

bool get useRouter => _routerDelegate != null;

SautRouterDelegate initRouterDelegate({
  List<NavigatorObserver>? navigatorObservers,
}) {
  return _routerDelegate ??= SautRouterDelegate(
    navigatorObservers: navigatorObservers,
  );
}

void disposeRouterDelegate() {
  _routerDelegate = null;
}
