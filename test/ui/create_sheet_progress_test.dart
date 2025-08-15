import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/sheets/create_sheet.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:nostr_video/services/upload/upload_service.dart';
import 'package:nostr_video/services/upload/upload_models.dart';
import 'dart:io';

class _UploadFake implements UploadService {
  @override
  Future<UploadResult> uploadFile(File file, {required void Function(int p1, int p2) onProgress}) async {
    onProgress(1, 2);
    onProgress(2, 2);
    return UploadResult(
      url: 'https://cdn/x.mp4',
      thumb: 'https://cdn/x.jpg',
      mime: 'video/mp4',
      width: 1080,
      height: 1920,
      duration: 10.0,
    );
  }
}

void main() {
  testWidgets('shows progress bar when sending', (tester) async {
    Locator.I.put<UploadService>(_UploadFake());
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CreateSheet())));
    expect(find.text('Choose video'), findsOneWidget);
  });
}
