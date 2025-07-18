import 'dart:async';

import 'package:example_router_delegate/cubits/post_favorites/post_favorites_cubit.dart';
import 'package:example_router_delegate/cubits/post_trending/post_trending_cubit.dart';
import 'package:example_router_delegate/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';

class PostTrendingDialogContent extends StatelessWidget {
  const PostTrendingDialogContent({
    super.key,
    this.postFavoritesCubitCompleter,
  });

  // checkout Q&A in README.md
  final Completer<PostFavoritesCubit>? postFavoritesCubitCompleter;

  @override
  Widget build(BuildContext context) {
    final state = context.read<PostTrendingCubit>().state;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Trending',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 12),
          TrendingItem(
            name: state.topOne!,
            id: 1,
            postFavoritesCubitCompleter: postFavoritesCubitCompleter,
          ),
          const SizedBox(height: 6),
          TrendingItem(
            name: state.secondary!,
            id: 2,
            postFavoritesCubitCompleter: postFavoritesCubitCompleter,
          ),
        ],
      ),
    );
  }
}

class TrendingItem extends StatelessWidget {
  const TrendingItem({
    super.key,
    required this.name,
    required this.id,
    this.postFavoritesCubitCompleter,
  });

  final int id;
  final String name;

  final Completer<PostFavoritesCubit>? postFavoritesCubitCompleter;

  void _listItemTapHandler(BuildContext context) {
    try {
      final PostFavoritesCubit cubit = context.read<PostFavoritesCubit>();

      Saut.toPage(
        context,
        AppPages.Post_Detail,
        blocValue: cubit,
        arguments: {
          'name': name,
          'id': id,
        },
      );
    } catch (e) {
      if (postFavoritesCubitCompleter != null) {
        // checkout Q&A in README.md
        postFavoritesCubitCompleter?.future.then((cubit) {
          Saut.toPage(
            context,
            AppPages.Post_Detail,
            blocValue: cubit,
            arguments: {
              'name': name,
              'id': id,
            },
          );
        });
      } else {
        throw 'PostFavoritesCubit not found';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      // need Material
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _listItemTapHandler(context),
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
            ),
            child: Center(
              child: Text(name),
            ),
          ),
        ),
      ),
    );
  }
}
