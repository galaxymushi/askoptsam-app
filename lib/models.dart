import 'content/citations.dart';

class AppUser {
  const AppUser({required this.uid, required this.email, required this.name});

  final String uid;
  final String email;
  final String name;

  AppUser copyWith({String? name}) =>
      AppUser(uid: uid, email: email, name: name ?? this.name);
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.status = MessageStatus.sent,
    this.feedback,
  });

  final String id;
  final String role; // 'user' | 'assistant'
  String text;
  final DateTime createdAt;
  MessageStatus status;

  /// 'up', 'down' or null. Saved with the chat so a rating survives restarts.
  String? feedback;

  bool get isUser => role == 'user';

  Map<String, dynamic> toMap() => {
    'id': id,
    'role': role,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    if (feedback != null) 'feedback': feedback,
  };

  static ChatMessage fromMap(Map<String, dynamic> map) => ChatMessage(
    id: map['id'] as String,
    role: map['role'] as String,
    // Chats saved before source markers were filtered keep them in storage;
    // clean them here so old conversations read cleanly too.
    text: stripCitations(map['text'] as String? ?? ''),
    createdAt:
        DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    feedback: map['feedback'] as String?,
  );
}

enum MessageStatus { sent, sending, failed }

class ChatSession {
  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<ChatMessage> messages;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'messages': messages.map((m) => m.toMap()).toList(),
  };

  static ChatSession fromMap(Map<String, dynamic> map) => ChatSession(
    id: map['id'] as String,
    title: map['title'] as String? ?? '',
    createdAt:
        DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    messages: ((map['messages'] as List?) ?? const [])
        .map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m as Map)))
        .toList(),
  );
}
