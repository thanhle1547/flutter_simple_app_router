import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class SautDialogRouteBuilder extends SautRouteBuilder {
  const SautDialogRouteBuilder({
    this.barrierDismissible = true,
    this.barrierColor = Colors.black54,
    this.barrierLabel,
    this.useSafeArea = true,
    this.useRootNavigator = true,
    this.transitionBuilder = _buildMaterialDialogTransitions,
  });

  final bool barrierDismissible;
  final Color? barrierColor;
  final String? barrierLabel;
  final bool useSafeArea;
  final bool useRootNavigator;
  final RouteTransitionsBuilder transitionBuilder;

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

    return RawDialogRoute<T>(
      pageBuilder: (context, animation, secondaryAnimation) {
        Widget dialog = themes.wrap(page);
        if (useSafeArea) {
          dialog = SafeArea(child: dialog);
        }
        return dialog;
      },
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: transitionBuilder,
      settings: settings,
    );
  }
}

/// See also:
///  * [fixes `RawDialogRoute` memory leak [prod-leak-fix]](https://github.com/flutter/flutter/pull/147817)
Widget _buildMaterialDialogTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: animation,
    child: child,
  );
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

class SautModalBottomSheetRouteBuilder extends SautRouteBuilder {
  const SautModalBottomSheetRouteBuilder({
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.barrierColor,
    this.isScrollControlled = false,
    this.useRootNavigator = false,
    this.isDismissible = true,
    this.enableDrag = true,
    this.showDragHandle,
    this.useSafeArea = false,
    this.anchorPoint,
  });

  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final Color? barrierColor;
  final bool isScrollControlled;
  final bool useRootNavigator;
  final bool isDismissible;
  final bool enableDrag;
  final bool? showDragHandle;
  final bool useSafeArea;
  final Offset? anchorPoint;

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

    return ModalBottomSheetRoute<T>(
      builder: (context) => page,
      capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
      isScrollControlled: isScrollControlled,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      isDismissible: isDismissible,
      modalBarrierColor: barrierColor ?? Theme.of(context).bottomSheetTheme.modalBarrierColor,
      enableDrag: enableDrag,
      settings: settings,
      anchorPoint: anchorPoint,
      useSafeArea: useSafeArea,
    );
  }
}
