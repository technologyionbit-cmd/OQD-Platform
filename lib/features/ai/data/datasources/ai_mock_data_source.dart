import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/ai/data/datasources/ai_remote_data_source.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/ai_conversation.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/ai_message.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/analysis_clause.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/analysis_risk_level.dart';
import 'package:aqd_ionbit/features/ai/domain/entities/contract_analysis.dart';

/// Temporary, isolated stand-in for a real LLM provider — see this
/// feature's `RoutePaths`/scope-rule note: NOT a real AI integration.
/// Replies are picked from a small canned set (loosely keyword-matched so
/// the conversation still feels responsive) and analysis results are a
/// fixed template of clauses. Swapping in a real provider later only ever
/// touches this file.
class AiMockDataSource implements AiRemoteDataSource {
  final List<AiConversation> _conversations = [
    AiConversation(
      id: 'ai_conv_seed_1',
      title: 'استفسار عن فسخ عقد الإيجار',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      messages: [
        AiMessage(
          id: 'm1',
          text: 'ما هي حقوقي إذا أراد المالك إنهاء عقد الإيجار قبل موعده؟',
          isFromUser: true,
          sentAt: DateTime.now().subtract(const Duration(days: 2, minutes: 5)),
        ),
        AiMessage(
          id: 'm2',
          text:
              'بشكل عام، لا يجوز للمؤجر إنهاء العقد قبل انتهاء مدته إلا لأسباب محددة في العقد أو النظام، مثل الإخلال بالشروط أو عدم السداد. '
              'أنصحك بمراجعة بند "إنهاء العقد" في عقدك، ويمكنني تحليله لك إذا رغبت. تذكّر أن هذا شرح عام وليس استشارة قانونية ملزمة.',
          isFromUser: false,
          sentAt: DateTime.now().subtract(const Duration(days: 2, minutes: 4)),
        ),
      ],
    ),
  ];

  final List<ContractAnalysis> _analyses = [];

  @override
  Future<List<AiConversation>> getConversations() async {
    await _simulateLatency();
    final sorted = List<AiConversation>.of(_conversations)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  @override
  Future<AiConversation> getConversationById(String id) async {
    await _simulateLatency();
    return _conversations.firstWhere((c) => c.id == id, orElse: () => throw const NotFoundFailure());
  }

  @override
  Future<AiConversation> sendMessage({required String text, String? conversationId}) async {
    await _simulateLatency(ms: 900);
    final now = DateTime.now();
    final userMessage = AiMessage(id: 'm_${now.microsecondsSinceEpoch}', text: text, isFromUser: true, sentAt: now);
    final reply = AiMessage(
      id: 'm_${now.microsecondsSinceEpoch + 1}',
      text: _generateReply(text),
      isFromUser: false,
      sentAt: now.add(const Duration(seconds: 1)),
    );

    if (conversationId == null) {
      final conversation = AiConversation(
        id: 'ai_conv_${now.microsecondsSinceEpoch}',
        title: text.length > 40 ? '${text.substring(0, 40)}...' : text,
        createdAt: now,
        updatedAt: now,
        messages: [userMessage, reply],
      );
      _conversations.insert(0, conversation);
      return conversation;
    }

    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index == -1) throw const NotFoundFailure();
    final updated = _conversations[index].copyWith(updatedAt: now, messages: [..._conversations[index].messages, userMessage, reply]);
    _conversations[index] = updated;
    return updated;
  }

  @override
  Future<void> clearConversation(String id) async {
    await _simulateLatency();
    final index = _conversations.indexWhere((c) => c.id == id);
    if (index == -1) throw const NotFoundFailure();
    _conversations[index] = _conversations[index].copyWith(messages: const []);
  }

  @override
  Future<List<ContractAnalysis>> getAnalyses() async {
    await _simulateLatency();
    final sorted = List<ContractAnalysis>.of(_analyses)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<ContractAnalysis> getAnalysisById(String id) async {
    await _simulateLatency();
    return _analyses.firstWhere((a) => a.id == id, orElse: () => throw const NotFoundFailure());
  }

  @override
  Future<ContractAnalysis> analyzeDocument({required String documentTitle, String? sourceDocumentId}) async {
    // A real analysis pass takes noticeably longer than a chat reply —
    // the "Analyzing..." state on the caller's screen should read as real
    // work happening, not an accidental extra spinner frame.
    await _simulateLatency(ms: 2200);
    final now = DateTime.now();
    final clauses = [
      const AnalysisClause(
        id: 'clause_1',
        title: 'بند إنهاء العقد',
        content: 'يحق لأي من الطرفين إنهاء هذا العقد بإشعار مسبق مدته 30 يومًا دون الحاجة لإبداء الأسباب.',
        riskLevel: AnalysisRiskLevel.high,
        recommendation: 'يُنصح بتحديد أسباب واضحة للإنهاء المبكر وتعويض مناسب لحماية الطرف الآخر من إنهاء تعسفي.',
      ),
      const AnalysisClause(
        id: 'clause_2',
        title: 'بند السرية',
        content: 'يلتزم الطرفان بالحفاظ على سرية المعلومات المتبادلة لمدة سنتين من تاريخ توقيع العقد.',
        riskLevel: AnalysisRiskLevel.low,
        recommendation: 'البند واضح ومتوازن، لا حاجة لتعديل.',
      ),
      const AnalysisClause(
        id: 'clause_3',
        title: 'بند تسوية النزاعات',
        content: 'يتم حل أي نزاع ينشأ عن هذا العقد عن طريق التحكيم دون تحديد الجهة أو مقر التحكيم.',
        riskLevel: AnalysisRiskLevel.medium,
        recommendation: 'يُفضّل تحديد مركز التحكيم والقانون الواجب التطبيق تجنبًا للغموض عند حدوث نزاع.',
      ),
      const AnalysisClause(
        id: 'clause_4',
        title: 'بند القوة القاهرة',
        content: 'يُعفى الطرفان من الالتزامات التعاقدية في حال وقوع ظروف قاهرة خارجة عن الإرادة.',
        riskLevel: AnalysisRiskLevel.low,
        recommendation: 'صياغة قياسية وسليمة.',
      ),
    ];

    final analysis = ContractAnalysis(
      id: 'analysis_${now.microsecondsSinceEpoch}',
      documentTitle: documentTitle,
      createdAt: now,
      overallRisk: AnalysisRiskLevel.medium,
      summary:
          'تم تحليل "$documentTitle" وتحديد ${clauses.length} بنود رئيسية. البند الأعلى خطورة هو "إنهاء العقد" '
          'نظرًا لغياب شرط تعويض عند الإنهاء المبكر — يُنصح بمراجعته قبل التوقيع.',
      clauses: clauses,
      sourceDocumentId: sourceDocumentId,
    );
    _analyses.insert(0, analysis);
    return analysis;
  }

  String _generateReply(String userText) {
    final text = userText.trim();
    if (text == 'أريد إنشاء عقد' || text == 'I want to create a contract') {
      return 'بالتأكيد! سأرشدك خطوة بخطوة لصياغة عقد قانوني موثوق مباشرة هنا في المحادثة.';
    }
    if (text.contains('عقد') || text.contains('contract')) {
      return 'يمكنني مساعدتك في فهم بنود العقد بشكل عام. إذا كان لديك عقد محدد، يمكنك استخدام ميزة "تحليل عقد" لأحصل لك تحليلًا مفصلًا للبنود والمخاطر المحتملة. '
          'تذكّر أن هذه استشارة أولية عامة وليست بديلاً عن استشارة محامٍ مرخّص.';
    }
    if (text.contains('محامٍ') || text.contains('محامي') || text.contains('lawyer')) {
      return 'يمكنك تصفح قائمة المحامين الموثقين وحجز استشارة مباشرة معهم من خلال قسم "المحامون" في التطبيق، وسيمكنك اختيار التخصص المناسب لحالتك.';
    }
    if (text.contains('إيجار') || text.contains('rent')) {
      return 'في عقود الإيجار، من المهم مراجعة بنود مدة العقد، شروط الإنهاء المبكر، وقيمة التأمين. هل ترغب أن أشرح لك أحد هذه البنود بمزيد من التفصيل؟';
    }
    return 'شكرًا لسؤالك. بناءً على المعلومات المتاحة، أنصحك بمراجعة الوثائق ذات الصلة بعناية، ويمكنني مساعدتك بشرح أي مصطلح قانوني تحتاجه. '
        'هذه استشارة أولية عامة فقط — للحالات المعقدة يُفضّل حجز استشارة مع محامٍ مختص.';
  }

  Future<void> _simulateLatency({int ms = 500}) => Future.delayed(Duration(milliseconds: ms));
}
