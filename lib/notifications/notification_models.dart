import 'package:equatable/equatable.dart';

/// Supported notification categories.
enum NotificationType { reply, like, repost, zap, mention }

/// Representation of a notification within the app.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.fromPubkey,
    this.fromName,
    this.noteId,
    this.content,
    required this.createdAt,
    this.read = false,
  });

  final String id;
  final NotificationType type;
  final String fromPubkey;
  final String? fromName;
  final String? noteId;
  final String? content;
  final DateTime createdAt;
  final bool read;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      type: type,
      fromPubkey: fromPubkey,
      fromName: fromName,
      noteId: noteId,
      content: content,
      createdAt: createdAt,
      read: read ?? this.read,
    );
  }

  @override
  List<Object?> get props => [id, type, fromPubkey, fromName, noteId, content, createdAt, read];
}
