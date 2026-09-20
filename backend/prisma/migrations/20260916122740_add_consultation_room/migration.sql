-- CreateEnum
CREATE TYPE "ConsultationRoomState" AS ENUM ('waiting', 'ready', 'connecting', 'active', 'ended', 'failed');

-- CreateEnum
CREATE TYPE "ConsultationParticipantEventType" AS ENUM ('join', 'leave', 'reconnect');

-- CreateTable
CREATE TABLE "consultation_room_sessions" (
    "id" UUID NOT NULL,
    "consultation_id" UUID NOT NULL,
    "state" "ConsultationRoomState" NOT NULL DEFAULT 'waiting',
    "is_muted" BOOLEAN NOT NULL DEFAULT false,
    "is_camera_on" BOOLEAN NOT NULL DEFAULT true,
    "is_speaker_on" BOOLEAN NOT NULL DEFAULT true,
    "reconnect_attempts" INTEGER NOT NULL DEFAULT 0,
    "ended_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "consultation_room_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "consultation_room_tokens" (
    "id" UUID NOT NULL,
    "session_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "token_hash" TEXT NOT NULL,
    "expires_at" TIMESTAMPTZ NOT NULL,
    "consumed_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "consultation_room_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "consultation_participant_events" (
    "id" UUID NOT NULL,
    "session_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "event_type" "ConsultationParticipantEventType" NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "consultation_participant_events_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "consultation_room_sessions_consultation_id_key" ON "consultation_room_sessions"("consultation_id");

-- CreateIndex
CREATE UNIQUE INDEX "consultation_room_tokens_token_hash_key" ON "consultation_room_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "consultation_room_tokens_session_id_user_id_idx" ON "consultation_room_tokens"("session_id", "user_id");

-- CreateIndex
CREATE INDEX "consultation_participant_events_session_id_idx" ON "consultation_participant_events"("session_id");

-- AddForeignKey
ALTER TABLE "consultation_room_sessions" ADD CONSTRAINT "consultation_room_sessions_consultation_id_fkey" FOREIGN KEY ("consultation_id") REFERENCES "consultations"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consultation_room_tokens" ADD CONSTRAINT "consultation_room_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "consultation_room_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "consultation_participant_events" ADD CONSTRAINT "consultation_participant_events_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "consultation_room_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;
