import { VendurePlugin } from '@vendure/core';
import { APP_INTERCEPTOR } from '@nestjs/core';

import { MetricsController } from './metrics.controller';
import { MetricsInterceptor } from './metrics.interceptor';

@VendurePlugin({
    controllers: [MetricsController],

    providers: [
        {
            provide: APP_INTERCEPTOR,
	    useClass: MetricsInterceptor,
	},
    ],
})

export class MetricsPlugin {}


