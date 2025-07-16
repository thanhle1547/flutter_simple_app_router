import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocBase, BlocProvider, MultiBlocProvider;
import 'package:provider/single_child_widget.dart' show SingleChildWidget;
import 'package:saut_enma_bloc/src/global.dart';

import 'app_config.dart';
import 'argument_error.dart';
import 'constants.dart';
import 'route_config.dart';
import 'saut_page_route_builder.dart';

Route<T> createRoute<T>({
  required Widget page,
  required RouteConfig config,
  required RouteSettings settings,
  BuildContext? context,
  bool createdFromPage = false,
}) {
  if (config.useRouteBuilder) {
    return config.routeBuilder!.call<T>(
      context!,
      config,
      settings,
      page,
    );
  }

  return SautPageRouteBuilder<T>(
    settings: settings,
    page: page,
    pageTransitionsBuilder: config.transitionsBuilder ??
        AppConfig.defaultTransitionsBuilder ??
        kPageTransitionsBuilder,
    transitionDuration: config.transitionDuration ??
        AppConfig.defaultTransitionDuration ??
        kTransitionDuration,
    opaque: config.opaque,
    barrierDismissible: config.barrierDismissible,
    fullscreenDialog: config.fullscreenDialog,
    createdFromSautPage: createdFromPage,
  );
}

Route createRouteFromName(String? name, [String? fallbackName]) {
  try {
    String? effectiveName;

    String? configuredInitialPageName = AppConfig.initialPage == null
        ? null
        : effectiveRouteNameBuilder(AppConfig.initialPage!);

    final key = AppConfig.routes.keys.firstWhere(
      (e) {
        final String builtName = effectiveRouteNameBuilder(e);

        if (builtName != name) return false;

        effectiveName = name;
        return true;
      },
      orElse: () {
        log("$name could not be found", name: source);

        try {
          return AppConfig.routes.keys.firstWhere(
            (e) {
              final String builtName = effectiveRouteNameBuilder(e);

              if (builtName == configuredInitialPageName) {
                effectiveName = configuredInitialPageName;
                return true;
              }

              if (builtName == fallbackName) {
                effectiveName = fallbackName;
                return true;
              }

              return false;
            },
          );
        } catch (e) {
          if (AppConfig.initialPage == null) rethrow;

          effectiveName = configuredInitialPageName;
          return AppConfig.initialPage!;
        }
      },
    );

    final RouteConfig config = AppConfig.routes[key]!;

    return createRoute(
      page: config.pageBuilder(null),
      config: config,
      settings: RouteSettings(name: effectiveName),
    );
  } on StateError {
    throw StateError("$name not found");
  }
}

bool debugAssertRouterDelegateExist() {
  if (routerDelegate == null) {
    throw StateError(
      'Feature only available when creates an app '
      '([MaterialApp], [CupertinoApp]) that uses the [Router] '
      'and using SautRouterDelegate as [routerDelegate]',
    );
  }

  return true;
}

Never routeObserverIsRequired() {
  throw "[RouteObserver] from [$source] has not been initialized";
}

String _defaultRouteNameBuilder(Enum page) => page.name;

String Function(Enum page) get effectiveRouteNameBuilder =>
    AppConfig.routeNameBuilder ?? _defaultRouteNameBuilder;

Widget maybeWrapWithBlocProviders<B extends BlocBase<Object?>>({
  required Widget page,
  B? blocValue,
  List<SingleChildWidget>? blocProviders,
}) {
  if (blocValue != null && blocProviders != null) {
    throw ArgumentError(
      'Do not pass value to [blocValue] & [blocProviders] at the same time.',
    );
  }

  if (blocValue != null) {
    return BlocProvider.value(
      value: blocValue,
      child: page,
    );
  }

  if (blocProviders != null) {
    return MultiBlocProvider(
      providers: blocProviders,
      child: page,
    );
  }

  return page;
}

RouteConfig getRouteConfig(Enum page) {
  if (!AppConfig.routes.containsKey(page)) {
    throw "$page weren't defined";
  }

  return AppConfig.routes[page]!;
}

/// Example:
///
///  * `<dynamic>` in `List<dynamic>`
///  * `<dynamic, dynamic>` in `Map<dynamic, dynamic>`
late final RegExp _dynamicTypeRegex = RegExp(
  r'<dynamic(, dynamic)?>$',
);

/// Example:
///
///  * CastList<dynamic, String>
///  * CastSet<dynamic, String>
///  * `... are allowed`
///
///  * _CastList<dynamic, String>
///  * (int, _CastList<dynamic, String>)
///  * (double, OverridedCastList<dynamic, String>)
///  * `... are NOT allowed`
late final RegExp _castTypeRegex = RegExp(
  r'(?<![\w_])Cast(\w+)<\w+,\s(\w+)>',
  caseSensitive: true,
  multiLine: false,
);

Widget getPage<T extends Object?>(
  RouteConfig routeConfig,
  Map<String, dynamic>? arguments,
) {
  assert(() {
    final Map<String, Object>? debugRequiredArguments = routeConfig.debugRequiredArguments;

    if (debugRequiredArguments == null || debugRequiredArguments.isEmpty == true) {
      return true;
    }

    if (arguments == null || arguments.isEmpty == true) {
      throw MissingArgument(
        debugRequiredArguments.toString(),
      );
    }

    for (final entry in debugRequiredArguments.entries) {
      final entryKey = entry.key;
      final entryValue = entry.value;

      final Type effectiveEntryType = entryValue is Type ? entryValue : entryValue.runtimeType;

      if (!arguments.containsKey(entryKey)) {
        throw MissingArgument(entryKey, effectiveEntryType);
      }

      String effectiveEntryTypeName = entryValue is String
          ? entryValue
          : effectiveEntryType.toString();

      effectiveEntryTypeName =
          effectiveEntryTypeName.replaceFirst(_dynamicTypeRegex, '');

      if (effectiveEntryTypeName == 'Object') continue;

      final currentArgument = arguments[entry.key];

      String effectiveArgumentType = objectRuntimeType(currentArgument, '');

      effectiveArgumentType = effectiveArgumentType.replaceAllMapped(
        _castTypeRegex,
        (match) {
          return "${match.group(1)}<${match.group(2)}>";
        },
      );

      if (effectiveArgumentType.contains('=>')) {
        effectiveArgumentType = 'Function';
      }

      // Using contains instead of equality operator due to
      // internal implementation of Dart Type
      //
      // Ex: CastList
      if (!effectiveArgumentType.contains(effectiveEntryTypeName)) {
        throw ArgumentTypeError(
          effectiveEntryType,
          arguments[entryKey].runtimeType,
          "'$entryKey'",
        );
      }
    }

    return true;
  }());

  return routeConfig.pageBuilder(arguments);
}
