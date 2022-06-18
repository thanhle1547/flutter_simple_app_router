late final RegExp _keyPattern = RegExp('(?<=[a-z])[A-Z]');

extension on Object {
  String get key => toString()
      .split('.')
      .last
      .replaceAll('_', '.')
      .replaceAllMapped(
        _keyPattern,
        (Match m) => "_${m.group(0) ?? ''}",
      )
      .toLowerCase();

  String get path => "/${key.replaceAll('.', '/')}";
}

/// Transform enums name to the string that represent route name.
///
/// The defined enum somehow similar to
/// __Mixed_Case_With_Underscores__,
/// __Ada_Case__
///
/// example:
///
/// ```dart
/// enmaRouteNameBuilder(AppPages.Auth_Sign_In)
/// ```
/// ⇒  `auth/sign/in`
///
/// ```dart
/// enmaRouteNameBuilder(AppPages.Auth_SignIn)
/// ```
/// ⇒  `auth/sign_in`
///
/// ```dart
/// enmaRouteNameBuilder(AppPages.AuthSignIn)
/// ```
/// ⇒  `auth_sign_in`
String mixedCaseWithUnderscoresEnumRouteNameBuilder(Object page) => page.path;
