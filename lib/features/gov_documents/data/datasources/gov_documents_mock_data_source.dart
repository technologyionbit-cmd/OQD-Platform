import 'package:aqd_ionbit/features/gov_documents/data/datasources/gov_documents_remote_data_source.dart';
import 'package:aqd_ionbit/features/gov_documents/domain/entities/gov_procedure.dart';

/// In-memory stand-in for the real backend (docs/backend/01-domain-model.md
/// §10). Catalog content is fixed reference data copied verbatim into the
/// seed script (backend/prisma/seed.ts) when this feature was migrated —
/// this file exists purely for tests/offline development, the real catalog
/// now lives in Postgres.
class GovDocumentsMockDataSource implements GovDocumentsRemoteDataSource {
  final Map<GovProcedureType, GovProcedureProgress> _progress = {};

  static const _procedures = [
    GovProcedure(
      id: 'mock-company-registration',
      type: GovProcedureType.companyRegistration,
      durationLabel: '٧ أيام عمل',
      accessType: GovProcedureAccessType.directLink,
      requiredDocuments: [
        GovRequiredDocument(id: 'd1', title: 'الهوية الوطنية سارية المفعول لجميع الشركاء'),
        GovRequiredDocument(id: 'd2', title: 'عقد التأسيس موثق من كاتب العدل'),
        GovRequiredDocument(id: 'd3', title: 'قائمة بأسماء المديرين وصلاحياتهم'),
        GovRequiredDocument(id: 'd4', title: 'سند ملكية أو عقد إيجار المقر'),
        GovRequiredDocument(id: 'd5', title: 'شهادة عدم التشابه في الاسم التجاري'),
      ],
      steps: [
        GovProcedureStep(order: 1, title: 'تجهيز المستندات', description: 'تجميع الهويات وعقد التأسيس والوثائق الداعمة من جميع الشركاء'),
        GovProcedureStep(order: 2, title: 'تعبئة البيانات', description: 'تعبئة نموذج التسجيل إلكترونياً واختيار الاسم التجاري'),
        GovProcedureStep(order: 3, title: 'تقديم الطلب', description: 'رفع الطلب عبر المنصة الإلكترونية أو التوجه لمركز خدمة وزارة التجارة'),
        GovProcedureStep(order: 4, title: 'دفع الرسوم', description: 'سداد رسوم التسجيل (150 د.أ) عبر البوابة الإلكترونية أو الدفع المباشر'),
        GovProcedureStep(order: 5, title: 'متابعة الطلب', description: 'استلام الموافقة الرسمية والترخيص خلال 3-5 أيام عمل'),
      ],
    ),
    GovProcedure(
      id: 'mock-property-registration',
      type: GovProcedureType.propertyRegistration,
      durationLabel: '٣-٥ أيام عمل',
      accessType: GovProcedureAccessType.directLink,
      requiredDocuments: [
        GovRequiredDocument(id: 'd1', title: 'صك الملكية الأصلي (طابو)'),
        GovRequiredDocument(id: 'd2', title: 'الهوية الوطنية للمالك والمشتري'),
        GovRequiredDocument(id: 'd3', title: 'وكالة رسمية موثقة إن وجد وكيل'),
        GovRequiredDocument(id: 'd4', title: 'شهادة عدم الحجز على العقار'),
        GovRequiredDocument(id: 'd5', title: 'إيصالات سداد الضرائب العقارية'),
      ],
      steps: [
        GovProcedureStep(order: 1, title: 'تجهيز المستندات', description: 'الحصول على صك الملكية وشهادة عدم الحجز من دائرة التسجيل'),
        GovProcedureStep(order: 2, title: 'تعبئة البيانات', description: 'تعبئة نموذج نقل الملكية وتوقيعه من الطرفين أمام الكاتب'),
        GovProcedureStep(order: 3, title: 'تقديم الطلب', description: 'تقديم الطلب لدى دائرة تسجيل الأراضي والمساحة'),
        GovProcedureStep(order: 4, title: 'دفع الرسوم', description: 'سداد رسوم التحويل ورسوم الطابع حسب قيمة العقار'),
        GovProcedureStep(order: 5, title: 'متابعة الطلب', description: 'استلام الصك الجديد بعد إكمال التسجيل والتوثيق الرسمي'),
      ],
    ),
    GovProcedure(
      id: 'mock-contract-notarization',
      type: GovProcedureType.contractNotarization,
      durationLabel: '١-٢ يوم عمل',
      accessType: GovProcedureAccessType.guide,
      requiredDocuments: [
        GovRequiredDocument(id: 'd1', title: 'نسختان أصليتان من العقد موقعتان من جميع الأطراف'),
        GovRequiredDocument(id: 'd2', title: 'الهوية الوطنية لجميع الأطراف'),
        GovRequiredDocument(id: 'd3', title: 'رسوم التوثيق (تحدد حسب نوع العقد)'),
        GovRequiredDocument(id: 'd4', title: 'وكالة رسمية إن كان أحد الأطراف غائباً'),
      ],
      steps: [
        GovProcedureStep(order: 1, title: 'تجهيز المستندات', description: 'طباعة نسختين من العقد وتوقيعهما من جميع الأطراف'),
        GovProcedureStep(order: 2, title: 'تعبئة البيانات', description: 'مراجعة بنود العقد والتأكد من اكتمال البيانات والتواريخ'),
        GovProcedureStep(order: 3, title: 'تقديم الطلب', description: 'التوجه لكاتب العدل أو المحكمة المختصة بالطلب'),
        GovProcedureStep(order: 4, title: 'دفع الرسوم', description: 'سداد رسوم التوثيق المحددة حسب نوع العقد وقيمته'),
        GovProcedureStep(order: 5, title: 'متابعة الطلب', description: 'استلام النسخة الموثقة في نفس اليوم أو اليوم التالي'),
      ],
    ),
    GovProcedure(
      id: 'mock-lawsuit-filing',
      type: GovProcedureType.lawsuitFiling,
      durationLabel: '٣-٤ أسابيع',
      accessType: GovProcedureAccessType.guide,
      requiredDocuments: [
        GovRequiredDocument(id: 'd1', title: 'لائحة الدعوى موقعة من المدعي أو محاميه'),
        GovRequiredDocument(id: 'd2', title: 'المستندات والأدلة الداعمة للدعوى'),
        GovRequiredDocument(id: 'd3', title: 'هوية المدعي الوطنية'),
        GovRequiredDocument(id: 'd4', title: 'وكالة قانونية للمحامي (إن وجد)'),
        GovRequiredDocument(id: 'd5', title: 'إيصال سداد رسوم المحكمة'),
      ],
      steps: [
        GovProcedureStep(order: 1, title: 'تجهيز المستندات', description: 'صياغة لائحة الدعوى وتجميع الأدلة والمستندات الداعمة'),
        GovProcedureStep(order: 2, title: 'تعبئة البيانات', description: 'التأكد من اكتمال بيانات المدعى عليه وموضوع الدعوى'),
        GovProcedureStep(order: 3, title: 'تقديم الطلب', description: 'تقديم لائحة الدعوى لدى قلم المحكمة المختصة'),
        GovProcedureStep(order: 4, title: 'دفع الرسوم', description: 'سداد رسوم القيد وفق قيمة الدعوى ونوعها'),
        GovProcedureStep(order: 5, title: 'متابعة الطلب', description: 'تحديد أول جلسة ومتابعة سير الدعوى أمام المحكمة'),
      ],
    ),
  ];

  @override
  Future<List<GovProcedure>> getGovProcedures({required String locale}) async => _procedures;

  @override
  Future<GovProcedureProgress> getProgress(GovProcedureType type) async {
    return _progress[type] ?? const GovProcedureProgress();
  }

  @override
  Future<GovProcedureProgress> updateProgress(GovProcedureType type, {String? toggleDocumentId, bool? start}) async {
    var current = _progress[type] ?? const GovProcedureProgress();
    if (toggleDocumentId != null) {
      final checked = Set<String>.of(current.checkedDocumentIds);
      if (!checked.remove(toggleDocumentId)) checked.add(toggleDocumentId);
      current = current.copyWith(checkedDocumentIds: checked);
    }
    if (start ?? false) {
      current = current.copyWith(started: true);
    }
    _progress[type] = current;
    return current;
  }
}
