import 'package:flutter_test/flutter_test.dart';

import 'package:aqd_ionbit/features/ai/data/datasources/ai_mock_data_source.dart';

void main() {
  late AiMockDataSource dataSource;

  setUp(() => dataSource = AiMockDataSource());

  test('getConversations returns the seeded conversation', () async {
    final conversations = await dataSource.getConversations();
    expect(conversations.length, 1);
  });

  test('sendMessage with no conversationId starts a new conversation with a reply', () async {
    final conversation = await dataSource.sendMessage(text: 'سؤال قانوني');

    expect(conversation.messages.length, 2);
    expect(conversation.messages.first.isFromUser, isTrue);
    expect(conversation.messages.last.isFromUser, isFalse);
  });

  test('sendMessage with a conversationId appends to that conversation', () async {
    final first = await dataSource.sendMessage(text: 'سؤال أول');
    final second = await dataSource.sendMessage(text: 'سؤال ثانٍ', conversationId: first.id);

    expect(second.id, first.id);
    expect(second.messages.length, 4);
  });

  test('clearConversation empties the messages but keeps the conversation', () async {
    final conversation = await dataSource.sendMessage(text: 'سؤال');
    await dataSource.clearConversation(conversation.id);
    final reloaded = await dataSource.getConversationById(conversation.id);

    expect(reloaded.messages, isEmpty);
  });

  test('analyzeDocument returns a risk-scored analysis with clauses', () async {
    final analysis = await dataSource.analyzeDocument(documentTitle: 'عقد إيجار');

    expect(analysis.documentTitle, 'عقد إيجار');
    expect(analysis.clauses, isNotEmpty);
    final analyses = await dataSource.getAnalyses();
    expect(analyses.first.id, analysis.id);
  });
}
