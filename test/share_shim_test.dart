import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/platform/share/share.dart';
import 'package:nostr_video/platform/share/share_interface.dart';

void main() {
  test('shareShim is defined and implements interface', () {
    expect(shareShim, isA<ShareShim>());
    // isSupported should be a bool, not throw
    expect(() => shareShim.isSupported, returnsNormally);
  });
}
