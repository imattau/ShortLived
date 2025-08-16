import 'package:flutter/material.dart';

class FeedController extends ChangeNotifier {
  final ValueNotifier<int> index = ValueNotifier<int>(0);
  final ValueNotifier<bool> muted = ValueNotifier<bool>(true);

  PageController? _pager;

  void attach(PageController pager) => _pager = pager;

  void next() => _pager?.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  void prev() => _pager?.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

  void toggleMute() => muted.value = !muted.value;

  @override
  void dispose() {
    index.dispose();
    muted.dispose();
    super.dispose();
  }
}
