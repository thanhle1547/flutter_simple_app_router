import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'modified_copy/bottom_sheet.dart' as bottom_sheet;
import 'modified_copy/dialog.dart' as dialog;
import 'route_config.dart';

abstract class SautRouteBuilder {
  const SautRouteBuilder();

  Route<T> call<T>(
    BuildContext context,
    RouteConfig resolvedConfig,
    RouteSettings settings,
    Widget page,
  );
}

abstract class SautRouteTransitionsBuilder {
  const SautRouteTransitionsBuilder();

  Widget call(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child);

  void dispose() {}
}

typedef SautModalBarrierBuilder = Widget Function(Widget superModalBarrier);

class SautDialogRouteBuilder extends SautRouteBuilder {
  const SautDialogRouteBuilder({
    this.barrierDismissible = true,
    this.barrierColor = Colors.black54,
    this.barrierLabel,
    this.modalBarrierBuilder,
    this.useSafeArea = true,
    this.useRootNavigator = true,
    this.useDisplayFeatureSubScreen = true,
    this.transitionBuilder = const SautRawDialogRouteTransitionsBuilder(),
    this.traversalEdgeBehavior,
  });

  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final SautModalBarrierBuilder? modalBarrierBuilder;
  final bool useSafeArea;
  final bool useRootNavigator;
  final bool useDisplayFeatureSubScreen;
  final SautRouteTransitionsBuilder transitionBuilder;
  final TraversalEdgeBehavior? traversalEdgeBehavior;

  @override
  Route<T> call<T>(
    BuildContext context,
    RouteConfig resolvedConfig,
    RouteSettings settings,
    Widget page,
  ) {
    assert(_debugIsActive(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final CapturedThemes themes = InheritedTheme.capture(
      from: context,
      to: Navigator.of(
        context,
        rootNavigator: useRootNavigator,
      ).context,
    );

    Widget dialogWidget = themes.wrap(page);
    if (useSafeArea) {
      dialogWidget = SafeArea(child: dialogWidget);
    }
    if (useDisplayFeatureSubScreen) {
      dialogWidget = DisplayFeatureSubScreen(child: dialogWidget);
    }

    return dialog.RawDialogRoute<T>(
      page: dialogWidget,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
      modalBarrierBuilder: modalBarrierBuilder,
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: transitionBuilder,
      traversalEdgeBehavior: traversalEdgeBehavior,
      settings: settings,
    );
  }
}

class SautRawDialogRouteTransitionsBuilder extends SautRouteTransitionsBuilder {
  const SautRawDialogRouteTransitionsBuilder();

  /// See also:
  ///  * [fixes `RawDialogRoute` memory leak [prod-leak-fix]](https://github.com/flutter/flutter/pull/147817)
  @override
  Widget call(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class SautMaterialDialogRouteTransitionsBuilder extends SautRouteTransitionsBuilder {
  CurvedAnimation? _curvedAnimation;

  void _setAnimation(Animation<double> animation) {
    if (_curvedAnimation?.parent != animation) {
      _curvedAnimation?.dispose();
      _curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    }
  }

  /// See also:
  ///  * [fixes `DialogRoute` memory leak [prod-leak-fix]](https://github.com/flutter/flutter/pull/147816)
  @override
  Widget call(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    _setAnimation(animation);
    return FadeTransition(
      opacity: _curvedAnimation!,
      child: child,
    );
  }

  @override
  void dispose() {
    _curvedAnimation?.dispose();
  }
}

bool _debugIsActive(BuildContext context) {
  if (context is Element && !context.debugIsActive) {
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary('This BuildContext is no longer valid.'),
      ErrorDescription(
        'The showDialog function context parameter is a BuildContext that is no longer valid.'
      ),
      ErrorHint(
        'This can commonly occur when the showDialog function is called after awaiting a Future. '
        'In this situation the BuildContext might refer to a widget that has already been disposed during the await. '
        'Consider using a parent context instead.',
      ),
    ]);
  }
  return true;
}

class SautCupertinoModalPopupRouteBuilder extends SautRouteBuilder {
  const SautCupertinoModalPopupRouteBuilder({
    this.barrierLabel = 'Dismiss',
    this.barrierColor = kCupertinoModalBarrierColor,
    this.barrierDismissible = true,
    this.semanticsDismissible = false,
    this.filter,
  });

  final String barrierLabel;
  final Color barrierColor;
  final bool barrierDismissible;
  final bool semanticsDismissible;
  final ui.ImageFilter? filter;

  @override
  Route<T> call<T>(
    BuildContext context,
    RouteConfig resolvedConfig,
    RouteSettings settings,
    Widget page,
  ) {
    return CupertinoModalPopupRoute<T>(
      builder: (context) => page,
      barrierLabel: barrierLabel,
      barrierColor: CupertinoDynamicColor.resolve(barrierColor, context),
      barrierDismissible: barrierDismissible,
      semanticsDismissible: semanticsDismissible,
      filter: filter,
      settings: settings,
    );
  }
}

class SautCupertinoDialogRouteBuilder extends SautRouteBuilder {
  const SautCupertinoDialogRouteBuilder({
    this.barrierLabel,
    this.barrierColor = kCupertinoModalBarrierColor,
    this.barrierDismissible = true,
  });

  final String? barrierLabel;
  final Color barrierColor;
  final bool barrierDismissible;

  @override
  Route<T> call<T>(
    BuildContext context,
    RouteConfig resolvedConfig,
    RouteSettings settings,
    Widget page,
  ) {
    // Using CupertinoDialogRoute instead of RawDialogRoute because
    // Flutter version 3.29.0 implements `createSimulation` internally
    // https://github.com/flutter/flutter/pull/155575
    return CupertinoDialogRoute<T>(
      context: context,
      builder: (context) => page,
      barrierLabel: barrierLabel,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      settings: settings,
    );
  }
}

/// {@macro saut.modified_copy.ModalBottomSheetRoute}
///
/// The `useRootNavigator` parameter ensures that the root navigator is used to
/// display the [BottomSheet] when set to `true`. This is useful in the case
/// that a modal [BottomSheet] needs to be displayed above all other content
/// but the caller is inside another [Navigator].
///
/// The 'barrierLabel' parameter can be used to set a custom barrier label.
/// Will default to [MaterialLocalizations.modalBarrierDismissLabel] of context
/// if not set.
class SautModalBottomSheetRouteBuilder extends SautRouteBuilder {
  const SautModalBottomSheetRouteBuilder({
    this.constraints,
    this.barrierLabel,
    this.barrierColor,
    this.modalBarrierBuilder,
    this.isScrollControlled = false,
    this.useRootNavigator = false,
    this.isDismissible = true,
    this.enableDrag = true,
    this.showDragHandle,
    this.useSafeArea = false,
    this.fallbackToMediaQuery = true,
    this.useDisplayFeatureSubScreen = true,
  });

  final BoxConstraints? constraints;
  final String? barrierLabel;
  final Color? barrierColor;
  final SautModalBarrierBuilder? modalBarrierBuilder;
  final bool isScrollControlled;
  final bool useRootNavigator;
  final bool isDismissible;
  final bool enableDrag;
  final bool? showDragHandle;
  final bool useSafeArea;

  /// If [useSafeArea] is false, then [MediaQuery.removePadding]
  /// will be used to remove top padding, so that a [SafeArea] widget
  /// inside the bottom sheet will have no effect at the top edge.
  /// If this is undesired, set the alue of
  /// [SautModalBottomSheetRouteBuilder.fallbackToMediaQuery] to false.
  final bool fallbackToMediaQuery;

  /// Whether to avoid overlapping any display feature.
  ///
  /// If true, a [DisplayFeatureSubScreen] is inserted to keep the bottom sheet
  /// away from overlapping any [DisplayFeature] that splits the screen
  /// into sub-screens.
  ///
  /// The default is true.
  ///
  /// See also:
  ///
  ///  * [DisplayFeatureSubScreen], which documents the specifics of how
  ///    [DisplayFeature]s can split the screen into sub-screens.
  final bool useDisplayFeatureSubScreen;

  @override
  Route<T> call<T>(
    BuildContext context,
    RouteConfig resolvedConfig,
    RouteSettings settings,
    Widget page,
  ) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));

    final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);

    return bottom_sheet.ModalBottomSheetRoute<T>(
      page: page,
      capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
      isScrollControlled: isScrollControlled,
      barrierLabel: barrierLabel ?? localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(localizations.bottomSheetLabel),
      modalBarrierBuilder: modalBarrierBuilder,
      constraints: constraints,
      isDismissible: isDismissible,
      modalBarrierColor: barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      enableDrag: enableDrag,
      settings: settings,
      useSafeArea: useSafeArea,
      fallbackToMediaQuery: fallbackToMediaQuery,
      useDisplayFeatureSubScreen: useDisplayFeatureSubScreen,
    );
  }
}
