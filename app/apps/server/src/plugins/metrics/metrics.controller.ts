import { Controller, Get, Res } from '@nestjs/common';
import type { Response } from 'express';
import { metricsRegistry } from './metrics.registry';

@Controller('metrics')
export class MetricsController {
	
    @Get()
    async metrics(
        @Res({ passthrough: true }) response: Response,
    ): Promise<string> {
        response.setHeader('Content-Type', metricsRegistry.contentType);
        return metricsRegistry.metrics();
    }
}
