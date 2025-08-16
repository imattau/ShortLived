import 'dart:async';
import 'package:nostr_video/core/testing/test_switches.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestSwitches.disableVideo = true;
  TestSwitches.disableRelays = true;
  await testMain();
}
