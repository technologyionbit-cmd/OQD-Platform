import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import type {
  ApiErrorBody,
  ApiErrorEnvelope,
} from '../errors/api-error-envelope';

/** OpenAPI schema for {@link ApiErrorBody} — documentation only. */
export class ApiErrorBodyDto implements ApiErrorBody {
  @ApiProperty({ example: 'Session expired. Please sign in again.' })
  message!: string;

  @ApiProperty({
    example: 'UNAUTHORIZED',
    description: 'Stable machine-readable code (see ApiErrorCode).',
  })
  code!: string;

  @ApiPropertyOptional({
    description: 'Field-level validation messages, keyed by field name.',
    example: { email: ['email must be an email'] },
  })
  errors?: Record<string, string[]>;
}

/** OpenAPI schema for {@link ApiErrorEnvelope} — documentation only. */
export class ApiErrorResponseDto implements ApiErrorEnvelope {
  @ApiProperty({ type: ApiErrorBodyDto })
  error!: ApiErrorBodyDto;
}
