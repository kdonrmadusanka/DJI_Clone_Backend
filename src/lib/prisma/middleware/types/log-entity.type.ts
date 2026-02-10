export type LogEntry = {
  timestamp: string;
  action: string;
  model: string;
  args?: any;
  resultCount?: number;
  ip?: string;
};
