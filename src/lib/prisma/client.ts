import { PrismaClient } from '@prisma/client';
import { softDeleteAndLogExtension } from './middleware/soft-delete-and-log'; // adjust path

// 1. Define a factory that creates the extended client
const createExtendedPrisma = () => {
  const baseClient = new PrismaClient({
    log:
      process.env.NODE_ENV === 'development'
        ? [
            { level: 'query', emit: 'event' },
            { level: 'info', emit: 'event' },
            { level: 'warn', emit: 'event' },
            { level: 'error', emit: 'event' },
          ]
        : [
            { level: 'warn', emit: 'event' },
            { level: 'error', emit: 'event' },
          ],
  });

  return baseClient.$extends(softDeleteAndLogExtension);
};

// 2. Infer the exact type of the extended client
type ExtendedPrismaClient = ReturnType<typeof createExtendedPrisma>;

// 3. Extend global with the correct extended type
declare global {
  var prisma: ExtendedPrismaClient | undefined;
}

// 4. Singleton logic using the factory
const prisma = globalThis.prisma ?? createExtendedPrisma();

if (process.env.NODE_ENV !== 'production') {
  globalThis.prisma = prisma;
}

export { prisma };
