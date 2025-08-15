import 'package:flutter/material.dart';
import 'core/app_router.dart';

void main() {
  runApp(MaterialApp(
    navigatorKey: AppRouter.navKey,
    onGenerateRoute: AppRouter.onGenerate,
    home: const Placeholder(),
  ));
}
