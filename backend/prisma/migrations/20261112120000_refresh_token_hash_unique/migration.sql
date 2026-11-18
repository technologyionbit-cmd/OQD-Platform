-- Every token refresh and logout looks the session up by the hash of the
-- presented refresh token; without an index that is a full table scan.
-- The hashes are SHA-256 of 48 random bytes, so uniqueness always holds.
-- Prisma runs this file in one transaction, so no CONCURRENTLY; the build
-- locks writes to refresh_tokens only for as long as the index takes to
-- build, which is short at this table size. Check the row count first on
-- a large production table.
CREATE UNIQUE INDEX "refresh_tokens_refresh_token_hash_key" ON "refresh_tokens"("refresh_token_hash");
