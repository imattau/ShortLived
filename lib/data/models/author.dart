class Author {
  final String pubkey;
  final String name;
  final String avatarUrl;
  final bool following;
  const Author({
    required this.pubkey,
    required this.name,
    required this.avatarUrl,
    this.following = false,
  });
}
