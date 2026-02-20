import { LoggingOptions } from '../interface/loggingOptions.interface';

export const DEFAULT_OPTIONS: LoggingOptions = {
  logLevel: 'info',
  logSlowQueries: 250,
  logQueryPayload: process.env.NODE_ENV === 'development',
  sensitiveFields: ['password', 'hashedPassword', 'token', 'refreshToken'],
};
