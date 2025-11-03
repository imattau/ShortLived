import '../../services/cache/cache_service.dart';
import '../../services/cache/cache_service_hive.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/keys/signer.dart';
import '../../services/keys/local_signer.dart';
import '../../services/keys/nip07_signer.dart';
import '../../services/keys/key_service.dart';
import '../../services/settings/settings_service.dart';

class Locator {
  Locator._() {
    final cache = CacheServiceHive();
    cache.init();
    put<CacheService>(cache);
  }
  static final Locator I = Locator._();

  final Map<Type, dynamic> _store = {};

  void put<T>(T value) => _store[T] = value;
  T get<T>() => _store[T] as T;
  T? tryGet<T>() => _store[T] as T?;
  bool contains<T>() => _store.containsKey(T);
  void remove<T>() => _store.remove(T);
}

extension SignerRegistration on Locator {
  void ensureSigner() {
    final settings = get<SettingsService>();
    final pref = settings.signerPref();
    if (pref == 'nip07' && kIsWeb) {
      final nip = Nip07Signer();
      if (nip.available) {
        put<Signer>(nip);
        return;
      }
    }
    put<Signer>(LocalSigner(get<KeyService>()));
  }
}

// During app start, remember to register the UploadService if absent:
// if (Locator.I.tryGet<UploadService>() == null) {
//   Locator.I.put<UploadService>(Nip96UploadService(Dio()));
// }

