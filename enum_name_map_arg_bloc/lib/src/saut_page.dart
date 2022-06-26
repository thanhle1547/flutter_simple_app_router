import 'dart:async';

import 'package:flutter/widgets.dart';

import 'route.dart' as router;
import 'route_config.dart';

typedef PagePredicate = bool Function(Page<dynamic> page);

class SautPage<T extends Object?> extends Page {
  SautPage({
    required dynamic page,
    required this.pageBuilder,
    String? name,
    Map<String, dynamic>? arguments,
    required this.routeConfig,
  })  : _popCompleter = Completer<T?>(),
        super(
          key: ValueKey(page),
          name: name,
          arguments: arguments,
          restorationId: name,
        );

  final Widget Function() pageBuilder;
  final RouteConfig routeConfig;
  final Completer<T?> _popCompleter;

  Future<T?> get completed => _popCompleter.future;

  @override
  Route createRoute(BuildContext context) {
    return router.createRoute(
      pageContext: context,
      pageBuilder: pageBuilder,
      config: routeConfig,
      settings: this,
      createdFromPage: true,
    );
  }

  void completeWith(T value) {
    _popCompleter.complete(value);
  }
}

class SautPageless extends Page {
  final Route route;

  const SautPageless({
    required this.route,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(
          name: name,
          arguments: arguments,
          restorationId: restorationId,
        );

  @override
  Route createRoute(BuildContext context) => route;
}
