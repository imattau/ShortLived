abstract class ShareShim {
  bool get isSupported;
  Future<bool> share({required String url, String? text, String? title});
}

ShareShim get shareShim => _shareShim;

final ShareShim _shareShim = _StubShareShim();

class _StubShareShim implements ShareShim {
  @override
  bool get isSupported => false;

  @override
  Future<bool> share({required String url, String? text, String? title}) async {
    // Not supported on this platform; caller should fallback to clipboard.
    return false;
  }
}
