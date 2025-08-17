import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/feed_controller.dart';
import 'package:nostr_video/ui/overlay/hud_model.dart';
import 'package:nostr_video/ui/overlay/hud_overlay.dart';

void main() {
  testWidgets('H key toggles HUD visibility', (t) async {
    final controller = FeedController();
    final state = HudState(
      visible: ValueNotifier<bool>(true),
      muted: ValueNotifier<bool>(false),
      model: ValueNotifier<HudModel>(
        const HudModel(caption: 'c', fullCaption: 'c'),
      ),
    );

    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HudOverlay(
            state: state,
            controller: controller,
            onLikeLogical: () {},
          ),
        ),
      ),
    );
    await t.pumpAndSettle();

    expect(state.visible.value, isTrue);
    await t.sendKeyDownEvent(LogicalKeyboardKey.keyH);
    await t.sendKeyUpEvent(LogicalKeyboardKey.keyH);
    await t.pumpAndSettle();
    expect(state.visible.value, isFalse);
    await t.sendKeyDownEvent(LogicalKeyboardKey.keyH);
    await t.sendKeyUpEvent(LogicalKeyboardKey.keyH);
    await t.pumpAndSettle();
    expect(state.visible.value, isTrue);
  });
}
