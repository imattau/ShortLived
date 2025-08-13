import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../services/upload/upload_service.dart';
import '../../services/upload/upload_service_nip96.dart';
import '../../data/models/post.dart';
import '../../data/models/author.dart';
import '../../data/models/file_meta.dart';

typedef OnPostCreated = void Function(Post post);

class CreateSheet extends StatefulWidget {
  const CreateSheet({super.key, required this.onCreated});
  final OnPostCreated onCreated;

  @override
  State<CreateSheet> createState() => _CreateSheetState();
}

class _CreateSheetState extends State<CreateSheet> {
  String? path;
  bool uploading = false;
  String caption = '';

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.video);
    if (res != null && res.files.single.path != null) {
      setState(() => path = res.files.single.path);
    }
  }

  Future<void> _upload() async {
    if (path == null) return;
    setState(() => uploading = true);
    try {
      final UploadService up = UploadServiceNip96(Dio());
      final meta = await up.uploadVideo(path!);
      _onUploaded(meta);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  void _onUploaded(FileMeta m) {
    final post = Post(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      author: const Author(pubkey: 'me', name: 'You', avatarUrl: ''),
      caption: caption.trim().isEmpty ? 'New post' : caption.trim(),
      tags: const [],
      url: m.url,
      thumb: m.thumb,
      mime: m.mime,
      width: m.width,
      height: m.height,
      duration: m.duration,
      createdAt: DateTime.now(),
    );
    widget.onCreated(post);
    Navigator.of(context).pop(); // close the sheet
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, width: 36, margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            TextField(
              decoration: const InputDecoration(hintText: 'Caption (optional)'),
              onChanged: (v) => caption = v,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text(path ?? 'No video selected')),
                TextButton(onPressed: uploading ? null : _pick, child: const Text('Pick video')),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (path != null && !uploading) ? _upload : null,
                child: uploading ? const CircularProgressIndicator() : const Text('Upload and publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
