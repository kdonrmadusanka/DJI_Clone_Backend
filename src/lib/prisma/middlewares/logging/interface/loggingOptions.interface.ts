import { LogLevel } from '../types/logLevel.type';

export interface LoggingOptions {
  logLevel?: LogLevel;
  logSlowQueries?: number; // ms
  logQueryPayload?: boolean;
  sensitiveFields?: string[]; // e.g. ['password', 'token']
}
