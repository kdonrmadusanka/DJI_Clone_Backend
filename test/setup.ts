import * as dotenv from 'dotenv';
import { join } from 'path';

dotenv.config({ path: join(__dirname, '../.env.test') });

console.log('DATABASE_URL from env:', process.env.DATABASE_URL);
