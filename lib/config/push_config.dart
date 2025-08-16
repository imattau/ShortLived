import 'package:flutter/foundation.dart';

/// Inject your own values at build time or edit here.
class PushConfig {
  /// Base64URL VAPID public key (no padding). Example-only placeholder.
  static const String vapidPublicKey = String.fromEnvironment(
    'VAPID_PUBLIC',
    defaultValue: 'BOPo8e1v...your_public_key_here...'
  );

  /// HTTPS endpoint that accepts a JSON WebPush subscription (see tools/webpush-server).
  static const String subscriptionEndpoint = String.fromEnvironment(
    'PUSH_SUBSCRIBE_URL',
    defaultValue: 'https://your.push.endpoint.example/subscribe'
  );

  static bool get isWeb => kIsWeb;
}
