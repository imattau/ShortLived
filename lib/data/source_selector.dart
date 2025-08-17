import 'dart:developer' as dev;

import '../core/config/app_config.dart';
import '../feed/data_source.dart';

class SourceSelector {
  static FeedDataSource? _instance;

  static FeedDataSource get instance => _instance ??= _create();

  static void bootstrap() {
    _instance = _create();
  }

  static FeedDataSource _create() {
    if (AppConfig.nostrEnabled) {
      dev.log('[ShortLived] Data source: NOSTR', name: 'ShortLived');
      return NostrFeedDataSource();
    }
    dev.log('[ShortLived] Data source: DEMO', name: 'ShortLived');
    return DemoFeedDataSource();
  }
}
