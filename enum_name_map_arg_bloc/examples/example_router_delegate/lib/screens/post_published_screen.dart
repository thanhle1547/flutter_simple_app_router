import 'dart:async';
import 'dart:convert';

import 'package:example_router_delegate/cubits/post_favorites/post_favorites_cubit.dart';
import 'package:example_router_delegate/cubits/post_published/post_published_cubit.dart';
import 'package:example_router_delegate/cubits/post_published/post_published_state.dart';
import 'package:example_router_delegate/cubits/post_trending/post_trending_cubit.dart';
import 'package:example_router_delegate/notification_controller.dart';
import 'package:example_router_delegate/routes/app_pages.dart';
import 'package:example_router_delegate/routes/routes.dart';
import 'package:example_router_delegate/routes/stacked_pages.dart';
import 'package:example_router_delegate/widget/post_trending_dialog_content.dart';
import 'package:example_router_delegate/widget/favorite_button.dart';
import 'package:example_router_delegate/widget/modified_popup_menu.dart';
import 'package:example_router_delegate/widget/post_trending_modal_bottom_sheet_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';

class PostPublishedScreen extends StatelessWidget {
  const PostPublishedScreen({Key? key}) : super(key: key);

  void _listItemTapHandler(BuildContext context, String name, int id) {
    Saut.toPage(
      context,
      AppPages.Post_Detail,
      blocValue: context.read<PostFavoritesCubit>(),
      arguments: {
        'name': name,
        'id': id,
      },
    );
  }

  void _showTrendingPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.blue.shade700,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => PostTrendingCubit(),
            ),
            BlocProvider.value(
              value: context.read<PostFavoritesCubit>(),
            ),
          ],
          child: const PostTrendingDialogContent(),
        ),
      ),
      routeSettings: Saut.createRouteSettings(
        name: mixedCaseWithUnderscoresEnumRouteNameBuilder(
          AppPages.Post_Trending,
        ),
      ),
    );
  }

  void _navigateToTrendingPostDialog(BuildContext context) {
    Saut.toPage(
      context,
      AppPages.Post_Trending,
      blocValue: context.read<PostFavoritesCubit>(),
    );
  }

  void _setStackTrendingPost(BuildContext context) {
    Saut.setPageStack(
      context,
      AppPageStack.tredingPost,
      arguments: {
        'PostFavoritesCubit': context.read<PostFavoritesCubit>(),
      },
    );
  }

  void _navigateToUnconfiguredTrendingPostDialog(BuildContext context) {
    Saut.toUnconfiguredPage(
      context,
      routeConfig: RouteConfig(
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
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => PostTrendingCubit(),
              ),
              BlocProvider.value(
                value: context.read<PostFavoritesCubit>(),
              ),
            ],
            child: const PostTrendingDialogContent(),
          );
        },
        transitionsBuilder: SautRouteTransition.none,
      ),
      name: 'unconfigured-trending-post-dialog',
    );
  }

  void _navigateToModifiedTrendingPostDialog(BuildContext context) {
    Saut.toUnconfiguredPage(
      context,
      routeConfig: postTrending.copyWith(
        routeBuilder: <Void>(
          BuildContext context,
          RouteConfig resolvedConfig,
          RouteSettings settings,
          Widget page,
        ) {
          return DialogRoute(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.amber.shade700, // Change the color
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.zero), // Remove BorderRadius
              ),
              child: BlocProvider.value(
                value: context.read<PostFavoritesCubit>(),
                child: page,
              ),
            ),
            settings: settings,
          );
        },
        transitionsBuilder: SautRouteTransition.none,
      ),
      page: AppPageStack.tredingPost,
    );
  }

  void _navigateToTrendingPostDialogWithCustomBarrier(BuildContext context) {
    Saut.toPage(
      context,
      AppPages.Post_Trending_CustomBarrier,
      blocValue: context.read<PostFavoritesCubit>(),
    );
  }

  void _showTrendingPostModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: PostTrendingModalBottomSheetContent.shape,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => PostTrendingCubit(),
            ),
            BlocProvider.value(
              value: context.read<PostFavoritesCubit>(),
            ),
          ],
          child: const PostTrendingModalBottomSheetContent(),
        );
      },
      routeSettings: Saut.createRouteSettings(
        name: mixedCaseWithUnderscoresEnumRouteNameBuilder(
          AppPages.Post_Trending,
        ),
      ),
    );
  }

  void _navigateToTrendingPostModalBottomSheet(BuildContext context) {
    Saut.toPage(
      context,
      AppPages.Post_TrendingModalBottomSheet,
      blocValue: context.read<PostFavoritesCubit>(),
    );
  }

  void _navigateToVariantTrendingPostDialog(BuildContext context) {
    Saut.toPage(
      context,
      AppPages.Post_TrendingVariant,
      blocValue: context.read<PostFavoritesCubit>(),
    );
  }

  /// An error will be shown in the debug console
  void _fabPressedHandler(BuildContext context) {
    Saut.toPage(context, AppPages.Post_Suggest);
  }

  @override
  Widget build(BuildContext context) {
    final postList = BlocBuilder<PostPublishedCubit, PostPublishedState>(
      builder: (_, state) {
        if (state.isLoading) {
          return const SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: InkWell(
                  onTap: () => _listItemTapHandler(
                    context,
                    state.names[index],
                    index,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                  child: Ink(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, -1),
                          color: Colors.black12,
                          blurRadius: 24,
                          spreadRadius: -14,
                        ),
                      ],
                    ),
                    child: Center(
                      child: ListTile(
                        title: Text(state.names[index]),
                        trailing: FavoriteButton(id: index),
                      ),
                    ),
                  ),
                ),
              ),
              childCount: state.names.length,
            ),
          ),
        );
      },
    );

    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post published'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _navigateToTrendingPostDialog(context),
            tooltip: '"Navigate to" Trending Post Dialog',
            icon: const Icon(Icons.trending_up_rounded),
          ),
          _PopupMenuButton(
            entries: [
              ModifiedPopupMenuItem(
                onTap: () {
                  _showTrendingPostDialog(context);
                },
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                labelTextStyle: MaterialStateTextStyle.resolveWith(
                  (states) => textTheme.labelLarge!.copyWith(color: Colors.red),
                ),
                child: const Text('Show Trending Post Dialog by using showDialog api'),
              ),
              ModifiedPopupMenuItem(
                onTap: () {
                  _setStackTrendingPost(context);
                },
                child: const Text('Set Stack: TrendingPost'),
              ),
              ModifiedPopupMenuItem(
                onTap: () {
                  _navigateToUnconfiguredTrendingPostDialog(context);
                },
                child: const Text('"Navigate to" Unconfigured Trending Post Dialog'),
              ),
              ModifiedPopupMenuItem(
                onTap: () {
                  _navigateToModifiedTrendingPostDialog(context);
                },
                child: const Text('"Navigate to" Modified Trending Post Dialog'),
              ),
              ModifiedPopupMenuItem(
                onTap: () {
                  _navigateToTrendingPostDialogWithCustomBarrier(context);
                },
                child: const Text('"Navigate to" Trending Post Dialog with custom barrier'),
              ),
              ModifiedPopupMenuItem(
                onTap: () {
                  _showTrendingPostModalBottomSheet(context);
                },
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                labelTextStyle: MaterialStateTextStyle.resolveWith(
                  (states) => textTheme.labelLarge!.copyWith(color: Colors.red),
                ),
                child: const Text('Show Trending Post Modal Bottom Sheet by using showModalBottomSheet api'),
              ),
              ModifiedPopupMenuItem(
                onTap: () {
                  _navigateToTrendingPostModalBottomSheet(context);
                },
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Text('"Navigate to" Trending Post Modal Bottom Sheet'),
              ),
              ModifiedPopupMenuItem(
                onTap: () {
                  _navigateToVariantTrendingPostDialog(context);
                },
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Text('"Navigate to" Trending Post Dialog with the route built by SautDialogRouteBuilder'),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: const Color(0xEEFFFDFF),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: NotificationTestingBanner(),
          ),
          postList,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fabPressedHandler(context),
        tooltip: 'An error will be shown in the debug console',
        child: const Icon(Icons.undo_rounded),
      ),
    );
  }
}

class _PopupMenuButton extends StatefulWidget {
  const _PopupMenuButton({required this.entries});

  final List<PopupMenuEntry<dynamic>> entries;

  @override
  State<_PopupMenuButton> createState() => __PopupMenuButtonState();
}

class __PopupMenuButtonState extends State<_PopupMenuButton> {
  final ValueNotifier<bool> useImperativeApiToOpenPopupMenu = ValueNotifier(false);
  final ValueNotifier<bool> useImperativeApiToDismissPopupMenu = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ModifiedPopupMenuButton(
      useImperativeApiToOpen: useImperativeApiToOpenPopupMenu.value,
      useImperativeApiToDismiss: useImperativeApiToDismissPopupMenu.value,
      onCanceled: () {
        setState(() {});
      },
      itemBuilder: (context) {
        return [
          ...widget.entries,
          ModifiedPopupMenuItem(
            enabled: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Use Saut api to open this popup menu',
                    style: textTheme.labelLarge,
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: useImperativeApiToOpenPopupMenu,
                  builder: (context, useImperativeApiToOpenPopupMenu, child) {
                    return Checkbox(
                      value: !useImperativeApiToOpenPopupMenu,
                      onChanged: (value) {
                        this.useImperativeApiToOpenPopupMenu.value = !value!;

                        if (!value) {
                          useImperativeApiToDismissPopupMenu.value = true;
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          ModifiedPopupMenuItem(
            enabled: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Use Saut api to dismiss this popup menu',
                    style: textTheme.labelLarge,
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: useImperativeApiToDismissPopupMenu,
                  builder: (context, useImperativeApiToDismissPopupMenu, child) {
                    return Checkbox(
                      value: !useImperativeApiToDismissPopupMenu,
                      onChanged: (value) {
                        this.useImperativeApiToDismissPopupMenu.value = !value!;

                        if (value) {
                          useImperativeApiToOpenPopupMenu.value = false;
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ];
      },
    );
  }
}

class NotificationTestingBanner extends StatefulWidget {
  const NotificationTestingBanner({Key? key}) : super(key: key);

  @override
  State<NotificationTestingBanner> createState() =>
      _NotificationTestingBannerState();
}

class _NotificationTestingBannerState extends State<NotificationTestingBanner> {
  void _showTrendingPostNotification() {
    NotificationController.showNotification(
      config: NotificationConfig.trending,
      id: 0,
      title: 'Trending Post',
      body: 'Tap to see the detail',
      data: {
        'name': 'One',
        'id': 0,
      },
    );
  }

  void _zonedScheduleTrendingPostNotification() {
    NotificationController.zonedScheduleNotification(
      config: NotificationConfig.trending,
      id: 0,
      title: 'Trending Post',
      body: 'Tap to see the detail',
      duration: const Duration(seconds: 10),
      data: {
        'name': 'One',
        'id': 0,
      },
    );
  }

  @override
  void initState() {
    super.initState();
    NotificationController.requestPermissions();
    _configureSelectNotificationSubject();
  }

  late final StreamSubscription<NotificationResponse> _selectNotificationStreamSubscription;

  void _configureSelectNotificationSubject() {
    _selectNotificationStreamSubscription = 
        NotificationController.selectNotificationStream.stream.listen(_handleNotification);
  }

  void _handleNotification(NotificationResponse? response) {
    if (response == null) return;

    final String? rawData = response.payload;

    if (rawData == null) return;

    final Map<String, dynamic> data = jsonDecode(rawData) as Map<String, dynamic>;

    _setStackDetailTrendingPost(
      name: data['name'],
      id: data['id'],
    );
  }

  void _setStackDetailTrendingPost({
    required String name,
    required int id,
  }) {
    Saut.setPageStack(
      context,
      AppPageStack.detailTredingPost,
      arguments: {
        'name': name,
        'id': id,
        'PostFavoritesCubit': context.read<PostFavoritesCubit>(),
      },
    );
  }

  @override
  void dispose() {
    _selectNotificationStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      padding: const EdgeInsets.all(16),
      content: const Text(
        'Show a notification about trending post '
        'that will take to the detail screen when you tapped',
      ),
      actions: [
        TextButton(
          onPressed: _showTrendingPostNotification,
          child: const Text('START NOW'),
        ),
        Tooltip(
          message: 'Schedule notification to appear in 10 seconds '
              'based on local time zone (you can close the app). ',
          child: TextButton(
            onPressed: _zonedScheduleTrendingPostNotification,
            child: const Text('Schedule in 10 seconds later'),
          ),
        ),
      ],
    );
  }
}
