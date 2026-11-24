import * as bcrypt from 'bcryptjs';
import { randomUUID } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { LawyerSpecialty, PrismaClient } from '@prisma/client';

/**
 * DEMO DATA for the admin web app: lawyers in every verification state,
 * so the "Lawyer verification" and "Lawyers" pages have something to show.
 * Never run this against production.
 *
 *   npx ts-node prisma/seed-demo-lawyers.ts
 *
 * Idempotent: accounts are upserted by email (demo-lawyer*@aqd.test);
 * pending lawyers get their document rows re-created on each run.
 * Password for all of them: Password123.
 */

type State = 'unverified' | 'pending' | 'verified' | 'rejected';

interface Demo {
  n: number;
  fullName: string;
  state: State;
  specialties: LawyerSpecialty[];
  years: number;
  rejectionReason?: string;
  documents?: string[];
}

const DEMO: Demo[] = [
  { n: 1, fullName: 'سامر الخطيب', state: 'pending', specialties: [LawyerSpecialty.commercial], years: 9, documents: ['national-id.pdf', 'bar-card.pdf'] },
  { n: 2, fullName: 'ليلى المصري', state: 'pending', specialties: [LawyerSpecialty.labor], years: 6, documents: ['bar-card.pdf'] },
  { n: 3, fullName: 'عمر الحداد', state: 'pending', specialties: [LawyerSpecialty.criminal, LawyerSpecialty.commercial], years: 12, documents: ['national-id.pdf', 'bar-card.pdf', 'certificate.pdf'] },
  { n: 4, fullName: 'هديل النابلسي', state: 'rejected', specialties: [LawyerSpecialty.intellectualProperty], years: 3, rejectionReason: 'صورة بطاقة النقابة غير واضحة، يرجى إعادة الرفع.' },
  { n: 5, fullName: 'يوسف العمري', state: 'unverified', specialties: [LawyerSpecialty.labor], years: 1 },
  { n: 6, fullName: 'دانا الشريف', state: 'verified', specialties: [LawyerSpecialty.commercial, LawyerSpecialty.intellectualProperty], years: 8 },
];

/** The smallest valid one-page PDF, so a download opens in any viewer. */
const PDF = Buffer.from(
  '%PDF-1.1\n1 0 obj<</Type/Catalog/Pages 2 0 R>>endobj\n' +
    '2 0 obj<</Type/Pages/Kids[3 0 R]/Count 1>>endobj\n' +
    '3 0 obj<</Type/Page/Parent 2 0 R/MediaBox[0 0 200 100]>>endobj\n' +
    'trailer<</Root 1 0 R>>\n%%EOF\n',
);

const prisma = new PrismaClient();
const FOLDER = 'lawyer-verification';

async function main(): Promise<void> {
  const uploads = resolve(process.env.UPLOADS_DIR ?? 'storage/uploads');
  await mkdir(join(uploads, FOLDER), { recursive: true });
  const passwordHash = await bcrypt.hash('Password123', 12);
  const now = Date.now();

  for (const demo of DEMO) {
    const email = `demo-lawyer${demo.n}@aqd.test`;
    const phone = `+96279100${String(demo.n).padStart(4, '0')}`;
    const user = await prisma.user.upsert({
      where: { email },
      update: { fullName: demo.fullName },
      create: {
        email,
        fullName: demo.fullName,
        phone,
        phoneVerifiedAt: new Date(),
        passwordHash,
        role: 'lawyer',
      },
    });

    const data = {
      fullName: demo.fullName,
      bio: 'حساب تجريبي لعرض لوحة الإدارة.',
      yearsOfExperience: demo.years,
      barLicenseNumber: `BAR-DEMO-${String(demo.n).padStart(4, '0')}`,
      verificationStatus: demo.state,
      verificationRejectionReason: demo.rejectionReason ?? null,
      verificationSubmittedAt:
        demo.state === 'unverified' ? null : new Date(now - demo.n * 3_600_000 * 7),
    };
    const profile = await prisma.lawyerProfile.upsert({
      where: { userId: user.id },
      update: data,
      create: { userId: user.id, ...data },
    });

    await prisma.lawyerProfileSpecialty.deleteMany({ where: { lawyerProfileId: profile.id } });
    await prisma.lawyerProfileSpecialty.createMany({
      data: demo.specialties.map((specialty) => ({ lawyerProfileId: profile.id, specialty })),
    });

    await prisma.lawyerVerificationDocument.deleteMany({ where: { lawyerProfileId: profile.id } });
    for (const name of demo.documents ?? []) {
      const storageKey = `${FOLDER}/${randomUUID()}.pdf`;
      await writeFile(join(uploads, storageKey), PDF, { mode: 0o600 });
      await prisma.lawyerVerificationDocument.create({
        data: {
          lawyerProfileId: profile.id,
          storageKey,
          originalName: name,
          mimeType: 'application/pdf',
          sizeBytes: PDF.length,
        },
      });
    }
    console.log(`Demo lawyer: ${demo.fullName} (${demo.state})`);
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
