import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import 'package:nostr_video/ui/home/widgets/overlay_cluster.dart';
import '../test_helpers/test_video_scope.dart';

void main() {
  testWidgets(
      'ultra-compact action bar stays < 320px high on 768px tall view',
      (t) async {
    await t.binding.setSurfaceSize(const Size(1024, 768));
    await mockNetworkImagesFor(() async {
      await t.pumpWidget(
          const TestVideoApp(child: MaterialApp(home: HomePage())));
      await t.pumpAndSettle();
    });

    // Locate the action cluster directly and confirm it stays compact.
    final cluster = find.byType(OverlayCluster);
    expect(cluster, findsOneWidget);
    expect(t.getSize(cluster).height, lessThan(320));
  });
}
