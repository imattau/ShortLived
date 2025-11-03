import '../../services/cache/cache_service.dart';
import '../../data/models/post.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/keys/signer.dart';
import '../../services/keys/local_signer.dart';
import '../../services/keys/nip07_signer.dart';
import '../../services/keys/key_service.dart';
import '../../services/settings/settings_service.dart';

class Locator {
  Locator._() {
    final cache = _MemoryCacheService();
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

class _MemoryCacheService implements CacheService {
  List<Post> _posts = [];

  @override
  Future<void> cacheThumb(String postId, String url) async {}

  @override
  Future<void> init() async {}

  @override
  Future<List<Post>> loadCachedPosts() async => List<Post>.from(_posts);

  @override
  Future<void> savePosts(List<Post> posts) async {
    _posts = List<Post>.from(posts);
  }
}

// During app start, remember to register the UploadService if absent:
// if (Locator.I.tryGet<UploadService>() == null) {
//   Locator.I.put<UploadService>(Nip96UploadService(Dio()));
// }

