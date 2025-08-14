import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:file_picker/file_picker.dart' as fp;
import 'package:dio/dio.dart';
import '../../core/di/locator.dart';
import '../../data/models/author.dart';
import '../../data/models/post.dart';
import '../../state/feed_controller.dart';
import '../../services/nostr/relay_service.dart';
import '../../services/upload/upload_service.dart';
import '../../services/upload/upload_models.dart';
import '../../crypto/nostr_event.dart';
import '../../services/keys/key_service.dart';

class CreateSheet extends StatefulWidget {
  const CreateSheet({super.key});
  @override
  State<CreateSheet> createState() => _CreateSheetState();
}

class _CreateSheetState extends State<CreateSheet> {
  final _caption = TextEditingController();
  double _progress = 0;
  bool _sending = false;
  File? _file;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      File? file;
      if (Platform.isAndroid || Platform.isIOS) {
        final picked = await ip.ImagePicker().pickVideo(source: ip.ImageSource.gallery);
        if (picked != null) file = File(picked.path);
      } else {
        final res = await fp.FilePicker.platform.pickFiles(type: fp.FileType.video, withData: false);
        if (res != null && res.files.single.path != null) {
          file = File(res.files.single.path!);
        }
      }
      if (!mounted) return;
      setState(() => _file = file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pick failed: $e')));
    }
  }

  Future<void> _uploadAndPublish() async {
    final file = _file;
    if (file == null || _sending) return;
    setState(() {
      _sending = true;
      _progress = 0;
    });
    try {
      final uploader = Locator.I.tryGet<UploadService>() ?? Nip96UploadService(Dio());
      final up = await uploader.uploadFile(
        file,
        onProgress: (s, t) {
          if (mounted && t > 0) setState(() => _progress = s / t);
        },
      );

      final relay = Locator.I.get<RelayService>();
      final keySvc = Locator.I.get<KeyService>();
      final pub = await keySvc.getPubkey();
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final tags = <List<String>>[
        ['t', up.mime],
        ['url', up.url],
        if (up.thumb.isNotEmpty) ['thumb', up.thumb],
        if (up.width > 0 && up.height > 0) ['dim', '${up.width}x${up.height}'],
        if (up.duration > 0) ['dur', up.duration.toStringAsFixed(1)],
      ];
      final e = NostrEvent(kind: 1, createdAt: now, content: _caption.text.trim(), tags: tags);
      final signed = NostrEvent.sign((await keySvc.getPrivkey())!, pub!, e);

      await relay.publishEvent(signed);

      final you = Author(pubkey: pub, name: pub.substring(0, 8), avatarUrl: '');
      final optimistic = Post(
        id: signed['id'] as String,
        author: you,
        caption: _caption.text.trim(),
        tags: const [],
        url: up.url,
        thumb: up.thumb,
        mime: up.mime,
        width: up.width,
        height: up.height,
        duration: up.duration,
        likeCount: 0,
        commentCount: 0,
        repostCount: 0,
        createdAt: DateTime.now(),
      );
      Locator.I.get<FeedController>().insertOptimistic(optimistic);

      if (!mounted) return;
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Published')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = _file;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 36,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caption,
                    decoration: const InputDecoration(hintText: 'Add a caption (optional)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _sending ? null : _pick,
                  icon: const Icon(Icons.video_library),
                  label: const Text('Choose video'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: (file == null || _sending) ? null : _uploadAndPublish,
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Upload'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_sending)
              LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                minHeight: 3,
              ),
            if (file != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  file.path.split('/').last,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
