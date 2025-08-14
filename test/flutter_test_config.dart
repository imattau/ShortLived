import 'dart:async';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'test_utils/fake_video_player_platform.dart';
import 'package:nostr_video/core/testing/test_switches.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestSwitches.disableVideo = true;
  TestSwitches.disableRelays = true;
  VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  await testMain();
}
