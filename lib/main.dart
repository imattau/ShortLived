import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'video/video_adapter.dart';
import 'video/video_adapter_real.dart';
import 'session/user_session.dart';
import 'data/source_selector.dart';

// Conditional import: on web use the real implementation, elsewhere the stub.
import 'util/sw_debug_stub.dart'
  if (dart.library.html) 'util/sw_debug_web.dart';

Future<void> main() async {
  // Run everything in one zone to avoid "Zone mismatch" on web.
  runZonedGuarded(() async {
    // Binding + error hook inside the same zone.
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError =
        (details) => FlutterError.dumpErrorToConsole(details);

    // In debug on web, unregister stale service workers and caches.
    assert(() {
      if (kIsWeb) {
        // ignore: unawaited_futures
        killServiceWorkersInDebug();
      }
      return true;
    }());

    // Set a placeholder viewer profile until auth is wired.
    userSession.current.value = const UserProfile(
      npub: 'npub1guest',
      displayName: 'You',
      pictureUrl: null,
    );

    // Select primary data source before app builds.
    SourceSelector.bootstrap();

    runApp(VideoScope(adapter: RealVideoAdapter(), child: const App()));
  }, (Object error, StackTrace stack) {
    // Surface uncaught errors in the console for web debug.
    // ignore: avoid_print
    print('Uncaught zone error: $error\n$stack');
  });
}
