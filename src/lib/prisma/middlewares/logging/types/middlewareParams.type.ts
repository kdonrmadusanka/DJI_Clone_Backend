import { PrismaAction } from './prismaAction.type';
import { SupportedModels } from './supportModel.types';

export type MiddlewareParams = {
  model?: SupportedModels; // model name
  action: PrismaAction; // the Prisma action being executed
  args?: {
    where?: Record<string, unknown>;
    data?: Record<string, unknown>;
    [key: string]: any;
  };
  dataPath?: string[]; // optional for Prisma internal usage
  runInTransaction?: boolean; // optional
};
