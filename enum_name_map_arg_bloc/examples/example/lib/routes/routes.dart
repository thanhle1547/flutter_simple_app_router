import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';
import 'package:example/cubits/post_favorites/post_favorites_cubit.dart';
import 'package:example/cubits/post_published/post_published_cubit.dart';
import 'package:example/screens/post_detail_screen.dart';
import 'package:example/screens/post_published_screen.dart';

import 'app_pages.dart';

final RouteConfig _postPublished = RouteConfig(
  pageBuilder: (arguments) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => PostPublishedCubit(),
      ),
      BlocProvider(
        create: (_) => PostFavoritesCubit(),
      ),
    ],
    child: const PostPublishedScreen(),
  ),
  opaque: true,
  fullscreenDialog: false,
);

final RouteConfig _postDetail = RouteConfig(
  debugRequiredArguments: {
    'name': String,
    'id': int,
    'exampleRequiredIntegerList': 'List<int>',
    'exampleRequiredDynamicList': List,
    'exampleRequiredDynamicMap': Map,
    // uncomment the line below to see the error
    // 'exampleWrongRequiredArgumentDeclaration': dynamic,
    'exampleRequiredIntArgumentButTheDeclarationIsNumber': 9,
  },
  pageBuilder: (arguments) => PostDetailScreen(
    name: arguments!['name'] as String,
    id: arguments['id'] as int,
  ),
  transitionsBuilder: SautRouteTransition.rightToLeftWithFade,
  opaque: true,
  fullscreenDialog: false,
);

final Map<Enum, RouteConfig> routes = {
  AppPages.Initial: _postPublished,
  AppPages.Post_Published: _postPublished,
  AppPages.Post_Detail: _postDetail,
};
