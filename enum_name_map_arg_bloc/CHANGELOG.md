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
