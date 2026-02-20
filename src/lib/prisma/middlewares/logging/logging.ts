import { PrismaClient } from '@prisma/client';
import { DEFAULT_OPTIONS } from './const/defaultOptions.const';
import { LoggingOptions } from './interface/loggingOptions.interface';
import { LogLevel } from './types/logLevel.type';

export function extendWithLogging(
  prisma: PrismaClient,
  userOptions: LoggingOptions = {},
) {
  const options = { ...DEFAULT_OPTIONS, ...userOptions };

  const shouldLog = (level: LogLevel): boolean => {
    const levels: Record<LogLevel, number> = {
      debug: 0,
      info: 1,
      warn: 2,
      error: 3,
    };
    return levels[level] >= levels[options.logLevel!];
  };

  const maskSensitiveData = (
    data: Record<string, unknown>,
    options: { sensitiveFields?: string[] },
  ): Record<string, unknown> => {
    if (!data || typeof data !== 'object') return data;

    const masked: Record<string, unknown> = { ...data };
    for (const field of options.sensitiveFields ?? []) {
      if (field in masked) masked[field] = '***';
    }
    return masked;
  };

  return prisma.$extends({
    query: {
      $allModels: {
        async $allOperations({ model, operation, args, query }) {
          const start = Date.now();

          if (
            operation === 'findFirst' &&
            typeof args === 'object' &&
            args !== null &&
            'where' in args &&
            typeof (args as { where?: { id?: string } }).where === 'object' &&
            (args as { where?: { id?: string } }).where?.id === 'health-check'
          ) {
            return query(args);
          }

          try {
            const result = await query(args);
            const duration = Date.now() - start;

            if (
              shouldLog('debug') ||
              (options.logSlowQueries && duration >= options.logSlowQueries)
            ) {
              const payload = options.logQueryPayload
                ? maskSensitiveData(args as Record<string, unknown>, options)
                : undefined;

              console.log(
                `[Prisma] ${model}.${operation} completed in ${duration}ms` +
                  (payload ? ` → ${JSON.stringify(payload, null, 2)}` : ''),
              );

              if (duration >= (options.logSlowQueries ?? 0)) {
                console.warn(
                  `[Prisma] Slow query: ${model}.${operation} (${duration}ms)`,
                );
              }
            }

            return result;
          } catch (error) {
            const duration = Date.now() - start;

            if (shouldLog('error')) {
              console.error(
                `[Prisma] ${model}.${operation} failed after ${duration}ms`,
                error instanceof Error ? error.stack : error,
              );
            }

            throw error;
          }
        },
      },
    },
  });
}
