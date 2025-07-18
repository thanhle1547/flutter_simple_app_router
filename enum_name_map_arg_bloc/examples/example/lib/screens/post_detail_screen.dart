import 'package:flutter/material.dart';
import 'package:example/widget/favorite_button.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({
    super.key,
    required this.name,
    required this.id,
  });

  final String name;
  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post detail'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(name),
            FavoriteButton(id: id),
          ],
        ),
      ),
    );
  }
}
