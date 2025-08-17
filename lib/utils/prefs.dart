import 'package:shared_preferences/shared_preferences.dart';

class VideoPrefs {
  static const _kMuted = 'video.muted';
  static Future<bool> getMuted() async =>
      (await SharedPreferences.getInstance()).getBool(_kMuted) ?? true;
  static Future<void> setMuted(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_kMuted, v);
}
