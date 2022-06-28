import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: implementation_imports
import 'package:flutter_bloc/src/bloc_provider.dart'
    show BlocProviderSingleChildWidget;

import 'enma_navigator_state_extension.dart';
import 'route_transition.dart';
import 'saut_page.dart';
import 'transition_builder_delegate.dart';

extension EnmaBuildContextExtension on BuildContext {
  /// Remove all the pages with new pages
  void setPageStack(Object stackName, Map<String, dynamic>? arguments) =>
      Navigator.of(this).setPageStack(stackName, arguments);

  /// This function use [ModalRoute.of(context)?.settings.arguments] internally
  ///
  /// See also:
  /// https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#2-create-a-widget-that-extracts-the-arguments
  Object? extractArguments() => ModalRoute.of(this)?.settings.arguments;

  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to a new page.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to a new page.
  ///
  /// * [transition]
  ///
  /// Used to build the route's transitions.
  ///
  /// * [customTransitionBuilderDelegate]
  ///
  /// Used to build your own custom route's transitions.
  ///
  /// * [curve]
  ///
  /// An parametric animation easing curve, i.e. a mapping of the unit interval to
  /// the unit interval.
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
  /// * [debugPreventDuplicates]
  ///
  /// Prevent (accidentally) from navigating to the same page on `debug mode`.
  ///
  /// Return a [Future]. The Future resolves when back to previous page
  /// and the [Future]'s value is the [back] method's `result` parameter.
  ///
  /// The `T` type argument is the type of the return value of the route.
  ///
  /// See also:
  ///
  ///  * [Curve], the interface implemented by the constants available from the
  ///    [Curves] class.
  ///  * [Curves], a collection of common animation easing curves.
  @optionalTypeArgs
  Future<T?> toPage<T extends Object?, B extends BlocBase<Object?>>(
    Object page, {
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

  /// * [blocValue]
  ///
  /// Used to provide an existing bloc to a new page.
  ///
  /// __Warning__: `SAUT` won't automatically handle closing the bloc.
  ///
  /// * [blocProviders]
  ///
  /// Used to provide existing blocs to a new page.
  ///
  /// * [result]
  ///
  /// If non-null, `result` will be used as the result of the route that is removed;
  /// the future that had been returned from pushing that old route
  /// will complete with result. The type of `result`, if provided,
  /// must match the type argument of the class of the old route (`TO`).
  ///
  /// * [transition]
  ///
  /// Used to build the route's transitions.
  ///
  /// * [customTransitionBuilderDelegate]
  ///
  /// Used to build your own custom route's transitions.
  ///
  /// * [curve]
  ///
  /// An parametric animation easing curve, i.e. a mapping of the unit interval to
  /// the unit interval.
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
  /// The `T` type argument is the type of the return value of the new route,
  /// and `TO` is the type of the return value of the old route.
  ///
  /// See also:
  ///
  ///  * [Curve], the interface implemented by the constants available from the
  ///    [Curves] class.
  ///  * [Curves], a collection of common animation easing curves.
  @optionalTypeArgs
  Future<T?>? replaceWithPage<T extends Object?, B extends BlocBase<Object?>,
          TO extends Object?>(
    Object page, {
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

  /// [routePredicate]
  ///
  /// To remove routes until a route with a certain name,
  /// use the [RoutePredicate] returned from [Saut.getModalRoutePredicate].
  ///
  /// To remove all the routes the replaced route, simply let [routePredicate] null.
  ///
  /// [pagePredicate]
  ///
  /// To remove pages until a page with a certain name when created an app
  /// ([MaterialApp], [CupertinoApp]) that uses the [Router]
  /// instead of a [Navigator].
  ///
  /// Use the [PagePredicate] returned from [Saut.getPagePredicate].
  ///
  /// To remove all the pages the replaced page, simply let [pagePredicate] null.
  ///
  /// * [transition]
  ///
  /// Used to build the route's transitions.
  ///
  /// * [customTransitionBuilderDelegate]
  ///
  /// Used to build your own custom route's transitions.
  ///
  /// * [curve]
  ///
  /// An parametric animation easing curve, i.e. a mapping of the unit interval to
  /// the unit interval.
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
  /// The T type argument is the type of the return value of the new route.
  ///
  /// See also:
  ///
  ///  * [Curve], the interface implemented by the constants available from the
  ///    [Curves] class.
  ///  * [Curves], a collection of common animation easing curves.
  @optionalTypeArgs
  Future<T?>?
      replaceAllWithPage<T extends Object?, B extends BlocBase<Object?>>(
    Object page, {
    RoutePredicate? routePredicate,
    PagePredicate? pagePredicate,
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
            routePredicate: routePredicate,
            pagePredicate: pagePredicate,
            arguments: arguments,
            transition: transition,
            customTransitionBuilderDelegate: customTransitionBuilderDelegate,
            curve: curve,
            duration: duration,
            opaque: opaque,
            fullscreenDialog: fullscreenDialog,
          );

  /// The `T` type argument is the type of the return value of the popped route.
  ///
  /// The type of `result`, if provided,
  /// must match the type argument of the class of the popped route (`T`).
  ///
  /// See [Navigator.pop] for more details of the semantics of popping a route.
  @optionalTypeArgs
  void back<T extends Object?>({T? result}) =>
      Navigator.of(this).back(result: result);

  /// Calls [back] repeatedly until found the page with a certain name.
  void backToPageName(String name) => Navigator.of(this).backToPageName(name);

  /// Calls [back] repeatedly until found the page.
  void backToPage(Object page) => backToPageName(page.toString());

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  Route? getCurrentRoute() => Navigator.of(this).getCurrentRoute();

  /// Trick explained here: https://github.com/flutter/flutter/issues/20451
  /// Note `ModalRoute.of(context).settings.name` doesn't always work.
  String? getCurrentRouteName() => getCurrentRoute()!.settings.name;
}
