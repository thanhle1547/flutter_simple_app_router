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

late final RegExp _dynamicTypeRegex = RegExp(
  r'<dynamic(, dynamic)?>$',
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
      final Type effectiveEntryType =
          entry.value is Type ? entry.value as Type : entry.value.runtimeType;

      if (!arguments.containsKey(entry.key)) {
        throw MissingArgument(entry.key, effectiveEntryType);
      }

      String effectiveEntryTypeName = entry.value is String
          ? entry.value as String
          : effectiveEntryType.toString();

      effectiveEntryTypeName =
          effectiveEntryTypeName.replaceFirst(_dynamicTypeRegex, '');

      final currentArgument = arguments[entry.key];

      String effectiveArgumentType = objectRuntimeType(currentArgument, '');

      if (effectiveArgumentType.contains('=>')) {
        effectiveArgumentType = 'Function';
      }

      if (!effectiveArgumentType.contains(effectiveEntryTypeName)) {
        throw ArgumentTypeError(
          effectiveEntryType,
          arguments[entry.key].runtimeType,
          "'${entry.key}'",
        );
      }
    }

    return true;
  }());

  return () => routeConfig.pageBuilder(arguments);
}
