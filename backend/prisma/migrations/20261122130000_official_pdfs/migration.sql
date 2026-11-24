-- AlterTable
ALTER TABLE "contract_templates" ADD COLUMN     "pdf_file_name" TEXT,
ADD COLUMN     "pdf_storage_key" TEXT;

-- AlterTable
ALTER TABLE "gov_procedures" ADD COLUMN     "pdf_file_name" TEXT,
ADD COLUMN     "pdf_storage_key" TEXT;
