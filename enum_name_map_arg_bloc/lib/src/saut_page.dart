import 'dart:async';

import 'package:flutter/widgets.dart';

import 'route.dart' as router;
import 'route_config.dart';

typedef PagePredicate = bool Function(Page<dynamic> page);

class SautPageKey<T> extends UniqueKey {
  SautPageKey(T value) : key = ValueKey<T>(value);

  final ValueKey key;
}

class SautPage<T extends Object?> extends Page {
  SautPage({
    required LocalKey key,
    required this.pageBuilder,
    String? name,
    Map<String, dynamic>? arguments,
    required this.routeConfig,
  })  : _popCompleter = Completer<T?>(),
        super(
          key: key,
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
    if (routeConfig.useRouteBuilder) {
      return routeConfig.routeBuilder!.call(
        context,
        routeConfig,
        this,
        pageBuilder(),
      );
    }

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
  late final Route route;

  // ignore: prefer_const_constructors_in_immutables
  SautPageless({
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
