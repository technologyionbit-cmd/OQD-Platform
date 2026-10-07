import * as bcrypt from 'bcryptjs';
import {
  ConsultationType,
  GovProcedureAccessType,
  GovProcedureType,
  LawyerSpecialty,
  PrismaClient,
} from '@prisma/client';

/**
 * Fixed reference catalog — content copied verbatim from
 * lib/features/gov_documents/presentation/providers/gov_procedures_provider.dart
 * (docs/plans/individual-user-rollout.md, Part 2). English strings are
 * placeholders pending real translation; Arabic is the source of truth.
 * Idempotent: safe to re-run (upsert on the unique `type`).
 */

interface SeedDoc {
  [locale: string]: string;
  ar: string;
  en: string;
}

interface SeedStep {
  title: SeedDoc;
  description: SeedDoc;
}

interface SeedProcedure {
  type: GovProcedureType;
  durationLabel: SeedDoc;
  accessType: GovProcedureAccessType;
  requiredDocuments: SeedDoc[];
  steps: SeedStep[];
}

const PROCEDURES: SeedProcedure[] = [
  {
    type: GovProcedureType.companyRegistration,
    durationLabel: { ar: '٧ أيام عمل', en: '7 business days' },
    accessType: GovProcedureAccessType.directLink,
    requiredDocuments: [
      { ar: 'الهوية الوطنية سارية المفعول لجميع الشركاء', en: 'Valid national ID for all partners' },
      { ar: 'عقد التأسيس موثق من كاتب العدل', en: 'Notarized articles of incorporation' },
      { ar: 'قائمة بأسماء المديرين وصلاحياتهم', en: 'List of managers and their authorities' },
      { ar: 'سند ملكية أو عقد إيجار المقر', en: 'Ownership deed or lease contract for the premises' },
      { ar: 'شهادة عدم التشابه في الاسم التجاري', en: 'Trade name non-similarity certificate' },
    ],
    steps: [
      { title: { ar: 'تجهيز المستندات', en: 'Prepare documents' }, description: { ar: 'تجميع الهويات وعقد التأسيس والوثائق الداعمة من جميع الشركاء', en: 'Collect IDs, articles of incorporation, and supporting documents from all partners' } },
      { title: { ar: 'تعبئة البيانات', en: 'Fill in the data' }, description: { ar: 'تعبئة نموذج التسجيل إلكترونياً واختيار الاسم التجاري', en: 'Fill in the registration form online and choose the trade name' } },
      { title: { ar: 'تقديم الطلب', en: 'Submit the request' }, description: { ar: 'رفع الطلب عبر المنصة الإلكترونية أو التوجه لمركز خدمة وزارة التجارة', en: 'Submit via the online platform or visit a Ministry of Trade service center' } },
      { title: { ar: 'دفع الرسوم', en: 'Pay the fees' }, description: { ar: 'سداد رسوم التسجيل (150 د.أ) عبر البوابة الإلكترونية أو الدفع المباشر', en: 'Pay the registration fee (150 JOD) via the online portal or in person' } },
      { title: { ar: 'متابعة الطلب', en: 'Follow up' }, description: { ar: 'استلام الموافقة الرسمية والترخيص خلال 3-5 أيام عمل', en: 'Receive official approval and license within 3-5 business days' } },
    ],
  },
  {
    type: GovProcedureType.propertyRegistration,
    durationLabel: { ar: '٣-٥ أيام عمل', en: '3-5 business days' },
    accessType: GovProcedureAccessType.directLink,
    requiredDocuments: [
      { ar: 'صك الملكية الأصلي (طابو)', en: 'Original ownership deed (Tabu)' },
      { ar: 'الهوية الوطنية للمالك والمشتري', en: 'National ID for owner and buyer' },
      { ar: 'وكالة رسمية موثقة إن وجد وكيل', en: 'Notarized power of attorney, if applicable' },
      { ar: 'شهادة عدم الحجز على العقار', en: 'Certificate confirming no lien on the property' },
      { ar: 'إيصالات سداد الضرائب العقارية', en: 'Property tax payment receipts' },
    ],
    steps: [
      { title: { ar: 'تجهيز المستندات', en: 'Prepare documents' }, description: { ar: 'الحصول على صك الملكية وشهادة عدم الحجز من دائرة التسجيل', en: 'Obtain the ownership deed and no-lien certificate from the registry department' } },
      { title: { ar: 'تعبئة البيانات', en: 'Fill in the data' }, description: { ar: 'تعبئة نموذج نقل الملكية وتوقيعه من الطرفين أمام الكاتب', en: 'Fill in and sign the ownership transfer form before the registrar' } },
      { title: { ar: 'تقديم الطلب', en: 'Submit the request' }, description: { ar: 'تقديم الطلب لدى دائرة تسجيل الأراضي والمساحة', en: 'Submit the request to the land registration and survey department' } },
      { title: { ar: 'دفع الرسوم', en: 'Pay the fees' }, description: { ar: 'سداد رسوم التحويل ورسوم الطابع حسب قيمة العقار', en: 'Pay transfer and stamp fees based on the property value' } },
      { title: { ar: 'متابعة الطلب', en: 'Follow up' }, description: { ar: 'استلام الصك الجديد بعد إكمال التسجيل والتوثيق الرسمي', en: 'Receive the new deed after registration and official notarization are complete' } },
    ],
  },
  {
    type: GovProcedureType.contractNotarization,
    durationLabel: { ar: '١-٢ يوم عمل', en: '1-2 business days' },
    accessType: GovProcedureAccessType.guide,
    requiredDocuments: [
      { ar: 'نسختان أصليتان من العقد موقعتان من جميع الأطراف', en: 'Two original signed copies of the contract' },
      { ar: 'الهوية الوطنية لجميع الأطراف', en: 'National ID for all parties' },
      { ar: 'رسوم التوثيق (تحدد حسب نوع العقد)', en: 'Notarization fee (varies by contract type)' },
      { ar: 'وكالة رسمية إن كان أحد الأطراف غائباً', en: 'Power of attorney if a party is absent' },
    ],
    steps: [
      { title: { ar: 'تجهيز المستندات', en: 'Prepare documents' }, description: { ar: 'طباعة نسختين من العقد وتوقيعهما من جميع الأطراف', en: 'Print two copies of the contract and have all parties sign them' } },
      { title: { ar: 'تعبئة البيانات', en: 'Fill in the data' }, description: { ar: 'مراجعة بنود العقد والتأكد من اكتمال البيانات والتواريخ', en: 'Review the contract terms and confirm all data and dates are complete' } },
      { title: { ar: 'تقديم الطلب', en: 'Submit the request' }, description: { ar: 'التوجه لكاتب العدل أو المحكمة المختصة بالطلب', en: 'Visit the notary public or the competent court' } },
      { title: { ar: 'دفع الرسوم', en: 'Pay the fees' }, description: { ar: 'سداد رسوم التوثيق المحددة حسب نوع العقد وقيمته', en: 'Pay the notarization fee based on contract type and value' } },
      { title: { ar: 'متابعة الطلب', en: 'Follow up' }, description: { ar: 'استلام النسخة الموثقة في نفس اليوم أو اليوم التالي', en: 'Receive the notarized copy the same day or the next' } },
    ],
  },
  {
    type: GovProcedureType.lawsuitFiling,
    durationLabel: { ar: '٣-٤ أسابيع', en: '3-4 weeks' },
    accessType: GovProcedureAccessType.guide,
    requiredDocuments: [
      { ar: 'لائحة الدعوى موقعة من المدعي أو محاميه', en: 'Statement of claim signed by the plaintiff or their lawyer' },
      { ar: 'المستندات والأدلة الداعمة للدعوى', en: 'Supporting documents and evidence' },
      { ar: 'هوية المدعي الوطنية', en: "Plaintiff's national ID" },
      { ar: 'وكالة قانونية للمحامي (إن وجد)', en: "Lawyer's power of attorney, if any" },
      { ar: 'إيصال سداد رسوم المحكمة', en: 'Court fee payment receipt' },
    ],
    steps: [
      { title: { ar: 'تجهيز المستندات', en: 'Prepare documents' }, description: { ar: 'صياغة لائحة الدعوى وتجميع الأدلة والمستندات الداعمة', en: 'Draft the statement of claim and gather supporting evidence' } },
      { title: { ar: 'تعبئة البيانات', en: 'Fill in the data' }, description: { ar: 'التأكد من اكتمال بيانات المدعى عليه وموضوع الدعوى', en: "Confirm the defendant's details and the subject of the claim are complete" } },
      { title: { ar: 'تقديم الطلب', en: 'Submit the request' }, description: { ar: 'تقديم لائحة الدعوى لدى قلم المحكمة المختصة', en: 'File the statement of claim at the competent court registry' } },
      { title: { ar: 'دفع الرسوم', en: 'Pay the fees' }, description: { ar: 'سداد رسوم القيد وفق قيمة الدعوى ونوعها', en: 'Pay filing fees based on the claim value and type' } },
      { title: { ar: 'متابعة الطلب', en: 'Follow up' }, description: { ar: 'تحديد أول جلسة ومتابعة سير الدعوى أمام المحكمة', en: 'Await the first hearing date and follow the case before the court' } },
    ],
  },
];

/**
 * Content copied verbatim from
 * lib/features/lawyers/data/datasources/lawyers_mock_data_source.dart
 * (docs/plans/individual-user-rollout.md, Part 3) so curl smoke-testing has
 * realistic, verified lawyers to search/filter/browse without needing the
 * (out-of-scope, lawyer-side) admin verify flow. Each needs a real `User`
 * row now that `LawyerProfile.userId` is a required 1:1 FK
 * (docs/backend/09-lawyers-marketplace.md §2) — password is the same
 * across all five, for local testing only.
 */
const SEED_LAWYER_PASSWORD = 'Password123';

interface SeedLawyer {
  email: string;
  fullName: string;
  barLicenseNumber: string;
  specialties: LawyerSpecialty[];
  bio: string;
  yearsOfExperience: number;
  rating: number;
  reviewsCount: number;
  pricing: Partial<Record<ConsultationType, number>>;
}

const LAWYERS: SeedLawyer[] = [
  {
    email: 'lawyer1@aqd.test',
    fullName: 'سارة المطيري',
    barLicenseNumber: 'BAR-SEED-0001',
    specialties: [LawyerSpecialty.commercial, LawyerSpecialty.corporate],
    bio: 'محامية متخصصة في القانون التجاري والشركات مع خبرة تمتد لأكثر من 9 سنوات في صياغة العقود التجارية وتأسيس الشركات.',
    yearsOfExperience: 9,
    rating: 4.8,
    reviewsCount: 132,
    pricing: { video: 250, voice: 180, written: 100 },
  },
  {
    email: 'lawyer2@aqd.test',
    fullName: 'محمد القحطاني',
    barLicenseNumber: 'BAR-SEED-0002',
    specialties: [LawyerSpecialty.realEstate, LawyerSpecialty.general],
    bio: 'محامٍ عقاري بخبرة 12 عامًا في عقود الإيجار والبيع والتوثيق العقاري.',
    yearsOfExperience: 12,
    rating: 4.6,
    reviewsCount: 98,
    pricing: { video: 220, written: 90 },
  },
  {
    email: 'lawyer3@aqd.test',
    fullName: 'نورة الحربي',
    barLicenseNumber: 'BAR-SEED-0003',
    specialties: [LawyerSpecialty.personalStatus, LawyerSpecialty.general],
    bio: 'محامية متخصصة في قضايا الأحوال الشخصية والأسرة، حاصلة على زمالة في الوساطة الأسرية.',
    yearsOfExperience: 6,
    rating: 4.9,
    reviewsCount: 210,
    pricing: { voice: 150, written: 80 },
  },
  {
    email: 'lawyer4@aqd.test',
    fullName: 'خالد العنزي',
    barLicenseNumber: 'BAR-SEED-0004',
    specialties: [LawyerSpecialty.criminal],
    bio: 'محامٍ جنائي بخبرة 15 عامًا في الترافع أمام المحاكم الجزائية.',
    yearsOfExperience: 15,
    rating: 4.4,
    reviewsCount: 76,
    pricing: { video: 300, voice: 220 },
  },
  {
    email: 'lawyer5@aqd.test',
    fullName: 'ريم الدوسري',
    barLicenseNumber: 'BAR-SEED-0005',
    specialties: [LawyerSpecialty.labor, LawyerSpecialty.intellectualProperty],
    bio: 'محامية متخصصة في قانون العمل والملكية الفكرية، عملت مع عدد من الشركات الناشئة.',
    yearsOfExperience: 4,
    rating: 4.5,
    reviewsCount: 41,
    pricing: { video: 190, voice: 140, written: 70 },
  },
];

const prisma = new PrismaClient();

async function seedLawyers(): Promise<void> {
  const passwordHash = await bcrypt.hash(SEED_LAWYER_PASSWORD, 12);

  for (const lawyer of LAWYERS) {
    const user = await prisma.user.upsert({
      where: { email: lawyer.email },
      // Seeded accounts count as verified so they can use every feature.
      update: { fullName: lawyer.fullName, emailVerifiedAt: new Date() },
      create: {
        email: lawyer.email,
        fullName: lawyer.fullName,
        passwordHash,
        role: 'lawyer',
        emailVerifiedAt: new Date(),
      },
    });

    const profile = await prisma.lawyerProfile.upsert({
      where: { userId: user.id },
      update: {
        fullName: lawyer.fullName,
        bio: lawyer.bio,
        yearsOfExperience: lawyer.yearsOfExperience,
        barLicenseNumber: lawyer.barLicenseNumber,
        rating: lawyer.rating,
        reviewsCount: lawyer.reviewsCount,
        // Seeded lawyers are pre-verified so the marketplace list/search
        // has real, non-empty results to test against — a freshly
        // self-registered lawyer still starts `unverified` (AuthService.register).
        verificationStatus: 'verified',
      },
      create: {
        userId: user.id,
        fullName: lawyer.fullName,
        bio: lawyer.bio,
        yearsOfExperience: lawyer.yearsOfExperience,
        barLicenseNumber: lawyer.barLicenseNumber,
        rating: lawyer.rating,
        reviewsCount: lawyer.reviewsCount,
        verificationStatus: 'verified',
      },
    });

    await prisma.lawyerProfileSpecialty.deleteMany({ where: { lawyerProfileId: profile.id } });
    await prisma.lawyerProfileSpecialty.createMany({
      data: lawyer.specialties.map((specialty) => ({ lawyerProfileId: profile.id, specialty })),
    });

    await prisma.lawyerConsultationOffering.deleteMany({ where: { lawyerProfileId: profile.id } });
    await prisma.lawyerConsultationOffering.createMany({
      data: Object.entries(lawyer.pricing).map(([consultationType, price]) => ({
        lawyerProfileId: profile.id,
        consultationType: consultationType as ConsultationType,
        price: price as number,
      })),
    });

    console.log(`Seeded lawyer: ${lawyer.fullName} (${lawyer.email})`);
  }
}

async function main(): Promise<void> {
  for (const proc of PROCEDURES) {
    const row = await prisma.govProcedure.upsert({
      where: { type: proc.type },
      update: {
        durationLabel: proc.durationLabel,
        accessType: proc.accessType,
      },
      create: {
        type: proc.type,
        durationLabel: proc.durationLabel,
        accessType: proc.accessType,
      },
    });

    // Re-seed children idempotently: delete + recreate rather than
    // per-row upserts, since these rows have no natural business key
    // beyond their position in a fixed, rarely-edited catalog.
    await prisma.govRequiredDocument.deleteMany({ where: { procedureId: row.id } });
    await prisma.govRequiredDocument.createMany({
      data: proc.requiredDocuments.map((title, index) => ({
        procedureId: row.id,
        title,
        sortOrder: index,
      })),
    });

    await prisma.govProcedureStep.deleteMany({ where: { procedureId: row.id } });
    await prisma.govProcedureStep.createMany({
      data: proc.steps.map((step, index) => ({
        procedureId: row.id,
        sortOrder: index,
        title: step.title,
        description: step.description,
      })),
    });

    console.log(`Seeded gov procedure: ${proc.type}`);
  }

  await seedLawyers();
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
