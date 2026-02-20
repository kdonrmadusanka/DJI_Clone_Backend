import { Test, TestingModule } from '@nestjs/testing';
import { PrismaService } from '../src/prisma/prisma.service';
import { INestApplication } from '@nestjs/common';
import { extendWithLogging } from '../src/lib/prisma/middlewares/logging/logging';

jest.mock('../src/lib/prisma/middlewares/logging/logging');

describe('PrismaService (e2e)', () => {
  let service: PrismaService;
  let appMock: Partial<INestApplication>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PrismaService],
    }).compile();

    service = module.get<PrismaService>(PrismaService);

    appMock = {
      close: jest.fn().mockResolvedValue(undefined),
    };
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('onModuleInit', () => {
    it('should extend Prisma with logging and connect', async () => {
      const mockConnect = jest
        .spyOn(service, '$connect')
        .mockResolvedValue(undefined);
      (extendWithLogging as jest.Mock).mockReturnValue(service);

      await service.onModuleInit();

      expect(extendWithLogging).toHaveBeenCalledWith(service);
      expect(mockConnect).toHaveBeenCalled();
    });

    it('should throw error if $connect fails', async () => {
      const error = new Error('Connection failed');
      jest.spyOn(service, '$connect').mockRejectedValueOnce(error);
      (extendWithLogging as jest.Mock).mockReturnValue(service);

      await expect(service.onModuleInit()).rejects.toThrow('Connection failed');
    });
  });

  describe('enableShutdownHooks', () => {
    it('should register SIGINT and SIGTERM hooks', () => {
      const listeners: Array<(...args: any[]) => void> = [];

      const processOnSpy = jest
        .spyOn(process, 'on')
        .mockImplementation(
          (event: string | symbol, listener: (...args: any[]) => void) => {
            listeners.push(listener);
            return process;
          },
        );

      service.enableShutdownHooks(appMock as INestApplication);

      listeners.forEach((listener) => {
        void listener();
      });

      expect(appMock.close).toHaveBeenCalledTimes(2);

      processOnSpy.mockRestore();
    });
  });
});
