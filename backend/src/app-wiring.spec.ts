import { Test } from '@nestjs/testing';

/**
 * Builds the whole dependency graph with a stand-in database. It exists
 * because a provider missing from a module's `providers` list compiles
 * fine and passes unit tests, then crashes the server on start with
 * "Nest can't resolve dependencies". No database is needed.
 */
describe('application wiring', () => {
  it('resolves every provider of every module', async () => {
    // The config module validates the environment when AppModule is
    // loaded, so the variables must exist before that import runs.
    process.env.NODE_ENV = 'test';
    process.env.DATABASE_URL ??= 'postgresql://x:y@localhost:5432/z';
    process.env.JWT_ACCESS_SECRET ??= 'a'.repeat(48);
    process.env.JWT_REFRESH_SECRET ??= 'b'.repeat(48);

    const { AppModule } = await import('./app.module');
    const { PrismaService } = await import('./prisma/prisma.service');

    const prismaStandIn = new Proxy(
      {},
      {
        get: (_target, prop) =>
          prop === 'then'
            ? undefined
            : new Proxy(() => Promise.resolve([]), {
                get: () => () => Promise.reject(new Error('no database')),
              }),
      },
    );

    const moduleRef = await Test.createTestingModule({ imports: [AppModule] })
      .overrideProvider(PrismaService)
      .useValue(prismaStandIn)
      .compile();

    await moduleRef.close();
  });
});
