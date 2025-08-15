import 'package:flutter/material.dart';
import '../ui/pages/tag_feed_page.dart';
import '../ui/pages/profile_feed_page.dart';
import '../ui/pages/event_view_page.dart';

class AppRouter {
  static final navKey = GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerate(RouteSettings s) {
    switch (s.name) {
      case '/tag':
        return MaterialPageRoute(
            builder: (_) => TagFeedPage(tag: s.arguments as String));
      case '/profile':
        return MaterialPageRoute(
            builder: (_) =>
                ProfileFeedPage(handle: s.arguments as String));
      case '/event':
        return MaterialPageRoute(
            builder: (_) => EventViewPage(encoded: s.arguments as String));
      default:
        return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
    }
  }
}
