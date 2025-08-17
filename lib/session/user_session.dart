import 'package:flutter/foundation.dart';

class UserProfile {
  final String npub;
  final String? displayName;
  final String? pictureUrl;
  const UserProfile({required this.npub, this.displayName, this.pictureUrl});
}

/// Very simple global until auth is wired.
class UserSession {
  final current = ValueNotifier<UserProfile?>(null);
}

final userSession = UserSession();
