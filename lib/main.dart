import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/app_router.dart';

// Conditional import: on web use the real implementation, elsewhere the stub.
import 'util/sw_debug_stub.dart'
  if (dart.library.html) 'util/sw_debug_web.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Print Flutter framework errors to the browser console.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  // In debug on web, unregister any stale service workers and caches.
  assert(() {
    if (kIsWeb) {
      // Fire-and-forget; we don't await to avoid slowing startup.
      // ignore: unawaited_futures
      killServiceWorkersInDebug();
    }
    return true;
  }());

  runZonedGuarded(
    () => runApp(MaterialApp(
      navigatorKey: AppRouter.navKey,
      onGenerateRoute: AppRouter.onGenerate,
      home: const Placeholder(),
    )),
    (Object error, StackTrace stack) {
      // Surface uncaught errors in console for web debug.
      // ignore: avoid_print
      print('Uncaught zone error: $error\n$stack');
    },
  );
}
