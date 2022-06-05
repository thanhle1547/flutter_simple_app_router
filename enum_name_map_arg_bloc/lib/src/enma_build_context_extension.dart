import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;

import 'enma_navigator_state_extension.dart';
import 'route_transition.dart';
import 'transition_builder_delegate.dart';

extension EnmaBuildContextExtension on BuildContext {
  /// See also:
  /// https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#2-create-a-widget-that-extracts-the-arguments
  Object? extractArguments() => ModalRoute.of(this)?.settings.arguments;

  /// * [blocValue]
  ///
  /// To provide an existing bloc to a new page.
  ///
  /// * [blocProviders]
  ///
  /// To provide existing blocs to a new page.
  ///
  /// * [debugPreventDuplicates]
  ///
  /// Prevent navigate to the same page.
  ///
  /// * [duration]
  ///
  /// The duration the transition going forwards.
  ///
  /// * [opaque]
  ///
  /// {@macro flutter.widgets.TransitionRoute.opaque}
  ///
  /// * [fullscreenDialog]
  ///
  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  ///
  /// Return a [Future]. The Future resolves when back to previous page
  /// and the [Future]'s value is the [back] method's `result` parameter.
  Future<T?> toPage<T extends Object?, B extends BlocBase<Object?>>(
    Enum page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<BlocProviderSingleChildWidget>? blocProviders,
    RouteTransition? transition,
    TransitionBuilderDelegate? customTransitionBuilderDelegate,
    Curve? curve,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
    bool? debugPreventDuplicates,
  }) =>
      Navigator.of(this).toPage(
        page,
        arguments: arguments,
        blocValue: blocValue,
        blocProviders: blocProviders,
        transition: transition,
        customTransitionBuilderDelegate: customTransitionBuilderDelegate,
        curve: curve,
        duration: duration,
        opaque: opaque,
        fullscreenDialog: fullscreenDialog,
        debugPreventDuplicates: debugPreventDuplicates,
      );

  /// [blocValue]: To provide an existing bloc to a new page.
  ///
  /// __Warning__: `SAUT` won't automatically handle closing the bloc.
  ///
  /// * [duration]
  ///
  /// The duration the transition going forwards.
  ///
  /// Return a [Future]. The Future resolves when back to previous page
  /// and the [Future]'s value is the [back] method's `result` parameter.
  Future<T?>? replaceWithPage<T extends Object?, B extends BlocBase<Object?>,
          TO extends Object?>(
    Enum page, {
    Map<String, dynamic>? arguments,
    B? blocValue,
    List<BlocProviderSingleChildWidget>? blocProviders,
    TO? result,
    RouteTransition? transition,
    TransitionBuilderDelegate? customTransitionBuilderDelegate,
    Curve? curve,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) =>
      Navigator.of(this).replaceWithPage(
        page,
        arguments: arguments,
        blocValue: blocValue,
        blocProviders: blocProviders,
        result: result,
        transition: transition,
        customTransitionBuilderDelegate: customTransitionBuilderDelegate,
        curve: curve,
        duration: duration,
        opaque: opaque,
        fullscreenDialog: fullscreenDialog,
      );

  /// * [duration]
  ///
  /// The duration the transition going forwards.
  ///
  /// Return a [Future]. The Future resolves when back to previous page
  /// and the [Future]'s value is the [back] method's `result` parameter.
  Future<T?>?
      replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
    Enum page, {
    RoutePredicate? predicate,
    Map<String, dynamic>? arguments,
    RouteTransition? transition,
    TransitionBuilderDelegate? customTransitionBuilderDelegate,
    Curve? curve,
    Duration? duration,
    bool? opaque,
    bool? fullscreenDialog,
  }) =>
          Navigator.of(this).replaceAllWithPage(
            page,
            predicate: predicate,
            arguments: arguments,
            transition: transition,
            customTransitionBuilderDelegate: customTransitionBuilderDelegate,
            curve: curve,
            duration: duration,
            opaque: opaque,
            fullscreenDialog: fullscreenDialog,
          );

  void back<T>({T? result}) => Navigator.of(this).back(result: result);

  void backToPageName(String name) => Navigator.of(this).backToPageName(name);

  void backToPage(Enum page) => backToPageName(page.name);

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  Route? getCurrentRoute() => Navigator.of(this).getCurrentRoute();

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  String? getCurrentRouteName() => getCurrentRoute()!.settings.name;
}
