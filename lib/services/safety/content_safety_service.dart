import '../../data/models/post.dart';
import '../settings/settings_service.dart';

class ContentSafetyService {
  final SettingsService settings;
  ContentSafetyService(this.settings);

  bool isSensitive(Post p) {
    final manual = settings.sensitiveMarks().contains(p.id);
    if (manual) return true;
    final words = settings.sensitiveWords();
    if (words.isEmpty) return false;
    final text = '${p.caption} ${p.tags.join(" ")}'.toLowerCase();
    for (final w in words) {
      if (w.isEmpty) continue;
      if (text.contains('#$w') ||
          RegExp('(^|\\s)'+RegExp.escape(w)+'(\\s|$)').hasMatch(text)) {
        return true;
      }
    }
    return false;
  }
}

