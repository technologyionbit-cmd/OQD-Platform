import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { AppModule } from '../../src/app.module';
import { HttpExceptionFilter } from '../../src/common/filters/http-exception.filter';
import { validationExceptionFactory } from '../../src/common/pipes/validation-exception-factory';

/**
 * Builds a Nest application configured exactly like `src/main.ts` (global
 * prefix, validation pipe, error-envelope filter) for e2e specs. Requires
 * PostgreSQL reachable at DATABASE_URL.
 */
export async function createE2EApp(): Promise<INestApplication> {
  const moduleRef = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  const app = moduleRef.createNestApplication();
  app.setGlobalPrefix('v1');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      exceptionFactory: validationExceptionFactory,
    }),
  );
  app.useGlobalFilters(new HttpExceptionFilter());
  await app.init();
  return app;
}
