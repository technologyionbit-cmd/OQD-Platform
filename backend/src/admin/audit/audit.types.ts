import type { Request } from 'express';

/** What a handler tells the audit interceptor about the change it made. */
export interface AuditNote {
  entityType?: string;
  entityId?: string;
  before?: unknown;
  after?: unknown;
  meta?: Record<string, unknown>;
}

export type AuditNoteFn = (note: AuditNote) => void;

/** Request fields the audit trail reads and writes. */
export type AuditedRequest = Request & {
  user?: { id: string };
  auditNote?: AuditNote;
};
