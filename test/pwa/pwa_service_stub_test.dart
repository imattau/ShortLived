import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/web/pwa/pwa_service.dart';

void main() {
  test('stub returns false and notifies false', () async {
    final s = PwaServiceStub();
    expect(s.installAvailable.value, false);
    final ok = await s.promptInstall();
    expect(ok, false);
  });
}
