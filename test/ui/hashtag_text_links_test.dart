import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/widgets/hashtag_text.dart';

void main() {
  testWidgets('links hashtags', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: HashtagText('hello #aTag world'))));
    final rich = tester.widget<RichText>(find.byType(RichText));
    expect(rich.text.toPlainText(), contains('#aTag'));
  });
}
