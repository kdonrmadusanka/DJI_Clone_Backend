import fs from 'fs';
import path from 'path';
import { Prisma } from '@prisma/client';
import { LogEntry } from './types/log-entity.type';

// ────────────────────────────────────────────────
//  Config
// ────────────────────────────────────────────────
const SOFT_DELETE_MODELS = new Set([
  'Category',
  'ProductSeries',
  'Product',
] as const);

const LOG_FILE_PATH = path.join(process.cwd(), 'logs', 'prisma-actions.log');

// Ensure log directory exists
if (!fs.existsSync(path.dirname(LOG_FILE_PATH))) {
  fs.mkdirSync(path.dirname(LOG_FILE_PATH), { recursive: true });
}

// ────────────────────────────────────────────────
//  Helpers
// ────────────────────────────────────────────────
function shouldSoftDelete(model: string | undefined): boolean {
  return !!model && SOFT_DELETE_MODELS.has(model as any);
}

function isSoftDeleteOperation(operation: string): boolean {
  return ['delete', 'deleteMany'].includes(operation);
}

function isReadOperation(operation: string): boolean {
  return ['findUnique', 'findFirst', 'findMany', 'count', 'aggregate'].includes(
    operation,
  );
}

function appendLog(entry: LogEntry) {
  const line = `${entry.timestamp} | ${entry.action.padEnd(12)} | ${entry.model.padEnd(18)} | ${JSON.stringify(entry.args ?? {})}\n`;
  fs.appendFile(LOG_FILE_PATH, line, (err) => {
    if (err) console.error('Log write failed:', err);
  });
}

// ────────────────────────────────────────────────
//  Extension (replaces old middleware)
// ────────────────────────────────────────────────
export const softDeleteAndLogExtension = Prisma.defineExtension({
  name: 'softDeleteAndLog',

  query: {
    $allModels: {
      async $allOperations({ model, operation, args, query }) {
        const now = new Date().toISOString();

        // Prepare log entry (we log the original operation)
        const logEntry: LogEntry = {
          timestamp: now,
          action: operation,
          model: model ?? 'unknown',
          args: args ? '[filtered args]' : undefined, // safer than full object
        };

        // Make a shallow copy — we may modify it
        const modifiedArgs = { ...args };

        // ─── Soft Delete: convert delete → update deletedAt ───────────────────
        if (shouldSoftDelete(model) && isSoftDeleteOperation(operation)) {
          const updateData = { deletedAt: now };

          if (operation === 'delete') {
            logEntry.action = 'softDelete (update)';
            // Instead of mutating, we call update directly
            return query({
              ...modifiedArgs,
              data: updateData,
            });
          }

          if (operation === 'deleteMany') {
            logEntry.action = 'softDeleteMany (updateMany)';
            return query({
              ...modifiedArgs,
              data: updateData,
            });
          }
        }

        // ─── Hide soft-deleted records by default ────────────────────────────────
        if (shouldSoftDelete(model) && isReadOperation(operation)) {
          // We know these operations support 'where'
          const readArgs = modifiedArgs as { where?: Record<string, any> };

          if (!readArgs.where) {
            readArgs.where = {};
          }

          // Safe now — TS knows .where exists
          if (readArgs.where.deletedAt === undefined) {
            readArgs.where.deletedAt = null;
          }

          // Alternative stricter version (using AND) – uncomment if preferred:
          // modifiedArgs.where = {
          //   AND: [
          //     ...( (modifiedArgs.where as any).AND ?? [] ),
          //     { deletedAt: null },
          //   ],
          // };
        }

        // ─── Logging ─────────────────────────────────────────────────────────
        appendLog(logEntry);

        // Execute the (possibly modified) query
        return query(modifiedArgs);
      },
    },
  },
});
