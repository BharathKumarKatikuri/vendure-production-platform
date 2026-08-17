import {
    CallHandler,
    ExecutionContext,
    HttpException,
    Injectable,
    NestInterceptor,
} from '@nestjs/common';

import type { Request, Response } from 'express';

import {
    catchError,
    finalize,
    Observable,
    throwError,
} from 'rxjs';

import {
    httpRequestsTotal,
    httpRequestDurationSeconds,
} from './metrics.registry';

@Injectable()
export class MetricsInterceptor implements NestInterceptor {
    
    intercept(
        context: ExecutionContext,
	next: CallHandler,
     ): Observable<unknown> {
	    if (context.getType() !== 'http') {
        return next.handle();
    }
         const request = context.switchToHttp().getRequest<Request>();
	 const response = context.switchToHttp().getResponse<Response>();

	 // Prometheus scraping /metrics should not count as application traffic.
	 if (request.path === '/metrics') {
	     return next.handle();
         }

	 const method = request.method;
	 const route = request.path;

	 const endTimer = httpRequestDurationSeconds.startTimer();

	 let errorStatusCode: number | undefined;

	 return next.handle().pipe(
             
	     catchError((error) => {
                 errorStatusCode = 
	             error instanceof HttpException
		         ? error.getStatus()
			 : 500;

		 return throwError(() => error);
	      }),

	      finalize(() => {
	          const statusCode = 
	              errorStatusCode ?? response.statusCode;

		  const labels = {
	              method,
		      route,
		      status_code: statusCode.toString(),
		   };

		   httpRequestsTotal.inc(labels);

		   endTimer(labels);

	      }),

	  );
      }
}

