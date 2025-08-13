import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

Map<String, dynamic> buildLike(String eventId, int now) => {
  "kind": 7,
  "content": "+",
  "tags": [
    ["e", eventId],
  ],
  "created_at": now,
};

void main() {
  test('kind 7 like event shape', () {
    final now = 1;
    final evt = buildLike('evt_123', now);
    final jsonStr = jsonEncode(["EVENT", evt]);
    expect(jsonStr.contains('"kind":7'), true);
    expect(jsonStr.contains('"content":"+"'), true);
    expect(jsonStr.contains('["e","evt_123"]'), true);
    expect(jsonStr.contains('"created_at":1'), true);
  });
}
