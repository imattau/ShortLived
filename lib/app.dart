import 'package:flutter/material.dart';
import 'core/app_router.dart';
import 'ui/design/theme.dart';
import 'ui/home/home_page.dart';
import 'navigation/route_observer.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRouter.navKey,
      onGenerateRoute: AppRouter.onGenerate,
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      theme: appThemeDark,
      home: const HomePage(),
    );
  }
}
