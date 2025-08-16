import 'package:flutter/material.dart';
import 'core/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRouter.navKey,
      onGenerateRoute: AppRouter.onGenerate,
      home: const Placeholder(),
    );
  }
}
