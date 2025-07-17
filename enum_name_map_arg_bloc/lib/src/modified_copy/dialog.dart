// A modified copy version of Flutter 3.29.3

import 'package:flutter/widgets.dart';

import '../route_builder.dart';
import '../saut.dart';

/// A general dialog route which allows for customization of the dialog popup.
///
/// It is used internally by [showGeneralDialog] or can be directly pushed
/// onto the [Navigator] stack to enable state restoration. See
/// [showGeneralDialog] for a state restoration app example.
///
/// This function takes a `pageBuilder`, which typically builds a dialog.
/// Content below the dialog is dimmed with a [ModalBarrier]. The widget
/// returned by the `builder` does not share a context with the location that
/// `showDialog` is originally called from. Use a [StatefulBuilder] or a
/// custom [StatefulWidget] if the dialog needs to update dynamically.
///
/// The `barrierDismissible` argument is used to indicate whether tapping on the
/// barrier will dismiss the dialog. It is `true` by default and cannot be `null`.
///
/// The `barrierColor` argument is used to specify the color of the modal
/// barrier that darkens everything below the dialog. If `null`, the default
/// color `Colors.black54` is used.
///
/// The `settings` argument define the settings for this route. See
/// [RouteSettings] for details.
///
/// See also:
///
///  * [DisplayFeatureSubScreen], which documents the specifics of how
///    [DisplayFeature]s can split the screen into sub-screens.
///  * [showGeneralDialog], which is a way to display a RawDialogRoute.
///  * [showDialog], which is a way to display a DialogRoute.
///  * [showCupertinoDialog], which displays an iOS-style dialog.
class RawDialogRoute<T> extends PopupRoute<T> {
  /// A general dialog route which allows for customization of the dialog popup.
  RawDialogRoute({
    required Widget page,
    bool barrierDismissible = true,
    Color? barrierColor = const Color(0x80000000),
    String? barrierLabel,
    Duration transitionDuration = const Duration(milliseconds: 200),
    required SautRouteTransitionsBuilder transitionBuilder,
    required SautModalBarrierBuilder? modalBarrierBuilder,
    super.settings,
    super.traversalEdgeBehavior,
  }) : _page = page,
       _barrierDismissible = barrierDismissible,
       _barrierLabel = barrierLabel,
       _barrierColor = barrierColor,
       _transitionDuration = transitionDuration,
       _transitionBuilder = transitionBuilder,
       _modalBarrierBuilder = modalBarrierBuilder;

  final Widget _page;

  @override
  bool get barrierDismissible => _barrierDismissible;
  final bool _barrierDismissible;

  @override
  String? get barrierLabel => _barrierLabel;
  final String? _barrierLabel;

  @override
  Color? get barrierColor => _barrierColor;
  final Color? _barrierColor;

  @override
  Duration get transitionDuration => _transitionDuration;
  final Duration _transitionDuration;

  final SautRouteTransitionsBuilder _transitionBuilder;

  final SautModalBarrierBuilder? _modalBarrierBuilder;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: _page,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return _transitionBuilder(context, animation, secondaryAnimation, child);
  }

  @override
  Widget buildModalBarrier() {
    final modalBarrier = Builder(
      builder: (context) {
        if (barrierColor != null && barrierColor!.alpha != 0 && !offstage) { // changedInternalState is called if barrierColor or offstage updates
          assert(barrierColor != barrierColor!.withOpacity(0.0));
          final Animation<Color?> color = animation!.drive(
            ColorTween(
              begin: barrierColor!.withOpacity(0.0),
              end: barrierColor, // changedInternalState is called if barrierColor updates
            ).chain(CurveTween(curve: barrierCurve)), // changedInternalState is called if barrierCurve updates
          );
          return AnimatedModalBarrier(
            color: color,
            dismissible: barrierDismissible, // changedInternalState is called if barrierDismissible updates
            semanticsLabel: barrierLabel, // changedInternalState is called if barrierLabel updates
            barrierSemanticsDismissible: semanticsDismissible,
            onDismiss: () => Saut.back(context),
          );
        } else {
          return ModalBarrier(
            dismissible: barrierDismissible, // changedInternalState is called if barrierDismissible updates
            semanticsLabel: barrierLabel, // changedInternalState is called if barrierLabel updates
            barrierSemanticsDismissible: semanticsDismissible,
            onDismiss: () => Saut.back(context),
          );
        }
      }
    );

    return _modalBarrierBuilder?.call(modalBarrier) ?? modalBarrier;
  }

  @override
  void dispose() {
    _transitionBuilder.dispose();
    super.dispose();
  }
}
