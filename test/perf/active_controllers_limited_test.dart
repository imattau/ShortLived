import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import '../test_helpers/test_video_scope.dart';

void main() {
  testWidgets('keeps at most 3 active pages', (tester) async {
    await tester.pumpWidget(const TestVideoApp(child: MaterialApp(home: HomePage())));
    await tester.pumpAndSettle();

    Future<int> activePages() async {
      return find
          .byWidgetPredicate((w) =>
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith('feed_'))
          .evaluate()
          .length;
    }

    expect(await activePages() <= 3, true);
    await tester.fling(find.byKey(const Key('feed-pageview')), const Offset(0, -400), 1000);
    await tester.pumpAndSettle();
    expect(await activePages() <= 3, true);
  });
}
