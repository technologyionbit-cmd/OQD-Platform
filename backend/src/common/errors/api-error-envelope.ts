/**
 * Success/error envelope shapes, per docs/backend/05-api-design.md §4.
 * The backend commits to exactly this shape since the frontend's
 * ApiErrorMapper already defensively probes for it.
 */
export interface ApiSuccessEnvelope<T> {
  data: T;
}

export interface ApiPaginatedEnvelope<T> {
  data: T[];
  meta: {
    nextCursor: string | null;
    hasMore: boolean;
  };
}

export interface ApiErrorBody {
  message: string;
  code: string;
  errors?: Record<string, string[]>;
}

export interface ApiErrorEnvelope {
  error: ApiErrorBody;
}
