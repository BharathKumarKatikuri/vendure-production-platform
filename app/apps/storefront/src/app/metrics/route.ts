import { connection } from 'next/server';
import { storefrontMetricsRegistry } from '../../lib/metrics';

export async function GET() {
    await connection();

    const metrics = await storefrontMetricsRegistry.metrics();

    return new Response(metrics, { 
        status: 200,
	headers: {
	    'Content-Type': storefrontMetricsRegistry.contentType,
	    'Cache-Control': 'no-store',
	}
    });
}


