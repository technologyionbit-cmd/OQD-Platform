-- CreateEnum
CREATE TYPE "GovProcedureType" AS ENUM ('companyRegistration', 'propertyRegistration', 'contractNotarization', 'lawsuitFiling');

-- CreateEnum
CREATE TYPE "GovProcedureAccessType" AS ENUM ('directLink', 'guide');

-- CreateTable
CREATE TABLE "gov_procedures" (
    "id" UUID NOT NULL,
    "type" "GovProcedureType" NOT NULL,
    "duration_label" JSONB NOT NULL,
    "access_type" "GovProcedureAccessType" NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "gov_procedures_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gov_required_documents" (
    "id" UUID NOT NULL,
    "procedure_id" UUID NOT NULL,
    "title" JSONB NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "gov_required_documents_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "gov_procedure_steps" (
    "id" UUID NOT NULL,
    "procedure_id" UUID NOT NULL,
    "sort_order" INTEGER NOT NULL,
    "title" JSONB NOT NULL,
    "description" JSONB NOT NULL,

    CONSTRAINT "gov_procedure_steps_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_gov_procedure_progress" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "procedure_id" UUID NOT NULL,
    "started_at" TIMESTAMPTZ,
    "checked_document_ids" UUID[] DEFAULT ARRAY[]::UUID[],
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "user_gov_procedure_progress_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "gov_procedures_type_key" ON "gov_procedures"("type");

-- CreateIndex
CREATE INDEX "gov_required_documents_procedure_id_idx" ON "gov_required_documents"("procedure_id");

-- CreateIndex
CREATE INDEX "gov_procedure_steps_procedure_id_idx" ON "gov_procedure_steps"("procedure_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_gov_procedure_progress_user_id_procedure_id_key" ON "user_gov_procedure_progress"("user_id", "procedure_id");

-- AddForeignKey
ALTER TABLE "gov_required_documents" ADD CONSTRAINT "gov_required_documents_procedure_id_fkey" FOREIGN KEY ("procedure_id") REFERENCES "gov_procedures"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "gov_procedure_steps" ADD CONSTRAINT "gov_procedure_steps_procedure_id_fkey" FOREIGN KEY ("procedure_id") REFERENCES "gov_procedures"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_gov_procedure_progress" ADD CONSTRAINT "user_gov_procedure_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_gov_procedure_progress" ADD CONSTRAINT "user_gov_procedure_progress_procedure_id_fkey" FOREIGN KEY ("procedure_id") REFERENCES "gov_procedures"("id") ON DELETE CASCADE ON UPDATE CASCADE;
