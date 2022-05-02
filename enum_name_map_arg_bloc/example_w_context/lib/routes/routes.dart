import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';
import 'package:saut_example_w_context/cubits/post_favorites/post_favorites_cubit.dart';
import 'package:saut_example_w_context/cubits/post_published/post_published_cubit.dart';
import 'package:saut_example_w_context/screens/post_detail_screen.dart';
import 'package:saut_example_w_context/screens/post_published_screen.dart';

import 'app_pages.dart';

late final RouteConfig _postPublished = RouteConfig(
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

late final RouteConfig _postDetail = RouteConfig(
  requiredArguments: {
    'name': String,
    'id': int,
  },
  pageBuilder: (arguments) => PostDetailScreen(
    name: arguments!['name'] as String,
    id: arguments['id'] as int,
  ),
  transition: RouteTransition.rightToLeftWithFade,
  opaque: true,
  fullscreenDialog: false,
);

late final Map<Enum, RouteConfig> routes = {
  AppPages.Initial: _postPublished,
  AppPages.Post_Published: _postPublished,
  AppPages.Post_Detail: _postDetail,
};
