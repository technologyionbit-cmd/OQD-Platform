-- AlterTable
ALTER TABLE "users" ADD COLUMN     "suspended_at" TIMESTAMPTZ,
ADD COLUMN     "suspended_by_id" UUID,
ADD COLUMN     "suspended_reason" TEXT;

-- CreateIndex
CREATE INDEX "users_status_idx" ON "users"("status");

-- CreateIndex
CREATE INDEX "users_created_at_idx" ON "users"("created_at");
