import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocBase, BlocProvider, MultiBlocProvider;
// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;

import 'app_config.dart';
import 'argument_error.dart';
import 'constants.dart';
import 'route_config.dart';
import 'route_transition.dart';
import 'saut_page_route_builder.dart';
import 'transition_builder_delegate.dart';

typedef PageBuilder = Widget Function();

PageRouteBuilder<T> createRoute<T>({
  required PageBuilder pageBuilder,
  required RouteSettings settings,
  TransitionBuilderDelegate? transitionBuilderDelegate,
  Duration? transitionDuration,
  Curve? curve,
  bool opaque = kOpaque,
  bool fullscreenDialog = kFullscreenDialog,
}) =>
    SautPageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, __, ___) => pageBuilder(),
      transitionBuilderDelegate: transitionBuilderDelegate ??
          AppConfig.defaultTransition?.builder ??
          kRouteTransition.builder,
      transitionDuration: transitionDuration ??
          AppConfig.defaultTransitionDuration ??
          kTransitionDuration,
      curve: curve ?? AppConfig.defaultTransitionCurve,
      opaque: opaque,
      fullscreenDialog: fullscreenDialog,
    );

PageRouteBuilder createRouteFromName(String? name) {
  try {
    final key = AppConfig.routes.keys.firstWhere(
      (e) => effectiveRouteNameBuilder(e) == name,
      orElse:
          AppConfig.initialPage == null ? null : () => AppConfig.initialPage!,
    );

    final RouteConfig config = AppConfig.routes[key]!;

    return createRoute(
      pageBuilder: () => config.pageBuilder(null),
      settings: RouteSettings(name: name),
      transitionBuilderDelegate:
          config.transition?.builder ?? config.customTransitionBuilderDelegate,
    );
  } on StateError {
    throw StateError("$name not found");
  }
}

void _logAndThrowError(Object e) {
  if (kDebugMode) {
    log(e.toString(), name: source);
  }

  throw e;
}

bool get _shouldCheckRouteType => AppConfig.routeTypes.isNotEmpty;

void checkRouteType(Enum page) {
  if (_shouldCheckRouteType &&
      !AppConfig.routeTypes.contains(page.runtimeType)) {
    _logAndThrowError(ArgumentError(
      "Route types did not contain type ${page.runtimeType} ($page)",
    ));
  }
}

String Function(Enum page) get effectiveRouteNameBuilder =>
    AppConfig.routeNameBuilder ?? (page) => page.name;

/// throw StateError when you pushed the same page to the stack
void duplicatedPage(String name) =>
    _logAndThrowError(StateError("Duplicated Page: $name"));

PageBuilder resolvePageBuilderWithBloc<B extends BlocBase<Object?>>({
  required PageBuilder pageBuilder,
  B? blocValue,
  List<BlocProviderSingleChildWidget>? blocProviders,
}) {
  if (blocValue != null && blocProviders != null) {
    _logAndThrowError(ArgumentError(
      'Do not pass value to [blocValue] & [blocProviders] at the same time.',
    ));
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
  if (routeConfig.requiredArguments != null) {
    if (arguments == null) {
      _logAndThrowError(MissingArgument(
        routeConfig.requiredArguments.toString(),
      ));
    } else {
      for (final entry in routeConfig.requiredArguments!.entries) {
        final Type effectiveEntryType =
            entry.value is Type ? entry.value as Type : entry.value.runtimeType;

        if (!arguments.containsKey(entry.key)) {
          _logAndThrowError(MissingArgument(entry.key, effectiveEntryType));
        }

        String effectiveEntryTypeName = entry.value is String
            ? entry.value as String
            : effectiveEntryType.toString();

        effectiveEntryTypeName =
            effectiveEntryTypeName.replaceFirst(_dynamicTypeRegex, '');

        if (!arguments[entry.key]
            .runtimeType
            .toString()
            .contains(effectiveEntryTypeName)) {
          _logAndThrowError(
            ArgumentTypeError(
              effectiveEntryType,
              arguments[entry.key].runtimeType,
              "'${entry.key}'",
            ),
          );
        }
      }
    }
  }

  return () => routeConfig.pageBuilder(arguments);
}
