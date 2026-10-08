-- Phone sign-in: every code is texted to the account's phone number, which
-- becomes the unique sign-in identifier. Email verification is removed.
BEGIN;

-- Normalize stored numbers to E.164 Jordanian mobile (+9627XXXXXXXX), the
-- only shape the API accepts from now on (src/auth/dto/phone.rules.ts).
-- Anything else cannot sign in by phone, so it is cleared.
UPDATE "users"
SET "phone" = CASE
  WHEN "phone" ~ '^[0-9[:space:]()+-]+$'
   AND regexp_replace("phone", '\D', '', 'g') ~ '^(00962|962|0)?7[789][0-9]{7}$'
  THEN '+962' || right(regexp_replace("phone", '\D', '', 'g'), 9)
  ELSE NULL
END
WHERE "phone" IS NOT NULL;

-- One account per number: the oldest account keeps a shared number.
UPDATE "users" AS u
SET "phone" = NULL
FROM (
  SELECT "id", row_number() OVER (PARTITION BY "phone" ORDER BY "created_at", "id") AS n
  FROM "users"
  WHERE "phone" IS NOT NULL
) AS d
WHERE u."id" = d."id" AND d.n > 1;

UPDATE "users" SET "phone_verified_at" = NULL WHERE "phone" IS NULL;

CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

ALTER TABLE "users" DROP COLUMN "email_verified_at";

-- Outstanding codes were sent to email addresses; none can be used any more.
DELETE FROM "verification_codes";

CREATE TYPE "VerificationPurpose_new" AS ENUM ('passwordReset', 'phoneVerification');
ALTER TABLE "verification_codes" ALTER COLUMN "purpose" TYPE "VerificationPurpose_new" USING ("purpose"::text::"VerificationPurpose_new");
ALTER TYPE "VerificationPurpose" RENAME TO "VerificationPurpose_old";
ALTER TYPE "VerificationPurpose_new" RENAME TO "VerificationPurpose";
DROP TYPE "VerificationPurpose_old";

COMMIT;
