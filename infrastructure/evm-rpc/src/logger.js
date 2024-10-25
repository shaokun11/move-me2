// logger.mjs
import { createLogger as winstonCreateLogger, format, transports } from 'winston';

export const createLogger = moduleName => {
    return winstonCreateLogger({
        level: process.env.LOG_LEVEL || 'info',
        format: format.combine(
            format.splat(),
            format.label({ label: moduleName }),
            // format.timestamp(),
            format.printf(({ timestamp, level, message, label }) => {
                // return `${timestamp} [${label}] ${level}: ${message}`;
                return `[${label}] ${level}: ${message}`;
            }),
        ),
        transports: [new transports.Console()],
    });
};

const logger = createLogger('default');
export default logger;
