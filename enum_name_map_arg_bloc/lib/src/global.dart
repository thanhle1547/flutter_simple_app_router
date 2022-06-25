import 'package:flutter/widgets.dart';

import 'saut_route_observer.dart';

SautRouteObserver? routeObserver;

GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;
GlobalKey<NavigatorState>? _navigatorKey;

NavigatorState? get currentNavigatorState => _navigatorKey?.currentState;

GlobalKey<NavigatorState> createNavigatorKeyIfNotExisted() =>
    _navigatorKey ??= GlobalKey<NavigatorState>();
