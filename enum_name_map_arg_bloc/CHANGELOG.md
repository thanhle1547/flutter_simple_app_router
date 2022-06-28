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
