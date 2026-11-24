-- AlterTable
ALTER TABLE "users" ADD COLUMN     "admin_full_access" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "admin_permissions" TEXT[] DEFAULT ARRAY[]::TEXT[];

-- Every admin that exists today keeps full access.
UPDATE "users" SET "admin_full_access" = true WHERE "role" = 'admin';
