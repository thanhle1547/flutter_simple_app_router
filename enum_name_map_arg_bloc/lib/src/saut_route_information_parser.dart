import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class SautRouteInformationParser
    extends RouteInformationParser<RouteInformation> {
  const SautRouteInformationParser();

  @override
  SynchronousFuture<RouteInformation> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    return SynchronousFuture(routeInformation);
  }

  @override
  RouteInformation restoreRouteInformation(RouteInformation configuration) {
    return configuration;
  }
}
