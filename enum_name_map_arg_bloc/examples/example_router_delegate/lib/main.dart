import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';

import 'cubits/post_favorites/post_favorites_cubit.dart';
import 'routes/app_pages.dart';
import 'routes/routes.dart';
import 'routes/stacked_pages.dart';

void main() {
  Saut.setDefaultConfig(
    initialPage: AppPages.Initial,
    routes: routes,
    stackedPages: stackedPages,
    routeNameBuilder: mixedCaseWithUnderscoresEnumRouteNameBuilder,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SAUT Example: navigation with context',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      routeInformationParser: const SautRouteInformationParser(),
      routerDelegate: Saut.createRouterDelegateIfNotExisted(
          navigatorObservers: [SautRouteLoggingObserver()],
          initialPageStackName: AppPageStack.detailTredingPost,
          arguments: {
            'name': 'One',
            'id': 1,
            'postFavoritesCubitCompleter': Completer<PostFavoritesCubit>(),
          }),
    );
  }
}
