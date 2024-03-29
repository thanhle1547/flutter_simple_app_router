import 'dart:convert';

import 'package:example_router_delegate/cubits/post_favorites/post_favorites_cubit.dart';
import 'package:example_router_delegate/cubits/post_published/post_published_cubit.dart';
import 'package:example_router_delegate/cubits/post_published/post_published_state.dart';
import 'package:example_router_delegate/cubits/post_trending/post_trending_cubit.dart';
import 'package:example_router_delegate/notification_controller.dart';
import 'package:example_router_delegate/routes/app_pages.dart';
import 'package:example_router_delegate/routes/stacked_pages.dart';
import 'package:example_router_delegate/screens/post_trending_dialog.dart';
import 'package:example_router_delegate/widget/favorite_button.dart';
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
          child: const PostTrendingDialog(),
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
    Saut.setPageStack(AppPageStack.tredingPost, {
      'PostFavoritesCubit': context.read<PostFavoritesCubit>(),
    });
  }

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post published'),
        centerTitle: true,
        actions: [
          IconButton(
            // Toggle one of the lines below to see
            // onPressed: () => _showTrendingPostDialog(context),
            // onPressed: () => _navigateToTrendingPostDialog(context),
            onPressed: () => _setStackTrendingPost(context),
            icon: const Icon(Icons.trending_up_rounded),
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
        child: const Icon(Icons.undo_rounded),
      ),
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
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }

  void _requestPermissions() {
    NotificationController.plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    NotificationController.plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    NotificationController.receivedNotificationStream
        .listen((ReceivedNotification receivedNotification) async {
      _handleNotification(receivedNotification.payload);
    });
  }

  void _configureSelectNotificationSubject() {
    NotificationController.selectedNotificationStream
        .listen(_handleNotification);
  }

  void _handleNotification(String? rawData) {
    if (rawData == null) return;

    final Map<String, dynamic> data =
        jsonDecode(rawData) as Map<String, dynamic>;
    _setStackDetailTrendingPost(
      name: data['name'],
      id: data['id'],
    );
  }

  void _setStackDetailTrendingPost({
    required String name,
    required int id,
  }) {
    Saut.setPageStack(AppPageStack.detailTredingPost, {
      'name': name,
      'id': id,
      'PostFavoritesCubit': context.read<PostFavoritesCubit>(),
    });
  }

  @override
  void dispose() {
    NotificationController.closeReceivedNotificationStream();
    NotificationController.closeSelectedNotificationStream();
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
