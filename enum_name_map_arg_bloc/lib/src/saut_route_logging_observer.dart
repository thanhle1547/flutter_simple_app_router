import 'dart:developer' show log;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class SautRouteLoggingObserver extends RouteObserver<PageRoute<dynamic>> {
  SautRouteLoggingObserver({
    this.minimizeLogging = true,
  });

  final bool minimizeLogging;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    _handleLogging(
      route: route,
      pagelessRouteAction: 'CLOSE',
      pageRouteAction: 'LEAVING',
      fallbackRouteAction: 'POP',
    );

    if (!minimizeLogging && previousRoute != null) {
      _handleLogging(
        route: previousRoute,
        pagelessRouteAction: 'UNCOVERING',
        pageRouteAction: 'BACK TO',
      );
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    _handleLogging(
      route: route,
      pagelessRouteAction: 'SHOW',
      pageRouteAction: 'GOING TO',
      fallbackRouteAction: 'PUSH',
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);

    if (!minimizeLogging) {
      _handleLogging(
        route: route,
        pagelessRouteAction: 'REMOVE',
        pageRouteAction: 'REMOVE',
        fallbackRouteAction: 'REMOVE',
      );
    }
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    if (oldRoute != null && newRoute != null) {
      _handleLogging(
        route: oldRoute,
        pagelessRouteAction: 'REPLACE',
        pageRouteAction: 'REPLACE',
        fallbackRouteAction: 'REPLACE',
        replacedRoute: newRoute,
      );
    }
  }

  void _handleLogging({
    required Route route,
    required String pagelessRouteAction,
    required String pageRouteAction,
    String? fallbackRouteAction,
    Route? replacedRoute,
  }) {
    final String action = _resolveRouteAction(
      route: route,
      pagelessRouteAction: pagelessRouteAction,
      pageRouteAction: pageRouteAction,
      fallbackRouteAction: fallbackRouteAction,
    );

    final bool seperateArgumentsToNewLine =
        _shouldSeperateArgumentsToNewLine(route);

    StringBuffer? additionalMessage;
    if (replacedRoute != null) {
      additionalMessage = buildMessageStringBuffer(
        action: 'WITH',
        settings: replacedRoute.settings,
        seperateArgumentsToNewLine: seperateArgumentsToNewLine,
        padLeft: action.length - 4,
      );
    }

    if (!isModalBottomSheetRoute(route) && route.settings.name == null) return;

    _log(
      action,
      route.settings,
      seperateArgumentsToNewLine: seperateArgumentsToNewLine,
      additionalMessage: additionalMessage,
    );
  }

  String _resolveRouteAction({
    required Route route,
    required String pagelessRouteAction,
    required String pageRouteAction,
    String? fallbackRouteAction,
  }) {
    if (route is DialogRoute) {
      return "$pagelessRouteAction DIALOG";
    } else if (isModalBottomSheetRoute(route)) {
      return "$pagelessRouteAction MODEL BOTTOM SHEET";
    } else if (route.settings.name != null) {
      return pageRouteAction;
    }

    return fallbackRouteAction ?? '';
  }

  bool _shouldSeperateArgumentsToNewLine(Route route) {
    if (route is DialogRoute) return true;

    return false;
  }

  bool isModalBottomSheetRoute(Route<dynamic> route) =>
      objectRuntimeType(route, '').contains('_ModalBottomSheetRoute');

  void _log(
    String action,
    RouteSettings settings, {
    bool seperateArgumentsToNewLine = false,
    StringBuffer? additionalMessage,
  }) {
    final StringBuffer buffer = buildMessageStringBuffer(
      action: action,
      settings: settings,
      seperateArgumentsToNewLine: seperateArgumentsToNewLine,
    );

    if (additionalMessage != null) {
      buffer.write(additionalMessage);
    }

    log(
      buffer.toString(),
      name: source,
    );
  }

  StringBuffer buildMessageStringBuffer({
    required String action,
    required RouteSettings settings,
    bool seperateArgumentsToNewLine = false,
    int padLeft = 0,
  }) {
    final StringBuffer buffer = StringBuffer();

    for (int i = 0; i < padLeft; i++) {
      buffer.write(' ');
    }

    buffer.write(action);
    buffer.write(': ');
    buffer.write(settings.name);

    if (seperateArgumentsToNewLine) {
      final int numWhiteSpace =
          padLeft + (action.length > 9 ? action.length - 9 : 0);
      buffer.write('\n');
      for (int i = 0; i < numWhiteSpace; i++) {
        buffer.write(' ');
      }
      buffer.write('arguments: ');

      // result: "\n${' ' * numWhiteSpace}arguments: $arguments"
    }

    buffer.write(resolveArguments(settings.arguments));

    // result: "$action: ${settings.name}$arguments"
    return buffer;
  }

  late final RegExp dynamicWordRegex = RegExp(r'\bdynamic\b');

  String getStringRepresentationOfListItems(List list) {
    if (list.isEmpty) return '[]';

    if (list is List<num> ||
        list is List<bool> ||
        list is List<String> ||
        list is List<Map> ||
        list is List<Set> ||
        list is List<Symbol> ||
        list is List<BigInt>) {
      return list.toString();
    }

    final String firstItemRuntimeType = list[0].runtimeType.toString();
    final String listRuntimeType = list.runtimeType.toString();

    final String startString = "[Instance of '$firstItemRuntimeType'";

    final isDynamicList = listRuntimeType.contains(dynamicWordRegex);

    final bool didItemNotOverrideToString =
        (isDynamicList ? list : [list[0]]).toString().startsWith(startString);

    late final isSingleItemTypeList =
        listRuntimeType.contains(RegExp("\\b$firstItemRuntimeType\\b"));

    if (didItemNotOverrideToString && (isDynamicList || isSingleItemTypeList)) {
      return "$startString, ...]";
    }

    return list.toString();
  }

  String resolveArguments(Object? args) {
    if (args == null) return '';

    if (args is Map) {
      return '?' +
          args.entries
              .map(
                (e) => [
                  e.key.toString(),
                  if (e.value is Function)
                    objectRuntimeType(e.value, '')
                  else if (e.value is List)
                    [
                      e.value.runtimeType,
                      "(${e.value.length})",
                      getStringRepresentationOfListItems(e.value as List),
                    ].join(' ')
                  else
                    e.value.toString(),
                ].join('='),
              )
              .join('&');
    }

    return "?$args";
  }
}
