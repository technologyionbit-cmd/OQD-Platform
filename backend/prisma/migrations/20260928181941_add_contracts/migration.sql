-- CreateEnum
CREATE TYPE "ContractStatus" AS ENUM ('draft', 'pendingSignature', 'signed', 'completed', 'cancelled');

-- CreateEnum
CREATE TYPE "ContractCategory" AS ENUM ('employment', 'sale', 'rental', 'partnership', 'nda', 'serviceAgreement', 'other');

-- CreateTable
CREATE TABLE "contracts" (
    "id" UUID NOT NULL,
    "owner_user_id" UUID NOT NULL,
    "template_key" TEXT NOT NULL,
    "template_version" INTEGER NOT NULL,
    "category" "ContractCategory" NOT NULL,
    "locale" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "status" "ContractStatus" NOT NULL DEFAULT 'draft',
    "field_values" JSONB NOT NULL,
    "parties" TEXT[],
    "generated_content" TEXT,
    "generated_at" TIMESTAMPTZ,
    "signed_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "contracts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contract_signatures" (
    "id" UUID NOT NULL,
    "contract_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "ip_address" TEXT,
    "user_agent" TEXT,
    "signed_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "contract_signatures_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "contracts_owner_user_id_updated_at_idx" ON "contracts"("owner_user_id", "updated_at");

-- CreateIndex
CREATE INDEX "contract_signatures_user_id_idx" ON "contract_signatures"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "contract_signatures_contract_id_user_id_key" ON "contract_signatures"("contract_id", "user_id");

-- AddForeignKey
ALTER TABLE "contracts" ADD CONSTRAINT "contracts_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contract_signatures" ADD CONSTRAINT "contract_signatures_contract_id_fkey" FOREIGN KEY ("contract_id") REFERENCES "contracts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contract_signatures" ADD CONSTRAINT "contract_signatures_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
