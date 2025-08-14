import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/crypto/nip19.dart';

void main() {
  test('encode note from id hex', () {
    const id = '00' '11' '22' '33' '44' '55' '66' '77' '88' '99' 'aa' 'bb' 'cc' 'dd' 'ee' 'ff'
               '00' '11' '22' '33' '44' '55' '66' '77' '88' '99' 'aa' 'bb' 'cc' 'dd' 'ee' 'ff';
    final note = Nip19.encodeNote(id);
    expect(note.startsWith('note1'), true);
  });
}
