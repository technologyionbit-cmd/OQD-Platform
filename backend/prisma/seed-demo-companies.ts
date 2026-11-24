import * as bcrypt from 'bcryptjs';
import { OrganizationVerificationStatus, PrismaClient } from '@prisma/client';

/**
 * DEMO DATA for the admin web "Companies" page. Never run on production.
 *
 *   npx ts-node prisma/seed-demo-companies.ts
 *
 * Idempotent (upsert by email / registration number). Password: Password123.
 */
const COMPANIES: { name: string; state: OrganizationVerificationStatus }[] = [
  { name: 'شركة النور للتجارة', state: 'pending' },
  { name: 'مجموعة الأفق للاستثمار', state: 'pending' },
  { name: 'مؤسسة الريادة للخدمات', state: 'unverified' },
  { name: 'شركة البناء الحديث', state: 'verified' },
  { name: 'الشرق للتقنية', state: 'rejected' },
];

const prisma = new PrismaClient();

async function main(): Promise<void> {
  const passwordHash = await bcrypt.hash('Password123', 12);
  for (const [i, company] of COMPANIES.entries()) {
    const n = i + 1;
    const owner = await prisma.user.upsert({
      where: { email: `demo-company${n}@aqd.test` },
      update: {},
      create: {
        email: `demo-company${n}@aqd.test`,
        fullName: `مالك ${company.name}`,
        phone: `+96279200${String(n).padStart(4, '0')}`,
        phoneVerifiedAt: new Date(),
        passwordHash,
        role: 'company',
      },
    });
    const registration = `CR-DEMO-${String(n).padStart(4, '0')}`;
    await prisma.organization.upsert({
      where: { commercialRegistrationNumber: registration },
      update: { name: company.name, verificationStatus: company.state },
      create: {
        name: company.name,
        commercialRegistrationNumber: registration,
        ownerUserId: owner.id,
        verificationStatus: company.state,
      },
    });
    console.log(`Demo company: ${company.name} (${company.state})`);
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
