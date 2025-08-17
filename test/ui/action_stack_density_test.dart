import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import 'package:nostr_video/ui/home/widgets/overlay_cluster.dart';

void main() {
  testWidgets('action stack compacts on short viewports', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 520)); // short
    await t.pumpWidget(const MaterialApp(home: HomePage()));
    await t.pumpAndSettle();

    // Ensure the six actions exist
    expect(find.byTooltip('Like'), findsOneWidget);
    expect(find.byTooltip('Zap'), findsOneWidget);

    final clusterBox =
        find.byType(OverlayCluster).evaluate().first.renderObject as RenderBox;
    final viewportHeight =
        RendererBinding.instance.renderViews.first.size.height;
    expect(clusterBox.size.height, lessThan(viewportHeight * 0.75));
    expect(viewportHeight, 520);
  });
}
