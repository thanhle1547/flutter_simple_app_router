import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example/cubits/post_favorites/post_favorites_cubit.dart';
import 'package:example/cubits/post_favorites/post_favorites_state.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostFavoritesCubit, PostFavoritesState>(
      builder: (context, state) => IconButton(
        onPressed: () => context.read<PostFavoritesCubit>().toogle(id),
        icon: Icon(
          context.read<PostFavoritesCubit>().hasSaved(id)
              ? Icons.favorite
              : Icons.favorite_border,
          color: Colors.red[300],
        ),
      ),
    );
  }
}
