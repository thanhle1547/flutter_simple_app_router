import 'package:example_router_delegate/cubits/post_favorites/post_favorites_cubit.dart';
import 'package:example_router_delegate/cubits/post_published/post_published_cubit.dart';
import 'package:example_router_delegate/cubits/post_published/post_published_state.dart';
import 'package:example_router_delegate/cubits/post_trending/post_trending_cubit.dart';
import 'package:example_router_delegate/routes/app_pages.dart';
import 'package:example_router_delegate/routes/stacked_pages.dart';
import 'package:example_router_delegate/screens/post_trending_dialog.dart';
import 'package:example_router_delegate/widget/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      body: BlocBuilder<PostPublishedCubit, PostPublishedState>(
        builder: (_, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: state.names.length,
            itemBuilder: (_, index) => Padding(
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _fabPressedHandler(context),
        child: const Icon(Icons.undo_rounded),
      ),
    );
  }
}
