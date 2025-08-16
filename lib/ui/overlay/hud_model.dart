import 'package:flutter/foundation.dart';

class HudModel {
  final String caption;
  final String likeCount;
  final String commentCount;
  final String repostCount;
  final String shareCount;
  final String zapCount;
  const HudModel({
    required this.caption,
    this.likeCount = '0',
    this.commentCount = '0',
    this.repostCount = '0',
    this.shareCount = '0',
    this.zapCount = '0',
  });

  HudModel copyWith({
    String? caption,
    String? likeCount,
    String? commentCount,
    String? repostCount,
    String? shareCount,
    String? zapCount,
  }) => HudModel(
    caption: caption ?? this.caption,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount ?? this.commentCount,
    repostCount: repostCount ?? this.repostCount,
    shareCount: shareCount ?? this.shareCount,
    zapCount: zapCount ?? this.zapCount,
  );
}

class HudState {
  final ValueNotifier<bool> visible;   // overlay opacity + hitTest
  final ValueNotifier<bool> muted;     // web mute button
  final ValueNotifier<HudModel> model; // caption + counts
  HudState({required this.visible, required this.muted, required this.model});
}
