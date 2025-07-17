import 'package:example_router_delegate/cubits/post_favorites/post_favorites_cubit.dart';
import 'package:example_router_delegate/cubits/post_trending/post_trending_cubit.dart';
import 'package:example_router_delegate/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';

class PostTrendingModalBottomSheetContent extends StatelessWidget {
  const PostTrendingModalBottomSheetContent({
    Key? key,
  }) : super(key: key);

  static const RoundedRectangleBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16))
  );

  @override
  Widget build(BuildContext context) {
    final state = context.read<PostTrendingCubit>().state;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Trending',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            TrendingItem(
              name: state.topOne!,
              id: 1,
            ),
            const SizedBox(height: 10),
            TrendingItem(
              name: state.secondary!,
              id: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class TrendingItem extends StatelessWidget {
  const TrendingItem({
    Key? key,
    required this.name,
    required this.id,
  }) : super(key: key);

  final int id;
  final String name;

  void _listItemTapHandler(BuildContext context) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _listItemTapHandler(context),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: const BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Center(
            child: Text(name),
          ),
        ),
      ),
    );
  }
}
