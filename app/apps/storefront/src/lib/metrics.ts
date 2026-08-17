import {
    Registry,
    collectDefaultMetrics,
} from 'prom-client';

export const storefrontMetricsRegistry = new Registry();

collectDefaultMetrics({
    register: storefrontMetricsRegistry,
});


