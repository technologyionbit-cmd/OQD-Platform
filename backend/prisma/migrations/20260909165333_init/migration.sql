-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "citext";

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('client', 'lawyer', 'company');

-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('active', 'suspended', 'banned', 'pendingDeletion');

-- CreateEnum
CREATE TYPE "LawyerSpecialty" AS ENUM ('commercial', 'personalStatus', 'criminal', 'labor', 'realEstate', 'corporate', 'intellectualProperty', 'general');

-- CreateEnum
CREATE TYPE "VerificationChannel" AS ENUM ('email', 'sms');

-- CreateEnum
CREATE TYPE "VerificationPurpose" AS ENUM ('passwordReset', 'emailVerification', 'phoneVerification');

-- CreateEnum
CREATE TYPE "OrganizationVerificationStatus" AS ENUM ('unverified', 'pending', 'verified', 'rejected');

-- CreateEnum
CREATE TYPE "OrgMemberRole" AS ENUM ('owner', 'admin', 'manager', 'member');

-- CreateEnum
CREATE TYPE "OrgMemberStatus" AS ENUM ('invited', 'active', 'removed');

-- CreateEnum
CREATE TYPE "OrgInvitationStatus" AS ENUM ('pending', 'accepted', 'declined', 'expired', 'revoked');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "full_name" TEXT NOT NULL,
    "email" CITEXT NOT NULL,
    "email_verified_at" TIMESTAMPTZ,
    "phone" TEXT,
    "phone_verified_at" TIMESTAMPTZ,
    "password_hash" TEXT NOT NULL,
    "role" "UserRole" NOT NULL,
    "status" "UserStatus" NOT NULL DEFAULT 'active',
    "two_factor_enabled" BOOLEAN NOT NULL DEFAULT false,
    "last_login_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,
    "deleted_at" TIMESTAMPTZ,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lawyer_registration_details" (
    "user_id" UUID NOT NULL,
    "bar_license_number" TEXT NOT NULL,
    "main_specialty" "LawyerSpecialty" NOT NULL,

    CONSTRAINT "lawyer_registration_details_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "refresh_tokens" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "refresh_token_hash" TEXT NOT NULL,
    "device_label" TEXT,
    "ip_address" INET,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ NOT NULL,
    "revoked_at" TIMESTAMPTZ,
    "last_used_at" TIMESTAMPTZ,

    CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "verification_codes" (
    "id" UUID NOT NULL,
    "user_id" UUID,
    "destination" TEXT NOT NULL,
    "channel" "VerificationChannel" NOT NULL,
    "code_hash" TEXT NOT NULL,
    "purpose" "VerificationPurpose" NOT NULL,
    "expires_at" TIMESTAMPTZ NOT NULL,
    "consumed_at" TIMESTAMPTZ,
    "attempt_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "verification_codes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "organizations" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "commercial_registration_number" TEXT NOT NULL,
    "owner_user_id" UUID NOT NULL,
    "verification_status" "OrganizationVerificationStatus" NOT NULL DEFAULT 'unverified',
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "organizations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "organization_members" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "user_id" UUID,
    "email" CITEXT NOT NULL,
    "full_name" TEXT NOT NULL,
    "role" "OrgMemberRole" NOT NULL,
    "status" "OrgMemberStatus" NOT NULL DEFAULT 'invited',
    "joined_at" TIMESTAMPTZ,
    "invited_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "removed_at" TIMESTAMPTZ,

    CONSTRAINT "organization_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "organization_invitations" (
    "id" UUID NOT NULL,
    "organization_id" UUID NOT NULL,
    "email" CITEXT NOT NULL,
    "role" "OrgMemberRole" NOT NULL,
    "token" TEXT NOT NULL,
    "invited_by_user_id" UUID NOT NULL,
    "status" "OrgInvitationStatus" NOT NULL DEFAULT 'pending',
    "expires_at" TIMESTAMPTZ NOT NULL,
    "responded_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "organization_invitations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_role_idx" ON "users"("role");

-- CreateIndex
CREATE UNIQUE INDEX "lawyer_registration_details_bar_license_number_key" ON "lawyer_registration_details"("bar_license_number");

-- CreateIndex
CREATE INDEX "refresh_tokens_user_id_idx" ON "refresh_tokens"("user_id");

-- CreateIndex
CREATE INDEX "verification_codes_user_id_idx" ON "verification_codes"("user_id");

-- CreateIndex
CREATE INDEX "verification_codes_destination_purpose_idx" ON "verification_codes"("destination", "purpose");

-- CreateIndex
CREATE UNIQUE INDEX "organizations_commercial_registration_number_key" ON "organizations"("commercial_registration_number");

-- CreateIndex
CREATE INDEX "organizations_owner_user_id_idx" ON "organizations"("owner_user_id");

-- CreateIndex
CREATE INDEX "organization_members_organization_id_email_idx" ON "organization_members"("organization_id", "email");

-- CreateIndex
CREATE INDEX "organization_members_user_id_idx" ON "organization_members"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "organization_members_organization_id_user_id_key" ON "organization_members"("organization_id", "user_id");

-- CreateIndex
CREATE UNIQUE INDEX "organization_invitations_token_key" ON "organization_invitations"("token");

-- CreateIndex
CREATE INDEX "organization_invitations_organization_id_idx" ON "organization_invitations"("organization_id");

-- CreateIndex
CREATE INDEX "organization_invitations_email_idx" ON "organization_invitations"("email");

-- AddForeignKey
ALTER TABLE "lawyer_registration_details" ADD CONSTRAINT "lawyer_registration_details_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "verification_codes" ADD CONSTRAINT "verification_codes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organizations" ADD CONSTRAINT "organizations_owner_user_id_fkey" FOREIGN KEY ("owner_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organization_members" ADD CONSTRAINT "organization_members_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organization_members" ADD CONSTRAINT "organization_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organization_invitations" ADD CONSTRAINT "organization_invitations_organization_id_fkey" FOREIGN KEY ("organization_id") REFERENCES "organizations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "organization_invitations" ADD CONSTRAINT "organization_invitations_invited_by_user_id_fkey" FOREIGN KEY ("invited_by_user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
