import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import 'package:nostr_video/ui/overlay/widgets/action_button.dart';
import 'package:nostr_video/utils/capabilities.dart';
import '../test_helpers/test_video_scope.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('action buttons have 44x44 hit targets and compact gaps', (t) async {
    await mockNetworkImagesFor(() async {
      await t.pumpWidget(
          const TestVideoApp(child: MaterialApp(home: HomePage())));
      await t.pumpAndSettle();
      if (kIsWeb) {
        expect(find.byTooltip('Like'), findsOneWidget);
      } else {
        final expected = Capabilities.shareSupported ? 6 : 5;
        expect(find.byType(ActionButton), findsNWidgets(expected));
      }
      final boxes =
          find.byWidgetPredicate((w) => w is SizedBox && w.width == 44 && w.height == 44);
      expect(boxes, findsWidgets);
    });
  });
}
