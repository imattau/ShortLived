import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/overlay/widgets/bottom_info_bar.dart';
import 'package:nostr_video/ui/overlay/hud_model.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('caption clamps to 3 lines and shows More when cleaned differs', (t) async {
    final long = '${'nostr:npub1'.padRight(200, 'x')} https://a.dev/v.mp4 ${List.filled(50, 'word').join(' ')}';
    final m = HudModel(
      caption: 'short',
      fullCaption: long,
      likeCount: '0',
      commentCount: '0',
      repostCount: '0',
      shareCount: '0',
      zapCount: '0',
      authorDisplay: 'Tester',
      authorNpub: 'npub1abcd…wxyz',
    );
    await t.pumpWidget(MaterialApp(home: Scaffold(body: BottomInfoBar(model: m))));
    expect(find.text('More'), findsOneWidget);
  });
}
