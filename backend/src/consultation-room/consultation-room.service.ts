import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { createHash, randomBytes } from 'node:crypto';
import type { ConsultationRoomSession, ConsultationRoomState } from '@prisma/client';
import { ApiErrorCode } from '../common/errors/api-error-codes';
import { PrismaService } from '../prisma/prisma.service';
import type { AuthenticatedUser } from '../auth/auth.types';
import type { UpdateRoomMetricsDto } from './dto/update-room-metrics.dto';

const TOKEN_TTL_MS = 5 * 60 * 1000;
const MAX_RECONNECT_ATTEMPTS = 3;

/** Forward transitions this service will perform — mirrors the frontend
 *  mock's own guard set exactly (`ConsultationRoomMockDataSource._transition`
 *  and its bespoke `connect`/`retryConnection` checks) so a real
 *  WebRTC/Agora/Twilio-backed implementation can swap in later without
 *  the state machine itself changing shape. */
const ALLOWED_FROM: Record<'join' | 'connect' | 'retry' | 'connectionLost' | 'end', ConsultationRoomState[]> = {
  join: ['waiting'],
  connect: ['ready'],
  retry: ['failed'],
  connectionLost: ['active'],
  end: ['waiting', 'ready', 'connecting', 'active', 'failed'],
};

export interface RoomTokenResult {
  roomToken: string;
  expiresAt: Date;
  session: ConsultationRoomSession;
}

@Injectable()
export class ConsultationRoomService {
  constructor(private readonly prisma: PrismaService) {}

  async issueToken(user: AuthenticatedUser, consultationId: string): Promise<RoomTokenResult> {
    await this.consultationForParticipant(user, consultationId);

    const session = await this.prisma.consultationRoomSession.upsert({
      where: { consultationId },
      create: { consultationId },
      update: {},
    });

    // Single-use: any previous token this user held for this session is
    // superseded the moment a new one is minted, not just when consumed.
    await this.prisma.consultationRoomToken.deleteMany({
      where: { sessionId: session.id, userId: user.id, consumedAt: null },
    });

    const raw = randomBytes(32).toString('base64url');
    const expiresAt = new Date(Date.now() + TOKEN_TTL_MS);
    await this.prisma.consultationRoomToken.create({
      data: { sessionId: session.id, userId: user.id, tokenHash: this.hash(raw), expiresAt },
    });

    return { roomToken: raw, expiresAt, session };
  }

  async join(user: AuthenticatedUser, consultationId: string, roomToken: string): Promise<ConsultationRoomSession> {
    const session = await this.requireSession(user, consultationId);
    const token = await this.prisma.consultationRoomToken.findUnique({ where: { tokenHash: this.hash(roomToken) } });
    if (!token || token.sessionId !== session.id || token.userId !== user.id) {
      throw this.unauthorizedToken();
    }
    if (token.consumedAt) {
      throw this.unauthorizedToken();
    }
    if (token.expiresAt.getTime() <= Date.now()) {
      throw this.unauthorizedToken();
    }
    this.assertTransition(session.state, 'join');

    return this.prisma.$transaction(async (tx) => {
      await tx.consultationRoomToken.update({ where: { id: token.id }, data: { consumedAt: new Date() } });
      await tx.consultationParticipantEvent.create({
        data: { sessionId: session.id, userId: user.id, eventType: 'join' },
      });
      return tx.consultationRoomSession.update({ where: { id: session.id }, data: { state: 'ready' } });
    });
  }

  /** There's no real media negotiation to fail here yet (no provider —
   *  see the schema comment on `ConsultationRoomSession`), so this always
   *  resolves to `active`; the frontend mock's written-vs-voice/video
   *  branching (skip `connecting` vs. pass through it) and its randomized
   *  failure were purely local demo concerns that don't apply to a real
   *  round-trip with nothing on the other end to fail against yet. */
  async connect(user: AuthenticatedUser, consultationId: string): Promise<ConsultationRoomSession> {
    const session = await this.requireSession(user, consultationId);
    this.assertTransition(session.state, 'connect');
    return this.prisma.consultationRoomSession.update({ where: { id: session.id }, data: { state: 'active' } });
  }

  async retryConnection(user: AuthenticatedUser, consultationId: string): Promise<ConsultationRoomSession> {
    const session = await this.requireSession(user, consultationId);
    this.assertTransition(session.state, 'retry');
    if (session.reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
      throw new BadRequestException({
        message: 'Maximum reconnection attempts exhausted.',
        code: ApiErrorCode.BAD_REQUEST,
      });
    }

    return this.prisma.$transaction(async (tx) => {
      await tx.consultationParticipantEvent.create({
        data: { sessionId: session.id, userId: user.id, eventType: 'reconnect' },
      });
      return tx.consultationRoomSession.update({
        where: { id: session.id },
        data: { state: 'active', reconnectAttempts: session.reconnectAttempts + 1 },
      });
    });
  }

  async reportConnectionLost(user: AuthenticatedUser, consultationId: string): Promise<ConsultationRoomSession> {
    const session = await this.requireSession(user, consultationId);
    this.assertTransition(session.state, 'connectionLost');
    return this.prisma.consultationRoomSession.update({ where: { id: session.id }, data: { state: 'failed' } });
  }

  async leave(user: AuthenticatedUser, consultationId: string): Promise<ConsultationRoomSession> {
    const session = await this.requireSession(user, consultationId);
    await this.prisma.consultationParticipantEvent.create({
      data: { sessionId: session.id, userId: user.id, eventType: 'leave' },
    });
    return session;
  }

  async endSession(user: AuthenticatedUser, consultationId: string): Promise<ConsultationRoomSession> {
    const session = await this.requireSession(user, consultationId);
    this.assertTransition(session.state, 'end');

    return this.prisma.$transaction(async (tx) => {
      await tx.consultationParticipantEvent.create({
        data: { sessionId: session.id, userId: user.id, eventType: 'leave' },
      });
      return tx.consultationRoomSession.update({
        where: { id: session.id },
        data: { state: 'ended', endedAt: new Date() },
      });
    });
  }

  async updateMetrics(user: AuthenticatedUser, consultationId: string, dto: UpdateRoomMetricsDto): Promise<ConsultationRoomSession> {
    const session = await this.requireSession(user, consultationId);
    return this.prisma.consultationRoomSession.update({
      where: { id: session.id },
      data: {
        ...(dto.isMuted !== undefined ? { isMuted: dto.isMuted } : {}),
        ...(dto.isCameraOn !== undefined ? { isCameraOn: dto.isCameraOn } : {}),
        ...(dto.isSpeakerOn !== undefined ? { isSpeakerOn: dto.isSpeakerOn } : {}),
      },
    });
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /** Session must already exist — every mutating action other than
   *  `/token` (which creates it) requires a prior `token` call, matching
   *  the frontend's own `getSession()`-before-everything-else flow. */
  private async requireSession(user: AuthenticatedUser, consultationId: string): Promise<ConsultationRoomSession> {
    await this.consultationForParticipant(user, consultationId);
    const session = await this.prisma.consultationRoomSession.findUnique({ where: { consultationId } });
    if (!session) {
      throw new NotFoundException({ message: 'Room session not found — call room/token first.', code: ApiErrorCode.NOT_FOUND });
    }
    return session;
  }

  private async consultationForParticipant(user: AuthenticatedUser, consultationId: string): Promise<void> {
    const consultation = await this.prisma.consultation.findUnique({ where: { id: consultationId } });
    if (!consultation) {
      throw new NotFoundException({ message: 'Consultation not found.', code: ApiErrorCode.NOT_FOUND });
    }
    const isClient = consultation.clientUserId === user.id;
    const isLawyer =
      user.role === 'lawyer' &&
      (await this.prisma.lawyerProfile.findUnique({ where: { userId: user.id } }))?.id === consultation.lawyerProfileId;
    if (!isClient && !isLawyer) {
      throw new ForbiddenException({ message: 'You are not a participant in this consultation.', code: ApiErrorCode.FORBIDDEN });
    }
    if (consultation.status !== 'confirmed') {
      throw new BadRequestException({
        message: `Consultation must be confirmed to open its room (current status: "${consultation.status}").`,
        code: ApiErrorCode.BAD_REQUEST,
      });
    }
  }

  private assertTransition(from: ConsultationRoomState, action: keyof typeof ALLOWED_FROM): void {
    if (!ALLOWED_FROM[action].includes(from)) {
      throw new BadRequestException({
        message: `Cannot ${action} a room session in state "${from}".`,
        code: ApiErrorCode.BAD_REQUEST,
      });
    }
  }

  private hash(raw: string): string {
    return createHash('sha256').update(raw).digest('hex');
  }

  private unauthorizedToken(): UnauthorizedException {
    return new UnauthorizedException({ message: 'Invalid or expired room token.', code: ApiErrorCode.UNAUTHORIZED });
  }
}
