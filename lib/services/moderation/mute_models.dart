class MuteList {
  final Set<String> users;   // hex pubkeys
  final Set<String> events;  // event ids (hex)
  final Set<String> tags;    // hashtag names (lowercase, no #)
  final Set<String> words;   // plain words (lowercase)
  const MuteList({this.users = const {}, this.events = const {}, this.tags = const {}, this.words = const {}});
  MuteList copyWith({Set<String>? users, Set<String>? events, Set<String>? tags, Set<String>? words}) =>
      MuteList(users: users ?? this.users, events: events ?? this.events, tags: tags ?? this.tags, words: words ?? this.words);
}
