import { Injectable } from '@nestjs/common';
import type { ReadStream } from 'node:fs';
import {
  conflict,
  notFound,
  validationFailed,
} from '../common/errors/api-exceptions';
import { NotificationsService } from '../notifications/notifications.service';
import { PrismaService } from '../prisma/prisma.service';
import { FileStorageService } from '../storage/file-storage.service';
import type { AuthenticatedUser } from '../auth/auth.types';
import { LawyersService } from './lawyers.service';
import {
  VERIFICATION_MAX_FILE_BYTES,
  VERIFICATION_MAX_FILES,
  cleanOriginalName,
  detectVerificationFileType,
} from './verification-files';

/** What multer hands over for one uploaded file (memory storage). */
export interface UploadedVerificationFile {
  originalname: string;
  size: number;
  buffer: Buffer;
}

const STORAGE_FOLDER = 'lawyer-verification';

/**
 * Lawyer verification: the lawyer sends documents (unverified/rejected ->
 * pending), an admin approves (pending -> verified) or rejects with a
 * reason (pending -> rejected). Each change is conditional on the status
 * the caller saw, so two admins, or a double tap, cannot both act.
 */
@Injectable()
export class LawyerVerificationService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: FileStorageService,
    private readonly notifications: NotificationsService,
    private readonly lawyers: LawyersService,
  ) {}

  async submit(user: AuthenticatedUser, files: UploadedVerificationFile[]) {
    const profile = await this.lawyers.profileForLawyer(user);
    if (
      profile.verificationStatus === 'pending' ||
      profile.verificationStatus === 'verified'
    ) {
      throw conflict(
        profile.verificationStatus === 'pending'
          ? 'Your documents are already under review.'
          : 'Your account is already verified.',
      );
    }

    const checked = this.checkFiles(files);
    const keys: string[] = [];
    try {
      for (const file of checked) {
        keys.push(
          await this.storage.save(
            STORAGE_FOLDER,
            file.type.extension,
            file.buffer,
          ),
        );
      }
      await this.prisma.$transaction(async (tx) => {
        const moved = await tx.lawyerProfile.updateMany({
          where: {
            id: profile.id,
            verificationStatus: profile.verificationStatus,
          },
          data: {
            verificationStatus: 'pending',
            verificationRejectionReason: null,
            verificationSubmittedAt: new Date(),
            verificationReviewedAt: null,
            verificationReviewedById: null,
          },
        });
        if (moved.count === 0)
          throw conflict(
            'The verification status just changed. Refresh and try again.',
          );
        await tx.lawyerVerificationDocument.createMany({
          data: checked.map((file, index) => ({
            lawyerProfileId: profile.id,
            storageKey: keys[index],
            originalName: file.originalName,
            mimeType: file.type.mimeType,
            sizeBytes: file.buffer.length,
          })),
        });
      });
    } catch (error) {
      await Promise.all(keys.map((key) => this.storage.remove(key)));
      throw error;
    }
    return this.lawyers.findMine(user);
  }

  /** Lawyers waiting for review, oldest submission first, with their files. */
  async listPending() {
    const rows = await this.prisma.lawyerProfile.findMany({
      where: { verificationStatus: 'pending' },
      orderBy: { verificationSubmittedAt: 'asc' },
      include: {
        user: { select: { email: true, phone: true } },
        verificationDocuments: { orderBy: { createdAt: 'desc' } },
      },
    });
    return rows.map((row) => ({
      lawyerProfileId: row.id,
      fullName: row.fullName,
      email: row.user.email,
      phone: row.user.phone,
      barLicenseNumber: row.barLicenseNumber,
      submittedAt: row.verificationSubmittedAt,
      documents: row.verificationDocuments.map((doc) => ({
        id: doc.id,
        originalName: doc.originalName,
        mimeType: doc.mimeType,
        sizeBytes: doc.sizeBytes,
        createdAt: doc.createdAt,
      })),
    }));
  }

  async openDocument(
    lawyerProfileId: string,
    documentId: string,
  ): Promise<{ stream: ReadStream; mimeType: string }> {
    const doc = await this.prisma.lawyerVerificationDocument.findFirst({
      where: { id: documentId, lawyerProfileId },
    });
    if (!doc) {
      throw notFound('Document not found.');
    }
    return {
      stream: await this.storage.open(doc.storageKey),
      mimeType: doc.mimeType,
    };
  }

  async approve(
    admin: AuthenticatedUser,
    lawyerProfileId: string,
  ): Promise<void> {
    await this.review(admin, lawyerProfileId, 'verified', null);
  }

  async reject(
    admin: AuthenticatedUser,
    lawyerProfileId: string,
    reason: string,
  ): Promise<void> {
    await this.review(admin, lawyerProfileId, 'rejected', reason);
  }

  private async review(
    admin: AuthenticatedUser,
    lawyerProfileId: string,
    to: 'verified' | 'rejected',
    reason: string | null,
  ): Promise<void> {
    const profile = await this.prisma.lawyerProfile.findUnique({
      where: { id: lawyerProfileId },
    });
    if (!profile) {
      throw notFound('Lawyer not found.');
    }
    await this.prisma.$transaction(async (tx) => {
      const moved = await tx.lawyerProfile.updateMany({
        where: { id: lawyerProfileId, verificationStatus: 'pending' },
        data: {
          verificationStatus: to,
          verificationRejectionReason: reason,
          verificationReviewedById: admin.id,
          verificationReviewedAt: new Date(),
        },
      });
      if (moved.count === 0)
        throw conflict(
          'The verification status just changed. Refresh and try again.',
        );
      await this.notifications.notify(tx, {
        userId: profile.userId,
        type:
          to === 'verified'
            ? 'lawyerVerificationApproved'
            : 'lawyerVerificationRejected',
        params: reason ? { reason } : {},
      });
    });
  }

  private checkFiles(files: UploadedVerificationFile[]) {
    const errors: string[] = [];
    if (files.length === 0) errors.push('Attach at least one document.');
    if (files.length > VERIFICATION_MAX_FILES)
      errors.push(`Attach at most ${VERIFICATION_MAX_FILES} documents.`);
    const checked = files.map((file) => {
      const type = detectVerificationFileType(file.buffer);
      if (!type)
        errors.push(
          `${cleanOriginalName(file.originalname)}: only JPEG, PNG or PDF files are accepted.`,
        );
      if (file.buffer.length > VERIFICATION_MAX_FILE_BYTES) {
        errors.push(
          `${cleanOriginalName(file.originalname)}: larger than 10 MB.`,
        );
      }
      return {
        type: type!,
        buffer: file.buffer,
        originalName: cleanOriginalName(file.originalname),
      };
    });
    if (errors.length > 0) {
      throw validationFailed(
        { documents: errors },
        'Some documents cannot be accepted.',
      );
    }
    return checked;
  }
}
