import { 
    Registry, 
    collectDefaultMetrics,
    Counter,
    Histogram,
} from 'prom-client';

export const metricsRegistry = new Registry();

collectDefaultMetrics({
    register: metricsRegistry,
});

export const httpRequestsTotal = new Counter({
    name: 'vendure_http_requests_total',
    help: 'Total number of HTTP requests processed by Vendure',
    labelNames: ['method', 'route', 'status_code'],
    registers: [metricsRegistry],
});

export const httpRequestDurationSeconds = new Histogram({
    name: 'vendure_http_request_duration_seconds',
    help: 'Duration of HTTP requests processed by Vendure in seconds',
    labelNames: ['method', 'route', 'status_code'],
    registers: [metricsRegistry],
});




