import { MiddlewareParams } from './middlewareParams.type';

export type Middleware = <T>(
  params: MiddlewareParams,
  next: (params: MiddlewareParams) => Promise<T>,
) => Promise<T>;
