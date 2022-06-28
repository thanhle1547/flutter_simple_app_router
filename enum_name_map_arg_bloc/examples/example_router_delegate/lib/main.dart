import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';

import 'cubits/post_favorites/post_favorites_cubit.dart';
import 'notification_controller.dart';
import 'routes/app_pages.dart';
import 'routes/routes.dart';
import 'routes/stacked_pages.dart';

AppPages? initialPage;
AppPageStack? initialPageStackName;
Map<String, dynamic>? arguments;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // configure route
  Saut.setDefaultConfig(
    initialPage: AppPages.Initial,
    routes: routes,
    stackedPages: stackedPages,
    routeNameBuilder: mixedCaseWithUnderscoresEnumRouteNameBuilder,
  );

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await NotificationController.getNotificationAppLaunchDetails();

  selectedNotificationPayload = notificationAppLaunchDetails?.payload;

  if ((notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) &&
      selectedNotificationPayload != null) {
    initialPage = null;
    initialPageStackName = AppPageStack.detailTredingPost;
    arguments = selectedNotificationPayload == null
        ? null
        : {
            ...jsonDecode(selectedNotificationPayload!) as Map<String, dynamic>,
            // checkout Q&A in README.md
            'postFavoritesCubitCompleter': Completer<PostFavoritesCubit>(),
          };
  } else {
    initialPage = AppPages.Initial;
    initialPageStackName = null;
    arguments = null;
  }

  // initialization notification settings
  NotificationController.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SAUT Example: using Router for navigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      routeInformationParser: const SautRouteInformationParser(),
      routerDelegate: Saut.createRouterDelegateIfNotExisted(
        navigatorObservers: [SautRouteLoggingObserver()],
        initialPage: initialPage,
        initialPageStackName: initialPageStackName,
        arguments: arguments,
      ),
    );
  }
}
