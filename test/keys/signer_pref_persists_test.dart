import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePrefs implements SharedPreferences {
  final Map<String, Object> _store = {};
  @override
  String? getString(String key) => _store[key] as String?;
  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('signer pref persists', () async {
    final s = SettingsService(FakePrefs());
    expect(s.signerPref(), 'local');
    await s.setSignerPref('nip07');
    expect(s.signerPref(), 'nip07');
  });
}
