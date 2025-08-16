import 'package:flutter/foundation.dart';

class HudModel {
  final String caption;
  final String fullCaption;
  final String likeCount;
  final String commentCount;
  final String repostCount;
  final String shareCount;
  final String zapCount;
  final String authorDisplay;
  final String authorNpub;
  const HudModel({
    required this.caption,
    required this.fullCaption,
    this.likeCount = '0',
    this.commentCount = '0',
    this.repostCount = '0',
    this.shareCount = '0',
    this.zapCount = '0',
    this.authorDisplay = 'anon',
    this.authorNpub = 'npub1xxxx',
  });

  HudModel copyWith({
    String? caption,
    String? fullCaption,
    String? likeCount,
    String? commentCount,
    String? repostCount,
    String? shareCount,
    String? zapCount,
    String? authorDisplay,
    String? authorNpub,
  }) => HudModel(
    caption: caption ?? this.caption,
    fullCaption: fullCaption ?? this.fullCaption,
    likeCount: likeCount ?? this.likeCount,
    commentCount: commentCount ?? this.commentCount,
    repostCount: repostCount ?? this.repostCount,
    shareCount: shareCount ?? this.shareCount,
    zapCount: zapCount ?? this.zapCount,
    authorDisplay: authorDisplay ?? this.authorDisplay,
    authorNpub: authorNpub ?? this.authorNpub,
  );
}

class HudState {
  final ValueNotifier<bool> visible;   // overlay opacity + hitTest
  final ValueNotifier<bool> muted;     // web mute button
  final ValueNotifier<HudModel> model; // caption + counts
  HudState({required this.visible, required this.muted, required this.model});
}
