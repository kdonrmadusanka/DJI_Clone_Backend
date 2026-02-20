export type PrismaAction =
  | 'findUnique'
  | 'findFirst'
  | 'findMany'
  | 'count'
  | 'aggregate'
  | 'create'
  | 'createMany'
  | 'update'
  | 'updateMany'
  | 'delete'
  | 'deleteMany';
