import 'package:flutter/material.dart';
import '../../../data/models/post.dart';
import 'video_player_view.dart';

class VideoCard extends StatelessWidget {
  final Post post;
  const VideoCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return VideoPlayerView(url: post.url);
  }
}
