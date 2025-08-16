abstract class UrlShim {
  Uri current();
  void replaceQuery(Map<String, String> params);
  String buildUrl(Map<String, String> params);
}

UrlShim get urlShim => _urlShim;

final UrlShim _urlShim = _StubUrlShim();

class _StubUrlShim implements UrlShim {
  @override
  Uri current() => Uri.base;

  @override
  void replaceQuery(Map<String, String> params) {
    // no-op off web
  }

  @override
  String buildUrl(Map<String, String> params) {
    final uri = current();
    final merged = Map<String, String>.from(uri.queryParameters)
      ..addAll(params);
    return uri.replace(queryParameters: merged).toString();
  }
}
