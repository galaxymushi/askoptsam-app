import 'package:flutter_test/flutter_test.dart';

import 'package:asksam/models.dart';
import 'package:asksam/services/ai_service.dart';

void main() {
  test('chat session round-trips through JSON', () {
    final session = ChatSession(
      id: 's1',
      title: 'Hello',
      createdAt: DateTime(2026, 10, 31, 9),
      updatedAt: DateTime(2026, 10, 31, 9, 5),
      messages: [
        ChatMessage(
          id: 'm1',
          role: 'user',
          text: 'Hi',
          createdAt: DateTime(2026, 10, 31, 9),
        ),
      ],
    );

    final restored = ChatSession.fromMap(session.toMap());
    expect(restored.title, 'Hello');
    expect(restored.messages.single.text, 'Hi');
    expect(restored.messages.single.isUser, isTrue);
  });

  test('AI service points at the hosted AskOptSam backend', () {
    expect(AiService.instance.configured, isTrue);
  });
}
