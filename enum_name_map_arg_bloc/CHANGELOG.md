## 0.15.1

* bump minimum Dart SDK version to 3.1.0 ~ Flutter 3.13.0

* update `example`, `example_router_delegate` examples to Flutter 3.13.9

* update `SautModalBottomSheetRouteBuilder` following these flutter PRs:
  - [Fix bottom sheet rebuilding when tapping](https://github.com/flutter/flutter/pull/127526)
  - [Support keeping a bottom sheet with a DraggableScrollableSheet from closing on drag/fling to min extent](https://github.com/flutter/flutter/pull/127339)

## 0.15.0

* bump minimum Dart SDK version to 3.0.0 ~ Flutter 3.10

* update `example`, `example_router_delegate` examples to Flutter 3.10.6

* fix remaining navigation issues when using SautRouterDelegate

* **add** `SautRouteTransitionsBuilder` and some pre-built:
  - `SautRawDialogRouteTransitionsBuilder`
  - `SautMaterialDialogRouteTransitionsBuilder`

* `SautDialogRouteBuilder`:
  - add `traversalEdgeBehavior` parameter
  - add `modalBarrierBuilder` parameter
  - add `useDisplayFeatureSubScreen` parameter to able to opt-out `DisplayFeatureSubScreen`, default to true
  - breaking:
    - using a copy version of `RawDialogRoute` in Flutter 3.29.3
    - `transitionBuilder` type change to `SautRouteTransitionsBuilder` and use `SautRawDialogRouteTransitionsBuilder` as default

* `SautModalBottomSheetRouteBuilder`:
  - add `barrierOnTapHint`
  - add `barrierLabel` parameter
  - add `modalBarrierBuilder` parameter
  - add `fallbackToMediaQuery` parameter to able to opt-out `MediaQuery` when `useSafeArea` is false, default to true
  - add `useDisplayFeatureSubScreen` parameter to able to opt-out `DisplayFeatureSubScreen`, default to true
  - breaking:
    - using a copy version of `ModalBottomSheetRoute` and `BottomSheet` in Flutter 3.29.3
    - remove `backgroundColor`, `elevation`, `shape`, `clipBehavior` and `anchorPoint`

* fix `Saut.back`, `Saut.backToPageName`, `Saut.backToPage`, `context.back`, `context.backToPageName`, `context.backToPage` cause navigation issues when using `SautRouterDelegate` from version 0.12.0

## 0.14.0

* update `flutter_bloc` to version 8.1.6

* bump minimum Dart SDK version to 2.19.0 ~ Flutter 3.7

* **delete** example: `example_wo_context`

* replace `example_w_context` example with new `example` project using Flutter 3.7.12

* update `example_router_delegate` to highlight menu item that will throw error on select

* fix navigation issues when using SautRouterDelegate

* **add** `SautModalBottomSheetRouteBuilder` to reduce verbosity in creating `RouteConfig.routeBuilder`

* update README about using imperative apis

* chore: update copyright year

## 0.13.0

* export `SautPage` and `SautPageKey` to make it accessible from outside this library

* **add** some `SautRouteBuilder`s to reduce verbosity in creating `RouteConfig.routeBuilder`:
  - SautDialogRouteBuilder
  - SautCupertinoModalPopupRouteBuilder
  - SautCupertinoDialogRouteBuilder

* **add** `barrierDismissible` to `RouteConfig`

* `SautPage` takes a widget as its page instead of a builder function to not delay widget creation

## 0.12.0

* fix: null check in assertion on `Saut.getCurrentRouteName`, `context.getCurrentRouteName`

* fix: assertion error `Navigator operation requested with a context that does not include a Navigator. The context used to push or pop routes from the Navigator must be that of a widget that is a descendant of a Navigator widget.` when look up the `Navigator` in `RouteConfig.routeBuilder` (e.g., DialogRoute)

* fix: the removed page did not call `completeWith` cause the navigation incomplete. This happend when using `SautRouterDelegate.backToPage`, `SautRouterDelegate.backToPageName` and `Navigator.pop*` apis

* **add** ability to go to a new page from a widget without preconfigured by using `Saut.toUnconfiguredPage`

* **add** optional `routeBuilder` and `pageBuilder` arguments to `RouteConfig.copyWith`

* **remove** valid route types assertion

* **remove** extension on `NavigatorState`

* update `example_router_delegate` to show Saut's apis usage example instead of doing toggle line comment

* breaking:

  - prefer using closest instance of `NavigatorState` that encloses the given context when using `Navigator` (not `RouterDelegate`) than the global one created via `Saut.createNavigatorKeyIfNotExisted`, affected methods are:
    - `toPage`
    - `back`
    - `backToPageName`
    - `backToPage`
    - `getCurrentRoute`
    - `getCurrentRouteName`

  - **add** `context` to `SautRouterDelegate` apis to look up the `Navigator` in `RouteConfig.routeBuilder` (e.g., DialogRoute)

  - **remove** `transitionsBuilder`, `duration`, `opaque` and `fullscreenDialog` parameters

  - **remove** `Saut.define`

  - **add** `Saut.maybeAddPageConfig`, `Saut.maybeAddPageConfigs` and `Saut.addPageConfigs`

  - use a named argument for `SautRouterDelegate.setPageStack` arguments

## 0.11.0

* Suppress transition between routes

  - Suppress previous route transition if current route is fullscreenDialog

  - Suppress outgoing route transition if the next route is a fullscreen dialog

* fix: `Navigator.of(context).backToPageName()` not working with a route that extends `PageRoute`, `CupertinoPageRoute`, `DialogRoute`

* **add** cupertino route transition

* breaking:

  - **replace** `transition`, `customTransitionBuilderDelegate` and `curve` with `transitionsBuilder`

  - **remove** `TransitionBuilderDelegate`

  - **replace** `RouteTransition` with `SautRouteTransition`

## 0.10.3

* fix: null check in assertion before call initRouterDelegate

* fix: `SautRouterDelegate.backToPage` & `SautRouterDelegate.backToPageName` remove all pages below the target page

* fix: `SautRouterDelegate.setPageStack` did not keep the current pages's state

* fix: assertion false after navigate to new page from a page that the `Route` not is the `SautPageRouteBuilder` (e.g. `DialogRoute`)

* fix: `PagePredicate` param in `SautRouterDelegate.replaceAllWithPage` not working like `RoutePredicate`

* fix: change from one screen to another did not properly get announcements and audio-feedback (Edge-triggered semantics)

## 0.10.2

* Add `abstract` modifier to `Saut` class to prevents instantiation
* Prevents extending `Saut` class by adding a private generative constructor

## 0.10.1

* fix: missing the `Route`'s return type correspond to the type argument `T` of `SautPage`
* fix: `SautPage.completeWith` did not accept null value

## 0.10.0

* **remove** `AppRouter`

## 0.9.5

* update assertion inside getPageBuilder to allow casted type & Object type

## 0.9.4

* fix: `debugRequiredArguments` declaration can be empty
* fix: `arguments` parameter can be empty

## 0.9.3

* fix: wrong assertion in `createRouterDelegateIfNotExisted`

## 0.9.2

* fix: replace all pages with an existing page but `Navigator` reserves its route state

## 0.9.1

* fix: some parameters of `EnmaNavigatorStateExtension.toPage` (`opaque`, `fullscreenDialog`, `debugPreventDuplicates`) not working

* fix: `Saut.createRouterDelegateIfNotExisted` did not use `initialPage` passed to `setDefaultConfig`

## 0.9.0

* update `SautRouteLoggingObserver`

  - change & update messages

  - override didRemove & didReplace

  - make `resolveArguments`, `getStringRepresentationOfListItems`, `dynamicWordRegex`, `buildMessageStringBuffer` public

* update docs

* update `flutter_bloc` to version 8.1.1

## 0.8.2

* When "pop" methods are invoked or there is a request from the operating system, `SautRouterDelegate` delivers unexpected behavior

* fix: `backToPage` methods

## 0.8.1

* optimize `_PagelessNavigatorObserver.didPush` method

* fix: `SautRouterDelegateExtension.replaceWithPage` did not return the value of the old route

* fix: (route logging) printing arguments to new line

## 0.8.0

* **add** route aware state mixin: 

  - `SautRouteSubscriptionStateMixin` for subscribing

  - `SautRouteListerningStateMixin` for listening

* **remove** `Saut.createRouteObserverIfNotExisted`

* fix: cannot listening or subscribing when SautRouteObserver did not create via `Saut.createRouteObserverIfNotExisted`

## 0.7.0

* **add** `RouterDelegate` and new example (using notification)

* **add** `routeBuilder` to `RouteConfig` for modal dialogs when using `RouterDelegate`

* fix: Navigator Key instance created via `Saut` or `AppRouter` was not the same

## 0.6.1

* **add** `Semantics`

* **add** `reset` (static) function

* **add** `RouteConfig.copyWith` method

* fix: `RouteObserver` instance created via `Saut` or `AppRouter` was not the same

## 0.6.0

* feat: `SautRouteObserver` is now able to register `RouteAware` to be informed about route changes.

* **add** `result` argument to `replaceWithPage` method

* breaking:

  - `getCurrentNavigatorRoute` changed to `getCurrentRoute`

  - `getCurrentNavigatorRouteName` changed to `getCurrentRouteName`

  - change `EnmaNavigatorStateExtension.backToPage()` argument type

## 0.5.0

* **add** `getModalRoutePredicate` function for convenience

## 0.4.2

* fix `createRouteFromName` function

## 0.4.1

* export `SautRouteObserver`

## 0.4.0

* **add** fallback to the `createRouteFromName` function

## 0.3.0

* breaking:

  - `requiredArguments` changed to `debugRequiredArguments`

  - `preventDuplicates` changed to `debugPreventDuplicates`

* **add** mising `debugPreventDuplicates`

## 0.2.0

* feat:

  - checking argument type funtion

  - get current navigator route

* fix: checking duplicate page

## 0.1.1

* forgot to export AppRouter.

## 0.1.0

* feat:

  - specific required argument types.

  - feat: AppRouter (same as Saut, just other name).

## 0.0.1

* First release.
