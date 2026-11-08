import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:asksam/eye/services/gemini_voice.dart';
import 'package:asksam/models.dart';
import 'package:asksam/services/ai_service.dart';
import 'package:asksam/services/auth_service.dart';

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

  test('GeminiVoice.splitSentences isolates first sentence for low latency', () {
    const paragraph =
        'Mbele yako kuna chumba chenye kompyuta na kiti. '
        'Kwenye meza kuna kikombe cha kahawa na kitabu. '
        'Dirisha liko upande wa kushoto likipitisha mwanga.';
    final chunks = GeminiVoice.splitSentences(paragraph);
    expect(chunks.length, greaterThanOrEqualTo(2));
    expect(chunks.first, 'Mbele yako kuna chumba chenye kompyuta na kiti.');
  });

  test('LocalAuthService supports signUp, resetLocalPassword, and changePassword', () async {
    SharedPreferences.setMockInitialValues({});
    final auth = LocalAuthService();
    final user = await auth.signUp('Samwel', 'sam@example.com', 'password123');
    expect(user.email, 'sam@example.com');

    await auth.changePassword('password123', 'newpass456');
    await auth.signOut();

    final signedIn = await auth.signIn('sam@example.com', 'newpass456');
    expect(signedIn.name, 'Samwel');

    await auth.resetLocalPassword('sam@example.com', 'resetpass789');
    final afterReset = await auth.signIn('sam@example.com', 'resetpass789');
    expect(afterReset.email, 'sam@example.com');
  });
}
