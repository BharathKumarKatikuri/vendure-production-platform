import { bootstrapWorker } from '@vendure/core';
import { config } from './vendure-config';
import { startWorkerMetricsServer } from './worker-metrics';

bootstrapWorker(config)
    .then(async worker => {
        startWorkerMetricsServer();
	await worker.startJobQueue();
    })

    .catch(err => {
        console.log(err);
    });
