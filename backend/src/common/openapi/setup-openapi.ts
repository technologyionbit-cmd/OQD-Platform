import type { INestApplication } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

export const BEARER_AUTH = 'bearer';

/**
 * Serves the OpenAPI contract at `/v1/docs` (UI) and `/v1/docs-json`
 * (raw spec) — the single source of truth the Flutter data sources are
 * written against. Off in production unless API_DOCS_ENABLED=true.
 */
export function setupOpenApi(app: INestApplication): void {
  const config = new DocumentBuilder()
    .setTitle('Aqd API')
    .setDescription(
      'Every success body is `{ data: ... }`; every error body is ' +
        '`{ error: { message, code, errors? } }`.',
    )
    .setVersion('1')
    .addBearerAuth(
      { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
      BEARER_AUTH,
    )
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('v1/docs', app, document, {
    jsonDocumentUrl: 'v1/docs-json',
  });
}
