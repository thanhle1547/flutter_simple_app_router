import 'package:flutter/widgets.dart';

import 'global.dart' as global;

/// A mixin for [StatefulWidgets] that need to implement RouteAware to subscribe
/// to [SautRouteObserver]
///
/// The mixin implements
mixin SautRouteSubscriptionStateMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    global.routeObserver?.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    global.routeObserver?.unsubscribe(this);
    super.dispose();
  }
}

/// A mixin for [StatefulWidgets] that need to implement RouteAware to listen
/// to [SautRouteObserver]
mixin SautRouteListerningStateMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    global.routeObserver?.addListener(this);
  }

  @override
  void dispose() {
    global.routeObserver?.removeListener(this);
    super.dispose();
  }
}
