-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "NotificationType" ADD VALUE 'lawyerVerificationApproved';
ALTER TYPE "NotificationType" ADD VALUE 'lawyerVerificationRejected';

-- AlterEnum
ALTER TYPE "UserRole" ADD VALUE 'admin';

-- AlterTable
ALTER TABLE "lawyer_profiles" ADD COLUMN     "verification_reviewed_at" TIMESTAMPTZ,
ADD COLUMN     "verification_reviewed_by_id" UUID,
ADD COLUMN     "verification_submitted_at" TIMESTAMPTZ;

-- CreateTable
CREATE TABLE "lawyer_verification_documents" (
    "id" UUID NOT NULL,
    "lawyer_profile_id" UUID NOT NULL,
    "storage_key" TEXT NOT NULL,
    "original_name" TEXT NOT NULL,
    "mime_type" TEXT NOT NULL,
    "size_bytes" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "lawyer_verification_documents_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "lawyer_verification_documents_storage_key_key" ON "lawyer_verification_documents"("storage_key");

-- CreateIndex
CREATE INDEX "lawyer_verification_documents_lawyer_profile_id_created_at_idx" ON "lawyer_verification_documents"("lawyer_profile_id", "created_at");

-- AddForeignKey
ALTER TABLE "lawyer_verification_documents" ADD CONSTRAINT "lawyer_verification_documents_lawyer_profile_id_fkey" FOREIGN KEY ("lawyer_profile_id") REFERENCES "lawyer_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;
