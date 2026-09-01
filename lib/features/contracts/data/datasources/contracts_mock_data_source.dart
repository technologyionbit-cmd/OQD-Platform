import 'dart:ui' show Locale;

import 'package:aqd_ionbit/core/errors/failure.dart';
import 'package:aqd_ionbit/features/contracts/data/datasources/contracts_remote_data_source.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_category.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_field_type.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_status.dart';
import 'package:aqd_ionbit/features/contracts/domain/entities/contract_template.dart';

/// Temporary, isolated stand-in for the real backend — no contract-template
/// or generation API is available yet. [getTemplates] returns different
/// content per [Locale] because template titles/field labels are content a
/// real backend would already localize per request; see
/// [ContractTemplate]'s doc for why that isn't routed through the app's
/// ARB files.
class ContractsMockDataSource implements ContractsRemoteDataSource {
  final List<Contract> _contracts = [
    Contract(
      id: 'c_seed_1',
      title: 'عقد خدمات — شركة الأفق',
      category: ContractCategory.serviceAgreement,
      status: ContractStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 14)),
      parties: const ['عمر الشريف', 'شركة الأفق للتقنية'],
      fieldValues: const {},
      templateId: 'service_agreement',
      generatedContent: 'عقد خدمات مكتمل بين عمر الشريف وشركة الأفق للتقنية.',
    ),
    Contract(
      id: 'c_seed_2',
      title: 'عقد إيجار شقة سكنية',
      category: ContractCategory.rental,
      status: ContractStatus.draft,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      parties: const ['خالد النابلسي', 'سارة الحداد'],
      fieldValues: const {},
      templateId: 'rental',
      generatedContent: 'مسودة عقد إيجار بين خالد النابلسي وسارة الحداد.',
    ),
  ];

  @override
  Future<List<ContractTemplate>> getTemplates(Locale locale) async {
    await _simulateLatency();
    return locale.languageCode == 'ar' ? _arTemplates : _enTemplates;
  }

  @override
  Future<List<Contract>> getContracts() async {
    await _simulateLatency();
    final sorted = List<Contract>.of(_contracts)..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  @override
  Future<Contract> getContractById(String id) async {
    await _simulateLatency();
    return _contracts.firstWhere((contract) => contract.id == id, orElse: () => throw const NotFoundFailure());
  }

  @override
  Future<Contract> saveDraft({required ContractTemplate template, required Map<String, String> fieldValues, String? contractId}) {
    return _save(template: template, fieldValues: fieldValues, status: ContractStatus.draft, contractId: contractId);
  }

  @override
  Future<Contract> generateContract({required ContractTemplate template, required Map<String, String> fieldValues, String? contractId}) {
    return _save(template: template, fieldValues: fieldValues, status: ContractStatus.pendingSignature, contractId: contractId);
  }

  @override
  Future<void> deleteContract(String id) async {
    await _simulateLatency();
    _contracts.removeWhere((contract) => contract.id == id);
  }

  Future<Contract> _save({
    required ContractTemplate template,
    required Map<String, String> fieldValues,
    required ContractStatus status,
    String? contractId,
  }) async {
    await _simulateLatency();
    final now = DateTime.now();
    final parties = [
      fieldValues['partyA'],
      fieldValues['partyB'],
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toList();
    final content = _buildContent(template, fieldValues);

    if (contractId != null) {
      final index = _contracts.indexWhere((contract) => contract.id == contractId);
      if (index == -1) throw const NotFoundFailure();
      final updated = _contracts[index].copyWith(
        title: template.title,
        category: template.category,
        status: status,
        updatedAt: now,
        parties: parties,
        fieldValues: fieldValues,
        generatedContent: content,
      );
      _contracts[index] = updated;
      return updated;
    }

    final created = Contract(
      id: 'c_${now.microsecondsSinceEpoch}',
      title: template.title,
      category: template.category,
      status: status,
      createdAt: now,
      updatedAt: now,
      parties: parties,
      fieldValues: fieldValues,
      templateId: template.id,
      generatedContent: content,
    );
    _contracts.insert(0, created);
    return created;
  }

  /// Stands in for real PDF/AI generation (see `ContractsRepository` doc) —
  /// a plain formatted summary of the filled fields, good enough to preview
  /// and store, structured so a real generator can replace just this.
  String _buildContent(ContractTemplate template, Map<String, String> fieldValues) {
    final buffer = StringBuffer()
      ..writeln(template.title)
      ..writeln();
    for (final field in template.fields) {
      final value = fieldValues[field.id];
      if (value == null || value.trim().isEmpty) continue;
      buffer.writeln('${field.label}: $value');
    }
    return buffer.toString().trim();
  }

  Future<void> _simulateLatency() => Future.delayed(const Duration(milliseconds: 500));
}

final _arTemplates = <ContractTemplate>[
  ContractTemplate(
    id: 'employment',
    category: ContractCategory.employment,
    title: 'عقد عمل',
    fields: [
      const ContractField(id: 'partyA', label: 'الطرف الأول (صاحب العمل)', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'الطرف الثاني (الموظف)', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'position', label: 'المسمى الوظيفي', type: ContractFieldType.text, isRequired: true),
      const ContractField(
        id: 'employmentType',
        label: 'نوع الدوام',
        type: ContractFieldType.dropdown,
        isRequired: true,
        options: ['دوام كامل', 'دوام جزئي', 'عن بعد'],
      ),
      const ContractField(id: 'salary', label: 'الراتب الشهري', type: ContractFieldType.currency, isRequired: true),
      const ContractField(id: 'startDate', label: 'تاريخ بداية العمل', type: ContractFieldType.date, isRequired: true),
      const ContractField(id: 'duration', label: 'مدة العقد (بالأشهر)', type: ContractFieldType.number, isRequired: true),
      const ContractField(id: 'contactEmail', label: 'البريد الإلكتروني للتواصل', type: ContractFieldType.email, isRequired: false),
      const ContractField(id: 'contactPhone', label: 'رقم هاتف للتواصل', type: ContractFieldType.phone, isRequired: false),
    ],
  ),
  ContractTemplate(
    id: 'sale',
    category: ContractCategory.sale,
    title: 'عقد بيع',
    fields: [
      const ContractField(id: 'partyA', label: 'البائع', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'المشتري', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'itemDescription', label: 'وصف السلعة / الممتلكات', type: ContractFieldType.multiline, isRequired: true),
      const ContractField(id: 'price', label: 'السعر', type: ContractFieldType.currency, isRequired: true),
      const ContractField(id: 'startDate', label: 'تاريخ البيع', type: ContractFieldType.date, isRequired: true),
    ],
  ),
  ContractTemplate(
    id: 'rental',
    category: ContractCategory.rental,
    title: 'عقد إيجار',
    fields: [
      const ContractField(id: 'partyA', label: 'المؤجر', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'المستأجر', type: ContractFieldType.text, isRequired: true),
      const ContractField(
        id: 'propertyType',
        label: 'نوع العقار',
        type: ContractFieldType.dropdown,
        isRequired: true,
        options: ['شقة', 'فيلا', 'مكتب', 'محل تجاري'],
      ),
      const ContractField(id: 'propertyAddress', label: 'عنوان العقار', type: ContractFieldType.multiline, isRequired: true),
      const ContractField(id: 'rentAmount', label: 'قيمة الإيجار الشهري', type: ContractFieldType.currency, isRequired: true),
      const ContractField(id: 'startDate', label: 'تاريخ بداية الإيجار', type: ContractFieldType.date, isRequired: true),
      const ContractField(id: 'duration', label: 'مدة العقد (بالأشهر)', type: ContractFieldType.number, isRequired: true),
    ],
  ),
  ContractTemplate(
    id: 'partnership',
    category: ContractCategory.partnership,
    title: 'عقد شراكة',
    fields: [
      const ContractField(id: 'partyA', label: 'الشريك الأول', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'الشريك الثاني', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'businessName', label: 'اسم المشروع / الشركة', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'sharePercentage', label: 'نسبة الشراكة (%)', type: ContractFieldType.number, isRequired: true),
      const ContractField(id: 'startDate', label: 'تاريخ بدء الشراكة', type: ContractFieldType.date, isRequired: true),
    ],
  ),
  ContractTemplate(
    id: 'nda',
    category: ContractCategory.nda,
    title: 'اتفاقية عدم إفصاح',
    fields: [
      const ContractField(id: 'partyA', label: 'الطرف المُفصِح', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'الطرف المُستلِم', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'purpose', label: 'الغرض من الإفصاح', type: ContractFieldType.multiline, isRequired: true),
      const ContractField(id: 'duration', label: 'مدة السرية (بالأشهر)', type: ContractFieldType.number, isRequired: true),
      const ContractField(id: 'startDate', label: 'تاريخ السريان', type: ContractFieldType.date, isRequired: true),
    ],
  ),
  ContractTemplate(
    id: 'service_agreement',
    category: ContractCategory.serviceAgreement,
    title: 'عقد خدمات',
    fields: [
      const ContractField(id: 'partyA', label: 'مقدم الخدمة', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'العميل', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'serviceDescription', label: 'وصف الخدمة', type: ContractFieldType.multiline, isRequired: true),
      const ContractField(id: 'fee', label: 'قيمة الأتعاب', type: ContractFieldType.currency, isRequired: true),
      const ContractField(id: 'startDate', label: 'تاريخ بدء الخدمة', type: ContractFieldType.date, isRequired: true),
    ],
  ),
  ContractTemplate(
    id: 'other',
    category: ContractCategory.other,
    title: 'عقد آخر',
    fields: [
      const ContractField(id: 'partyA', label: 'الطرف الأول', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'الطرف الثاني', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'subject', label: 'موضوع العقد', type: ContractFieldType.multiline, isRequired: true),
      const ContractField(id: 'startDate', label: 'تاريخ العقد', type: ContractFieldType.date, isRequired: true),
    ],
  ),
];

final _enTemplates = <ContractTemplate>[
  ContractTemplate(
    id: 'employment',
    category: ContractCategory.employment,
    title: 'Employment Contract',
    fields: [
      const ContractField(id: 'partyA', label: 'First Party (Employer)', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'Second Party (Employee)', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'position', label: 'Job Title', type: ContractFieldType.text, isRequired: true),
      const ContractField(
        id: 'employmentType',
        label: 'Employment Type',
        type: ContractFieldType.dropdown,
        isRequired: true,
        options: ['Full-time', 'Part-time', 'Remote'],
      ),
      const ContractField(id: 'salary', label: 'Monthly Salary', type: ContractFieldType.currency, isRequired: true),
      const ContractField(id: 'startDate', label: 'Start Date', type: ContractFieldType.date, isRequired: true),
      const ContractField(id: 'duration', label: 'Contract Duration (months)', type: ContractFieldType.number, isRequired: true),
      const ContractField(id: 'contactEmail', label: 'Contact Email', type: ContractFieldType.email, isRequired: false),
      const ContractField(id: 'contactPhone', label: 'Contact Phone', type: ContractFieldType.phone, isRequired: false),
    ],
  ),
  ContractTemplate(
    id: 'sale',
    category: ContractCategory.sale,
    title: 'Sale Contract',
    fields: [
      const ContractField(id: 'partyA', label: 'Seller', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'Buyer', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'itemDescription', label: 'Item / Property Description', type: ContractFieldType.multiline, isRequired: true),
      const ContractField(id: 'price', label: 'Price', type: ContractFieldType.currency, isRequired: true),
      const ContractField(id: 'startDate', label: 'Sale Date', type: ContractFieldType.date, isRequired: true),
    ],
  ),
  ContractTemplate(
    id: 'rental',
    category: ContractCategory.rental,
    title: 'Rental Contract',
    fields: [
      const ContractField(id: 'partyA', label: 'Landlord', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'Tenant', type: ContractFieldType.text, isRequired: true),
      const ContractField(
        id: 'propertyType',
        label: 'Property Type',
        type: ContractFieldType.dropdown,
        isRequired: true,
        options: ['Apartment', 'Villa', 'Office', 'Retail Shop'],
      ),
      const ContractField(id: 'propertyAddress', label: 'Property Address', type: ContractFieldType.multiline, isRequired: true),
      const ContractField(id: 'rentAmount', label: 'Monthly Rent', type: ContractFieldType.currency, isRequired: true),
      const ContractField(id: 'startDate', label: 'Lease Start Date', type: ContractFieldType.date, isRequired: true),
      const ContractField(id: 'duration', label: 'Lease Duration (months)', type: ContractFieldType.number, isRequired: true),
    ],
  ),
  ContractTemplate(
    id: 'partnership',
    category: ContractCategory.partnership,
    title: 'Partnership Contract',
    fields: [
      const ContractField(id: 'partyA', label: 'First Partner', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'Second Partner', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'businessName', label: 'Business / Company Name', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'sharePercentage', label: 'Partnership Share (%)', type: ContractFieldType.number, isRequired: true),
      const ContractField(id: 'startDate', label: 'Partnership Start Date', type: ContractFieldType.date, isRequired: true),
    ],
  ),
  ContractTemplate(
    id: 'nda',
    category: ContractCategory.nda,
    title: 'NDA Agreement',
    fields: [
      const ContractField(id: 'partyA', label: 'Disclosing Party', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'Receiving Party', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'purpose', label: 'Purpose of Disclosure', type: ContractFieldType.multiline, isRequired: true),
      const ContractField(id: 'duration', label: 'Confidentiality Period (months)', type: ContractFieldType.number, isRequired: true),
      const ContractField(id: 'startDate', label: 'Effective Date', type: ContractFieldType.date, isRequired: true),
    ],
  ),
  ContractTemplate(
    id: 'service_agreement',
    category: ContractCategory.serviceAgreement,
    title: 'Service Agreement',
    fields: [
      const ContractField(id: 'partyA', label: 'Service Provider', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'Client', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'serviceDescription', label: 'Service Description', type: ContractFieldType.multiline, isRequired: true),
      const ContractField(id: 'fee', label: 'Fee Amount', type: ContractFieldType.currency, isRequired: true),
      const ContractField(id: 'startDate', label: 'Service Start Date', type: ContractFieldType.date, isRequired: true),
    ],
  ),
  ContractTemplate(
    id: 'other',
    category: ContractCategory.other,
    title: 'Other Contract',
    fields: [
      const ContractField(id: 'partyA', label: 'First Party', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'partyB', label: 'Second Party', type: ContractFieldType.text, isRequired: true),
      const ContractField(id: 'subject', label: 'Contract Subject', type: ContractFieldType.multiline, isRequired: true),
      const ContractField(id: 'startDate', label: 'Contract Date', type: ContractFieldType.date, isRequired: true),
    ],
  ),
];
