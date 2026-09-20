-- CreateEnum
CREATE TYPE "LawyerVerificationStatus" AS ENUM ('unverified', 'pending', 'verified', 'rejected');

-- CreateEnum
CREATE TYPE "ConsultationType" AS ENUM ('video', 'voice', 'written');

-- CreateTable
CREATE TABLE "lawyer_profiles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "full_name" TEXT NOT NULL,
    "bio" TEXT NOT NULL DEFAULT '',
    "years_of_experience" INTEGER NOT NULL DEFAULT 0,
    "bar_license_number" TEXT NOT NULL,
    "rating" DECIMAL(3,2) NOT NULL DEFAULT 0,
    "reviews_count" INTEGER NOT NULL DEFAULT 0,
    "verification_status" "LawyerVerificationStatus" NOT NULL DEFAULT 'unverified',
    "verification_rejection_reason" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "lawyer_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lawyer_profile_specialties" (
    "id" UUID NOT NULL,
    "lawyer_profile_id" UUID NOT NULL,
    "specialty" "LawyerSpecialty" NOT NULL,

    CONSTRAINT "lawyer_profile_specialties_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lawyer_consultation_offerings" (
    "id" UUID NOT NULL,
    "lawyer_profile_id" UUID NOT NULL,
    "consultation_type" "ConsultationType" NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'SAR',
    "is_active" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "lawyer_consultation_offerings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reviews" (
    "id" UUID NOT NULL,
    "lawyer_profile_id" UUID NOT NULL,
    "consultation_id" UUID NOT NULL,
    "reviewer_user_id" UUID NOT NULL,
    "rating" INTEGER NOT NULL,
    "comment" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reviews_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "lawyer_profiles_user_id_key" ON "lawyer_profiles"("user_id");

-- CreateIndex
CREATE INDEX "lawyer_profiles_verification_status_idx" ON "lawyer_profiles"("verification_status");

-- CreateIndex
CREATE UNIQUE INDEX "lawyer_profile_specialties_lawyer_profile_id_specialty_key" ON "lawyer_profile_specialties"("lawyer_profile_id", "specialty");

-- CreateIndex
CREATE UNIQUE INDEX "lawyer_consultation_offerings_lawyer_profile_id_consultatio_key" ON "lawyer_consultation_offerings"("lawyer_profile_id", "consultation_type");

-- CreateIndex
CREATE INDEX "reviews_lawyer_profile_id_idx" ON "reviews"("lawyer_profile_id");

-- CreateIndex
CREATE UNIQUE INDEX "reviews_consultation_id_reviewer_user_id_key" ON "reviews"("consultation_id", "reviewer_user_id");

-- AddForeignKey
ALTER TABLE "lawyer_profiles" ADD CONSTRAINT "lawyer_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lawyer_profile_specialties" ADD CONSTRAINT "lawyer_profile_specialties_lawyer_profile_id_fkey" FOREIGN KEY ("lawyer_profile_id") REFERENCES "lawyer_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lawyer_consultation_offerings" ADD CONSTRAINT "lawyer_consultation_offerings_lawyer_profile_id_fkey" FOREIGN KEY ("lawyer_profile_id") REFERENCES "lawyer_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_lawyer_profile_id_fkey" FOREIGN KEY ("lawyer_profile_id") REFERENCES "lawyer_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_reviewer_user_id_fkey" FOREIGN KEY ("reviewer_user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
