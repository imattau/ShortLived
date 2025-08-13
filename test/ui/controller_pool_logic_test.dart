import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/video_controller_pool.dart';

class FakeCtl { bool disposed = false; }
void main() {
  test('pool keeps only desired indices', () async {
    final pool = ControllerPool<FakeCtl>(
      ctor: (url) async => FakeCtl(),
      dispose: (c) async => c.disposed = true,
    );

    final map = {0:'a',1:'b',2:'c',3:'d'};
    await pool.ensureFor(indexToUrl: map, keep: {1,2});
    expect(pool.size, 2);
    await pool.ensureFor(indexToUrl: map, keep: {2,3});
    expect(pool.size, 2);
  });
}
