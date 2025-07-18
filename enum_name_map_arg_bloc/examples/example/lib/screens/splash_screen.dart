import 'package:flutter/material.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';
import 'package:example/routes/app_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1200)).then((value) {
        Saut.replaceAllWithPage(
          context,
          AppPages.Post_Published,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).primaryColor,
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColorLight,
        ),
      ),
    );
  }
}
