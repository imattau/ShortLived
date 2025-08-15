import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/moderation/mute_models.dart';

void main() {
  test('isPostMuted checks users/tags/words/events', () {
    final m = MuteServiceHarness(MuteList(
      users: {'u1'},
      events: {'e1'},
      tags: {'nsfw'},
      words: {'spoiler'},
    ));
    expect(m.isPostMuted(author: 'u1', eventId: 'x', caption: ''), true);
    expect(m.isPostMuted(author: 'u2', eventId: 'e1', caption: ''), true);
    expect(m.isPostMuted(author: 'u2', eventId: 'x', caption: 'nice #nsfw clip'), true);
    expect(m.isPostMuted(author: 'u2', eventId: 'x', caption: 'no spoilers here'), true);
  });
}

class MuteServiceHarness {
  final MuteList _list;
  MuteServiceHarness(this._list);
  bool isPostMuted({required String author, required String eventId, required String caption}) {
    final low = caption.toLowerCase();
    if (_list.users.contains(author) || _list.events.contains(eventId)) {
      return true;
    }
    for (final t in _list.tags) {
      if (low.contains('#$t')) return true;
    }
    for (final w in _list.words) {
      if (RegExp(r'(^|\s)' + RegExp.escape(w) + r'(\s|$)').hasMatch(low)) {
        return true;
      }
    }
    return false;
  }
}
