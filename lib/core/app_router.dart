import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../ui/pages/tag_feed_page.dart';
import '../ui/pages/profile_feed_page.dart';
import '../ui/pages/event_view_page.dart';
import '../ui/pages/notifications_page.dart';
import '../ui/pages/settings_page.dart';

class AppRouter {
  static final navKey = GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerate(RouteSettings s) {
    switch (s.name) {
      case AppRoutes.notifications:
        return MaterialPageRoute(
            builder: (_) => const NotificationsPage());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
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
