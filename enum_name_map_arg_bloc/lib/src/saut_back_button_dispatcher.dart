import 'package:flutter/widgets.dart';

import 'app_config.dart';
import 'saut_router_delegate.dart';

class SautRootBackButtonDispatcher extends RootBackButtonDispatcher {
  SautRootBackButtonDispatcher(this.delegate);

  final SautRouterDelegate delegate;

  @override
  Future<bool> didPopRoute() async {
    if (AppConfig.didPreventBackButtonToGoBack) {
      return true;
    }

    return super.didPopRoute();
  }
}
