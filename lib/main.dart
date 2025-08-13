import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/locator.dart';
import 'ui/home/home_feed_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final prefs = await SharedPreferences.getInstance();
  await setupLocator(prefs);
  runApp(ProviderScope(overrides: [
    sharedPrefsProvider.overrideWithValue(prefs),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Short Lived',
      theme: ThemeData.dark(),
      home: const HomeFeedPage(),
    );
  }
}
