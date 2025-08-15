import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/app_router.dart';

class HashtagText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const HashtagText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final re = RegExp(r'(#[a-zA-Z0-9_]{1,40})');
    int idx = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > idx) {
        spans.add(TextSpan(text: text.substring(idx, m.start)));
      }
      final tag = m.group(1)!;
      spans.add(TextSpan(
        text: tag,
        style: style?.copyWith(color: Colors.blueAccent) ??
            const TextStyle(color: Colors.blueAccent),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            Navigator.of(AppRouter.navKey.currentContext!)
                .pushNamed('/tag', arguments: tag.substring(1).toLowerCase());
          },
      ));
      idx = m.end;
    }
    if (idx < text.length) {
      spans.add(TextSpan(text: text.substring(idx)));
    }
    return RichText(
        text: TextSpan(
            style: style ?? const TextStyle(color: Colors.white),
            children: spans));
  }
}
