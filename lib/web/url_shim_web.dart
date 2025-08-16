import 'dart:html' as html;
import 'url_shim.dart';

final UrlShim _urlShim = _WebUrlShim();

class _WebUrlShim implements UrlShim {
  @override
  Uri current() => Uri.parse(html.window.location.href);

  @override
  void replaceQuery(Map<String, String> params) {
    final uri = current();
    final merged = Map<String, String>.from(uri.queryParameters)
      ..addAll(params);
    final next = uri.replace(queryParameters: merged).toString();
    html.window.history.replaceState(null, html.document.title, next);
  }

  @override
  String buildUrl(Map<String, String> params) {
    final uri = current();
    final merged = Map<String, String>.from(uri.queryParameters)
      ..addAll(params);
    return uri.replace(queryParameters: merged).toString();
  }
}
