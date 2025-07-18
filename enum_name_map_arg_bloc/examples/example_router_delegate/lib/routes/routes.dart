import 'dart:async';
import 'dart:ui';

import 'package:example_router_delegate/cubits/post_favorites/post_favorites_cubit.dart';
import 'package:example_router_delegate/cubits/post_published/post_published_cubit.dart';
import 'package:example_router_delegate/cubits/post_trending/post_trending_cubit.dart';
import 'package:example_router_delegate/screens/post_detail_screen.dart';
import 'package:example_router_delegate/screens/post_published_screen.dart';
import 'package:example_router_delegate/widget/post_trending_dialog_content.dart';
import 'package:example_router_delegate/screens/splash_screen.dart';
import 'package:example_router_delegate/widget/post_trending_modal_bottom_sheet_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';

import 'app_pages.dart';

final RouteConfig _splash = RouteConfig(
  pageBuilder: (arguments) => const SplashScreen(),
);

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
    child: Builder(
      key: const Key('trending'),
      builder: (context) {
        // checkout Q&A in README.md
        final Completer<PostFavoritesCubit>? completer =
            arguments?['postFavoritesCubitCompleter'];

        if (completer != null && completer.isCompleted == false) {
          completer.complete(context.read<PostFavoritesCubit>());
          arguments?.addAll({
            'PostFavoritesCubit': context.read<PostFavoritesCubit>(),
          });
        }

        return const PostPublishedScreen();
      },
    ),
  ),
);

final RouteConfig postTrending = RouteConfig(
  routeBuilder: <Void>(
    BuildContext context,
    RouteConfig resolvedConfig,
    RouteSettings settings,
    Widget page,
  ) {
    return DialogRoute(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.blue.shade700,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: page,
      ),
      settings: settings,
    );
  },
  pageBuilder: (arguments) {
    final Completer<PostFavoritesCubit>? completer =
        arguments?['postFavoritesCubitCompleter'];
    final PostFavoritesCubit? postFavoritesCubit =
        arguments?['PostFavoritesCubit'];

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PostTrendingCubit(),
        ),
        if (postFavoritesCubit != null)
          BlocProvider.value(value: postFavoritesCubit),
      ],
      child: PostTrendingDialogContent(
        postFavoritesCubitCompleter: completer,
      ),
    );
  },
  transitionsBuilder: SautRouteTransition.none,
);

Widget _buildPostTrendingDialogVariant(Map<String, dynamic>? arguments) {
  final Completer<PostFavoritesCubit>? completer = arguments?['postFavoritesCubitCompleter'];
  final PostFavoritesCubit? postFavoritesCubit = arguments?['PostFavoritesCubit'];

  return MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => PostTrendingCubit(),
      ),
      if (postFavoritesCubit != null)
        BlocProvider.value(value: postFavoritesCubit),
    ],
    child: Dialog(
      backgroundColor: Colors.orange.shade300,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: PostTrendingDialogContent(
        postFavoritesCubitCompleter: completer,
      ),
    ),
  );
}

final RouteConfig postTrendingVariant = RouteConfig(
  routeBuilder: SautDialogRouteBuilder(
    barrierColor: Colors.amber.withAlpha(66), // opacity 40%
  ).call,
  pageBuilder: _buildPostTrendingDialogVariant,
  transitionsBuilder: SautRouteTransition.downToUp,
);

final RouteConfig _postTrendingVariantModalBottomSheet = RouteConfig(
  routeBuilder: const SautModalBottomSheetRouteBuilder().call,
  pageBuilder: (arguments) {
    final PostFavoritesCubit? postFavoritesCubit =
      arguments?['PostFavoritesCubit'];

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PostTrendingCubit(),
        ),
        if (postFavoritesCubit != null)
          BlocProvider.value(value: postFavoritesCubit),
      ],
      child: const PostTrendingModalBottomSheetContent(),
    );
  },
);

final RouteConfig _postTrendingVariantCustomBarrier = RouteConfig(
  routeBuilder: SautDialogRouteBuilder(
    barrierColor: Colors.black12,
    modalBarrierBuilder: (superModalBarrier) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        blendMode: BlendMode.srcATop,
        child: superModalBarrier,
      );
    },
  ).call,
  pageBuilder: _buildPostTrendingDialogVariant,
  transitionsBuilder: SautRouteTransition.downToUp,
);

final RouteConfig _postDetail = RouteConfig(
  debugRequiredArguments: {
    'name': String,
    'id': int,
  },
  pageBuilder: (arguments) {
    final PostFavoritesCubit? postFavoritesCubit =
        arguments?['PostFavoritesCubit'];

    final screen = PostDetailScreen(
      name: arguments!['name'] as String,
      id: arguments['id'] as int,
    );

    if (postFavoritesCubit != null) {
      return BlocProvider.value(
        value: postFavoritesCubit,
        child: screen,
      );
    }

    return screen;
  },
  transitionsBuilder: SautRouteTransition.rightToLeftWithFade,
  opaque: true,
  fullscreenDialog: false,
);

final Map<Enum, RouteConfig> routes = {
  AppPages.Initial: _splash,
  AppPages.Post_Published: _postPublished,
  AppPages.Post_Trending: postTrending,
  AppPages.Post_TrendingVariant: postTrendingVariant,
  AppPages.Post_TrendingModalBottomSheet: _postTrendingVariantModalBottomSheet,
  AppPages.Post_Trending_CustomBarrier: _postTrendingVariantCustomBarrier,
  AppPages.Post_Detail: _postDetail,
};
