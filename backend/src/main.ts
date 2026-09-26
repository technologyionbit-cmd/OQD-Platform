import 'reflect-metadata';
import { Logger, ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import type { NestExpressApplication } from '@nestjs/platform-express';
import helmet from 'helmet';
import { AppModule } from './app.module';
import { setupOpenApi } from './common/openapi/setup-openapi';
import { validationExceptionFactory } from './common/pipes/validation-exception-factory';
import type { AppConfig, CorsConfig } from './config/configuration';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  const configService = app.get(ConfigService);
  const appConfig = configService.get<AppConfig>('app')!;
  const corsConfig = configService.get<CorsConfig>('cors')!;

  // Behind a reverse proxy every request arrives from the proxy's address;
  // without this, rate limiting and session IPs would treat all users as
  // one client. Only the configured proxies' X-Forwarded-For is honored.
  if (appConfig.trustProxy !== false) {
    app.set('trust proxy', appConfig.trustProxy);
  }

  app.use(helmet());

  app.setGlobalPrefix('v1');

  if (appConfig.apiDocsEnabled) {
    setupOpenApi(app);
  }

  app.enableCors({
    // Production: explicit allow-list only, never a wildcard. Development:
    // fall back to allowing any origin only if none was configured, so a
    // fresh clone works out of the box against the Flutter web build.
    origin:
      appConfig.isProduction || corsConfig.origins.length > 0
        ? corsConfig.origins
        : true,
    credentials: true,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      exceptionFactory: validationExceptionFactory,
    }),
  );

  // Lets Nest's lifecycle hooks (PrismaService/RedisService onModuleDestroy)
  // run on SIGTERM/SIGINT instead of the process dying mid-connection.
  app.enableShutdownHooks();

  await app.listen(appConfig.port, appConfig.host);
  Logger.log(
    `Aqd backend listening on ${appConfig.host}:${appConfig.port} (${appConfig.nodeEnv})`,
    'Bootstrap',
  );
}

void bootstrap();
