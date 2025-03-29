import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocBase, BlocProvider, MultiBlocProvider;
// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;
import 'package:saut_enma_bloc/src/global.dart';

import 'app_config.dart';
import 'argument_error.dart';
import 'constants.dart';
import 'route_config.dart';
import 'route_transition.dart';
import 'saut_page_route_builder.dart';
import 'transition_builder_delegate.dart';

typedef PageBuilder = Widget Function();

Route<T> createRoute<T>({
  required PageBuilder pageBuilder,
  required RouteConfig config,
  required RouteSettings settings,
  BuildContext? pageContext,
  bool createdFromPage = false,
}) {
  if (config.useRouteBuilder) {
    return config.routeBuilder!.call<T>(
      pageContext!,
      config,
      settings,
      pageBuilder(),
    );
  }

  return _createSautPageRoute(
    pageBuilder: pageBuilder,
    settings: settings,
    transitionBuilderDelegate: config.effectiveTransitionBuilderDelegate,
    transitionDuration: config.transitionDuration,
    curve: config.curve,
    opaque: config.opaque,
    fullscreenDialog: config.fullscreenDialog,
    createdFromPage: createdFromPage,
  );
}

PageRouteBuilder<T> _createSautPageRoute<T>({
  required PageBuilder pageBuilder,
  required RouteSettings settings,
  TransitionBuilderDelegate? transitionBuilderDelegate,
  Duration? transitionDuration,
  Curve? curve,
  bool opaque = kOpaque,
  bool fullscreenDialog = kFullscreenDialog,
  bool createdFromPage = false,
}) =>
    SautPageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, __, ___) => Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: pageBuilder(),
      ),
      transitionBuilderDelegate: transitionBuilderDelegate ??
          AppConfig.defaultTransition?.builder ??
          kRouteTransition.builder,
      transitionDuration: transitionDuration ??
          AppConfig.defaultTransitionDuration ??
          kTransitionDuration,
      curve: curve ?? AppConfig.defaultTransitionCurve,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
      createdFromSautPage: createdFromPage,
    );

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
      pageBuilder: () => config.pageBuilder(null),
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

bool get _shouldCheckRouteType => AppConfig.routeTypes.isNotEmpty;

bool debugAssertRouteTypeIsValid(Enum page) {
  assert(() {
    if (_shouldCheckRouteType &&
        !AppConfig.routeTypes.contains(page.runtimeType)) {
      throw ArgumentError(
        "Route types did not contain type ${page.runtimeType} ($page)",
      );
    }

    return true;
  }());

  return true;
}

String _defaultRouteNameBuilder(Enum page) => page.name;

String Function(Enum page) get effectiveRouteNameBuilder =>
    AppConfig.routeNameBuilder ?? _defaultRouteNameBuilder;

PageBuilder resolvePageBuilderWithBloc<B extends BlocBase<Object?>>({
  required PageBuilder pageBuilder,
  B? blocValue,
  List<BlocProviderSingleChildWidget>? blocProviders,
}) {
  if (blocValue != null && blocProviders != null) {
    throw ArgumentError(
      'Do not pass value to [blocValue] & [blocProviders] at the same time.',
    );
  }

  if (blocValue != null) {
    return () => BlocProvider.value(
          value: blocValue,
          child: pageBuilder(),
        );
  }

  if (blocProviders != null) {
    return () => MultiBlocProvider(
          providers: blocProviders,
          child: pageBuilder(),
        );
  }

  return pageBuilder;
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

Widget Function() getPageBuilder<T extends Object?>(
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

  return () => routeConfig.pageBuilder(arguments);
}
