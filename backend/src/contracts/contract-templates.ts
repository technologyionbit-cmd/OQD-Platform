import type { ContractCategory } from '@prisma/client';

/**
 * The contract template catalog. Templates live in code, not the
 * database: they are product content that ships and is reviewed with the
 * app, and a deploy never needs a seed step. A contract stores the
 * template's key and version, and its own generated text, so editing a
 * template later never changes an existing contract — bump `version`
 * whenever a template's fields or wording change.
 */

export const CONTRACT_LOCALES = ['ar', 'en'] as const;
export type ContractLocale = (typeof CONTRACT_LOCALES)[number];

type Localized = Record<ContractLocale, string>;

export const CONTRACT_FIELD_TYPES = [
  'text',
  'multiline',
  'number',
  'date',
  'dropdown',
  'phone',
  'email',
  'currency',
] as const;
export type ContractFieldType = (typeof CONTRACT_FIELD_TYPES)[number];

export interface ContractFieldOption {
  /** Stored in the contract; stable across languages. */
  value: string;
  label: Localized;
}

export interface ContractFieldDefinition {
  id: string;
  type: ContractFieldType;
  label: Localized;
  isRequired: boolean;
  options?: ContractFieldOption[];
}

export interface ContractTemplateDefinition {
  key: string;
  version: number;
  category: ContractCategory;
  title: Localized;
  fields: ContractFieldDefinition[];
}

const required = (
  id: string,
  type: ContractFieldType,
  label: Localized,
  options?: ContractFieldOption[],
): ContractFieldDefinition => ({ id, type, label, isRequired: true, options });

const optional = (
  id: string,
  type: ContractFieldType,
  label: Localized,
): ContractFieldDefinition => ({ id, type, label, isRequired: false });

/** Every template names its two parties `partyA` and `partyB`. */
export const PARTY_FIELD_IDS = ['partyA', 'partyB'] as const;

export const CONTRACT_TEMPLATES: readonly ContractTemplateDefinition[] = [
  {
    key: 'employment',
    version: 1,
    category: 'employment',
    title: { ar: 'عقد عمل', en: 'Employment Contract' },
    fields: [
      required('partyA', 'text', {
        ar: 'الطرف الأول (صاحب العمل)',
        en: 'First Party (Employer)',
      }),
      required('partyB', 'text', {
        ar: 'الطرف الثاني (الموظف)',
        en: 'Second Party (Employee)',
      }),
      required('position', 'text', { ar: 'المسمى الوظيفي', en: 'Job Title' }),
      required(
        'employmentType',
        'dropdown',
        { ar: 'نوع الدوام', en: 'Employment Type' },
        [
          { value: 'fullTime', label: { ar: 'دوام كامل', en: 'Full-time' } },
          { value: 'partTime', label: { ar: 'دوام جزئي', en: 'Part-time' } },
          { value: 'remote', label: { ar: 'عن بعد', en: 'Remote' } },
        ],
      ),
      required('salary', 'currency', {
        ar: 'الراتب الشهري',
        en: 'Monthly Salary',
      }),
      required('startDate', 'date', {
        ar: 'تاريخ بداية العمل',
        en: 'Start Date',
      }),
      required('duration', 'number', {
        ar: 'مدة العقد (بالأشهر)',
        en: 'Contract Duration (months)',
      }),
      optional('contactEmail', 'email', {
        ar: 'البريد الإلكتروني للتواصل',
        en: 'Contact Email',
      }),
      optional('contactPhone', 'phone', {
        ar: 'رقم هاتف للتواصل',
        en: 'Contact Phone',
      }),
    ],
  },
  {
    key: 'sale',
    version: 1,
    category: 'sale',
    title: { ar: 'عقد بيع', en: 'Sale Contract' },
    fields: [
      required('partyA', 'text', { ar: 'البائع', en: 'Seller' }),
      required('partyB', 'text', { ar: 'المشتري', en: 'Buyer' }),
      required('itemDescription', 'multiline', {
        ar: 'وصف السلعة / الممتلكات',
        en: 'Item / Property Description',
      }),
      required('price', 'currency', { ar: 'السعر', en: 'Price' }),
      required('startDate', 'date', { ar: 'تاريخ البيع', en: 'Sale Date' }),
    ],
  },
  {
    key: 'rental',
    version: 1,
    category: 'rental',
    title: { ar: 'عقد إيجار', en: 'Rental Contract' },
    fields: [
      required('partyA', 'text', { ar: 'المؤجر', en: 'Landlord' }),
      required('partyB', 'text', { ar: 'المستأجر', en: 'Tenant' }),
      required(
        'propertyType',
        'dropdown',
        { ar: 'نوع العقار', en: 'Property Type' },
        [
          { value: 'apartment', label: { ar: 'شقة', en: 'Apartment' } },
          { value: 'villa', label: { ar: 'فيلا', en: 'Villa' } },
          { value: 'office', label: { ar: 'مكتب', en: 'Office' } },
          {
            value: 'retailShop',
            label: { ar: 'محل تجاري', en: 'Retail Shop' },
          },
        ],
      ),
      required('propertyAddress', 'multiline', {
        ar: 'عنوان العقار',
        en: 'Property Address',
      }),
      required('rentAmount', 'currency', {
        ar: 'قيمة الإيجار الشهري',
        en: 'Monthly Rent',
      }),
      required('startDate', 'date', {
        ar: 'تاريخ بداية الإيجار',
        en: 'Lease Start Date',
      }),
      required('duration', 'number', {
        ar: 'مدة العقد (بالأشهر)',
        en: 'Lease Duration (months)',
      }),
    ],
  },
  {
    key: 'partnership',
    version: 1,
    category: 'partnership',
    title: { ar: 'عقد شراكة', en: 'Partnership Contract' },
    fields: [
      required('partyA', 'text', { ar: 'الشريك الأول', en: 'First Partner' }),
      required('partyB', 'text', { ar: 'الشريك الثاني', en: 'Second Partner' }),
      required('businessName', 'text', {
        ar: 'اسم المشروع / الشركة',
        en: 'Business / Company Name',
      }),
      required('sharePercentage', 'number', {
        ar: 'نسبة الشراكة (%)',
        en: 'Partnership Share (%)',
      }),
      required('startDate', 'date', {
        ar: 'تاريخ بدء الشراكة',
        en: 'Partnership Start Date',
      }),
    ],
  },
  {
    key: 'nda',
    version: 1,
    category: 'nda',
    title: { ar: 'اتفاقية عدم إفصاح', en: 'NDA Agreement' },
    fields: [
      required('partyA', 'text', {
        ar: 'الطرف المُفصِح',
        en: 'Disclosing Party',
      }),
      required('partyB', 'text', {
        ar: 'الطرف المُستلِم',
        en: 'Receiving Party',
      }),
      required('purpose', 'multiline', {
        ar: 'الغرض من الإفصاح',
        en: 'Purpose of Disclosure',
      }),
      required('duration', 'number', {
        ar: 'مدة السرية (بالأشهر)',
        en: 'Confidentiality Period (months)',
      }),
      required('startDate', 'date', {
        ar: 'تاريخ السريان',
        en: 'Effective Date',
      }),
    ],
  },
  {
    key: 'service_agreement',
    version: 1,
    category: 'serviceAgreement',
    title: { ar: 'عقد خدمات', en: 'Service Agreement' },
    fields: [
      required('partyA', 'text', { ar: 'مقدم الخدمة', en: 'Service Provider' }),
      required('partyB', 'text', { ar: 'العميل', en: 'Client' }),
      required('serviceDescription', 'multiline', {
        ar: 'وصف الخدمة',
        en: 'Service Description',
      }),
      required('fee', 'currency', { ar: 'قيمة الأتعاب', en: 'Fee Amount' }),
      required('startDate', 'date', {
        ar: 'تاريخ بدء الخدمة',
        en: 'Service Start Date',
      }),
    ],
  },
  {
    key: 'other',
    version: 1,
    category: 'other',
    title: { ar: 'عقد آخر', en: 'Other Contract' },
    fields: [
      required('partyA', 'text', { ar: 'الطرف الأول', en: 'First Party' }),
      required('partyB', 'text', { ar: 'الطرف الثاني', en: 'Second Party' }),
      required('subject', 'multiline', {
        ar: 'موضوع العقد',
        en: 'Contract Subject',
      }),
      required('startDate', 'date', { ar: 'تاريخ العقد', en: 'Contract Date' }),
    ],
  },
];

export const CONTRACT_TEMPLATE_KEYS = CONTRACT_TEMPLATES.map((t) => t.key);

export function findTemplate(
  key: string,
): ContractTemplateDefinition | undefined {
  return CONTRACT_TEMPLATES.find((template) => template.key === key);
}
