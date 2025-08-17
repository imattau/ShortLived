import 'share_interface.dart';

class _StubShareShim implements ShareShim {
  @override
  bool get isSupported => false;

  @override
  Future<bool> share(
          {required String url, String? text, String? title}) async =>
      false;
}

final ShareShim shareShim = _StubShareShim();
