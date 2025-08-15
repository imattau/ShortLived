import 'package:flutter/material.dart';

typedef DeepLinkHandler = Future<void> Function(Uri uri);

class DeepLinkService {
  final GlobalKey<NavigatorState> navKey;
  DeepLinkService(this.navKey);

  Future<bool> handle(String link) async {
    Uri? uri;
    try {
      uri = Uri.parse(link);
    } catch (_) {
      return false;
    }
    if (uri.scheme == 'nostr') {
      // nostr:<nevent|nprofile|npub|note|...>
      final s = uri.path.isNotEmpty ? uri.path : uri.host;
      if (s.startsWith('nprofile1')) {
        return _openProfile(s);
      }
      if (s.startsWith('nevent1') || s.startsWith('note1')) {
        return _openEvent(s);
      }
      if (s.startsWith('npub1')) {
        return _openProfile(s);
      }
    }
    // Hash route on web: /t/<tag>
    if (uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == 't' &&
        uri.pathSegments.length >= 2) {
      final tag = uri.pathSegments[1];
      return _openTag(tag);
    }
    return false;
  }

  Future<bool> _openProfile(String nprofileOrNpub) async {
    final ctx = navKey.currentContext;
    if (ctx == null) return false;
    return Navigator.of(ctx)
        .pushNamed('/profile', arguments: nprofileOrNpub)
        .then((_) => true);
  }

  Future<bool> _openEvent(String neventOrNote) async {
    final ctx = navKey.currentContext;
    if (ctx == null) return false;
    return Navigator.of(ctx)
        .pushNamed('/event', arguments: neventOrNote)
        .then((_) => true);
  }

  Future<bool> _openTag(String tag) async {
    final ctx = navKey.currentContext;
    if (ctx == null) return false;
    return Navigator.of(ctx)
        .pushNamed('/tag', arguments: tag)
        .then((_) => true);
  }
}
