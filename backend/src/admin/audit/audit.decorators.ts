import {
  applyDecorators,
  createParamDecorator,
  ExecutionContext,
  SetMetadata,
} from '@nestjs/common';
import type { AuditedRequest, AuditNote, AuditNoteFn } from './audit.types';

export const AUDIT_ACTION = 'audit:action';
export const AUDIT_SKIP = 'audit:skip';
export const AUDIT_READ = 'audit:read';

/** Stable dotted name for the audit row, e.g. `user.suspend`. */
export const AuditAction = (action: string) =>
  SetMetadata(AUDIT_ACTION, action);

/** Opt a write out of auditing (only for writes with no side effects). */
export const AuditSkip = () => SetMetadata(AUDIT_SKIP, true);

/**
 * Injects `note(...)`: the handler calls it with the entity and its
 * before/after state, and the interceptor stores that in the audit row.
 * Calls merge, so a handler can note the entity first and the result later.
 */
export const AuditNoter = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): AuditNoteFn => {
    const request = ctx.switchToHttp().getRequest<AuditedRequest>();
    return (note: AuditNote) => {
      request.auditNote = {
        ...request.auditNote,
        ...note,
        meta: { ...request.auditNote?.meta, ...note.meta },
      };
    };
  },
);

/**
 * Audits a GET too. Reads are normally not recorded, but pulling personal
 * data out in bulk (CSV export) must leave a trace.
 */
export const AuditRead = (action: string) => applyDecorators(SetMetadata(AUDIT_ACTION, action), SetMetadata(AUDIT_READ, true));
