import 'package:flutter/material.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';

import 'routes/app_pages.dart';
import 'routes/routes.dart';
import 'screens/splash_screen.dart';

void main() {
  Saut.setDefaultConfig(
    initialPage: AppPages.Initial,
    routes: routes,
    routeNameBuilder: mixedCaseWithUnderscoresEnumRouteNameBuilder,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAUT Example: navigation without context',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      navigatorKey: Saut.createNavigatorKeyIfNotExisted(),
      navigatorObservers: [SautRouteLoggingObserver()],
      home: const SplashScreen(),
    );
  }
}
