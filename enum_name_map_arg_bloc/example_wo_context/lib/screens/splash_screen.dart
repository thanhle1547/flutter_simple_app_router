import 'package:flutter/material.dart';
import 'package:saut_enma_bloc/enum_name_map_arg_bloc.dart';
import 'package:saut_example_wo_context/routes/app_pages.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1200)).then((value) {
        Saut.navigator.replaceAllWithPage(
          AppPages.Post_Published,
          transition: RouteTransition.fadeIn,
          curve: Curves.easeIn,
          duration: const Duration(milliseconds: 450),
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
