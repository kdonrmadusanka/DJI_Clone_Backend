import { INestApplication, Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { extendWithLogging } from '../lib/prisma/middlewares/logging/logging';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit {
  constructor() {
    super();
  }
  async onModuleInit() {
    try {
      const clientWithLogging = extendWithLogging(this);

      Object.assign(this, clientWithLogging);

      await this.$connect();
      console.log('[PrismaService] Connected to database with logging');
    } catch (error) {
      console.error('[PrismaService] Prisma initialization failed', error);
      throw error;
    }
  }

  enableShutdownHooks(app: INestApplication) {
    process.on('SIGINT', () => {
      app.close().catch((err) => console.error(err));
    });

    process.on('SIGTERM', () => {
      app.close().catch((err) => console.error(err));
    });
  }
}
