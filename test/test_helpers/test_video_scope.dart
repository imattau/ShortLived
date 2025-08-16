import 'package:flutter/widgets.dart';
import 'package:nostr_video/video/video_adapter.dart';
import 'package:nostr_video/video/video_adapter_fake.dart';

class TestVideoApp extends StatelessWidget {
  final Widget child;
  const TestVideoApp({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return VideoScope(adapter: FakeVideoAdapter(), child: child);
  }
}
