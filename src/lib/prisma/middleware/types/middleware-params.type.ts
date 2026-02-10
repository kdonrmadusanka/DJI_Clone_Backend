import { Prisma } from '@prisma/client';

export type MiddlewareParams = {
  model?: Prisma.ModelName;
  action: Prisma.PrismaAction;
  args: Record<string, unknown>;
};
