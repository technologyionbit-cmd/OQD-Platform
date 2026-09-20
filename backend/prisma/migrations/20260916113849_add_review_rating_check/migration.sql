-- Prisma DSL can't express CHECK constraints declaratively — hand-added,
-- same pattern as the exclusion/partial-unique constraints in other
-- migrations (docs/plans/individual-user-rollout.md "التشغيل محلياً").
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_rating_range_check" CHECK ("rating" >= 1 AND "rating" <= 5);
