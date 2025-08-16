import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nostr_video/ui/home/widgets/overlay_cluster.dart';

void main() {
  testWidgets('OverlayCluster lays out with finite constraints', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomRight,
            child: OverlayCluster(
              onLike: _noop,
              onComment: _noop,
              onRepost: _noop,
              onShare: _noop,
              onCopyLink: _noop,
              onZap: _noop,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(OverlayCluster), findsOneWidget);
  });
}

void _noop() {}
