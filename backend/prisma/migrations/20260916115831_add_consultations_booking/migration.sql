-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- CreateEnum
CREATE TYPE "ConsultationStatus" AS ENUM ('pendingApproval', 'confirmed', 'completed', 'cancelled', 'declined', 'missed', 'failed');

-- CreateTable
CREATE TABLE "availability_slots" (
    "id" UUID NOT NULL,
    "lawyer_profile_id" UUID NOT NULL,
    "start_at" TIMESTAMPTZ NOT NULL,
    "end_at" TIMESTAMPTZ NOT NULL,
    "is_booked" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "availability_slots_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "consultations" (
    "id" UUID NOT NULL,
    "client_user_id" UUID NOT NULL,
    "lawyer_profile_id" UUID NOT NULL,
    "availability_slot_id" UUID NOT NULL,
    "lawyer_name" TEXT NOT NULL,
    "client_name" TEXT NOT NULL,
    "type" "ConsultationType" NOT NULL,
    "status" "ConsultationStatus" NOT NULL DEFAULT 'pendingApproval',
    "scheduled_at" TIMESTAMPTZ NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,
    "notes" TEXT NOT NULL DEFAULT '',
    "cancellation_reason" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "consultations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "availability_slots_lawyer_profile_id_start_at_idx" ON "availability_slots"("lawyer_profile_id", "start_at");

-- Prisma DSL can't express exclusion constraints declaratively — hand-added
-- (docs/plans/individual-user-rollout.md Part 4). Prevents two *overlapping*
-- booked slots for the same lawyer from both landing `is_booked = true`
-- under a concurrent-booking race, at the database level rather than
-- relying solely on the application's conditional UPDATE.
ALTER TABLE "availability_slots" ADD CONSTRAINT "no_overlapping_booked_slots"
  EXCLUDE USING gist (
    "lawyer_profile_id" WITH =,
    tstzrange("start_at", "end_at") WITH &&
  ) WHERE ("is_booked");

-- CreateIndex
CREATE UNIQUE INDEX "consultations_availability_slot_id_key" ON "consultations"("availability_slot_id");

-- CreateIndex
CREATE INDEX "consultations_client_user_id_idx" ON "consultations"("client_user_id");

-- CreateIndex
CREATE INDEX "consultations_lawyer_profile_id_idx" ON "consultations"("lawyer_profile_id");

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_consultation_id_fkey" FOREIGN KEY ("consultation_id") REFERENCES "consultations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "availability_slots" ADD CONSTRAINT "availability_slots_lawyer_profile_id_fkey" FOREIGN KEY ("lawyer_profile_id") REFERENCES "lawyer_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consultations" ADD CONSTRAINT "consultations_client_user_id_fkey" FOREIGN KEY ("client_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consultations" ADD CONSTRAINT "consultations_lawyer_profile_id_fkey" FOREIGN KEY ("lawyer_profile_id") REFERENCES "lawyer_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consultations" ADD CONSTRAINT "consultations_availability_slot_id_fkey" FOREIGN KEY ("availability_slot_id") REFERENCES "availability_slots"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
