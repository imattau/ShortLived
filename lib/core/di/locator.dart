import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupLocator(SharedPreferences prefs) async {
  getIt.registerSingleton<SharedPreferences>(prefs);
  // register other services here
}
