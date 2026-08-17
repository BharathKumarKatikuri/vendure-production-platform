import { createServer } from 'node:http';
import { metricsRegistry } from './plugins/metrics/metrics.registry';

export function startWorkerMetricsServer() {
    const port = Number(process.env.WORKER_METRICS_PORT ?? 9464);

    const server = createServer(async (request, response) => {
       
        if (request.method === 'GET' && request.url === '/metrics') {
	    const metrics = await metricsRegistry.metrics();

	    response.writeHead(200, {
	        'Content-Type': metricsRegistry.contentType,
		'Cache-Control': 'no-store',
	    });

	    response.end(metrics);
	    return;

	 }

	 response.writeHead(404);
	 response.end('Not Found');
     });

     server.listen(port, '0.0.0.0', () => {
         console.log(`Worker metrics server listening on port ${port}`);
     });
}
