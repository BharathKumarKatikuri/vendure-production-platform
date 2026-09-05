import {
    dummyPaymentHandler,
    DefaultJobQueuePlugin,
    DefaultSchedulerPlugin,
    DefaultSearchPlugin,
    VendureConfig,
} from '@vendure/core';
import { defaultEmailHandlers, EmailPlugin, FileBasedTemplateLoader } from '@vendure/email-plugin';
import { AssetServerPlugin, configureS3AssetStorage } from '@vendure/asset-server-plugin';
import { fromContainerMetadata } from '@aws-sdk/credential-providers';
import { DashboardPlugin } from '@vendure/dashboard/plugin';
import { GraphiqlPlugin } from '@vendure/graphiql-plugin';
import 'dotenv/config';
import path from 'path';
import { HealthPlugin } from './plugins/health/health.plugin';
import { MetricsPlugin } from './plugins/metrics/metrics.plugin';
import { SESv2Client, SendEmailCommand } from '@aws-sdk/client-sesv2';
import { StripePlugin } from '@vendure-community/payments-plugin/package/stripe';

const IS_DEV = process.env.APP_ENV === 'dev';
const IS_PROD = process.env.APP_ENV === 'production';
const serverPort = +process.env.PORT || 3000;

const s3AssetBucketName = process.env.S3_ASSET_BUCKET_NAME;
const awsRegion = process.env.AWS_REGION;

const emailFromAddress = process.env.EMAIL_FROM_ADDRESS;
const storefrontUrl = process.env.STOREFRONT_URL;


if (IS_PROD) {
    if (!s3AssetBucketName) {
        throw new Error('S3_ASSET_BUCKET_NAME is required in production');
    }

    if (!awsRegion) {
        throw new Error('AWS_REGION is required in production');
    }

    if (!emailFromAddress) {
        throw new Error('EMAIL_FROM_ADDRESS is required in production');
    }

    if (!storefrontUrl) {
        throw new Error('STOREFRONT_URL is required in production');
    }
}

export const config: VendureConfig = {
    apiOptions: {
        port: serverPort,
        adminApiPath: 'admin-api',
        shopApiPath: 'shop-api',
        trustProxy: IS_DEV ? false : 1,
        // The following options are useful in development mode,
        // but are best turned off for production for security
        // reasons.
        ...(IS_DEV ? {
            adminApiDebug: true,
            shopApiDebug: true,
        } : {}),
    },
    authOptions: {
        tokenMethod: ['bearer', 'cookie'],
        superadminCredentials: {
            identifier: process.env.SUPERADMIN_USERNAME,
            password: process.env.SUPERADMIN_PASSWORD,
        },
        cookieOptions: {
          secret: process.env.COOKIE_SECRET,
        },
    },
    dbConnectionOptions: {
        type: 'postgres',
        // See the README.md "Migrations" section for an explanation of
        // the `synchronize` and `migrations` options.
        synchronize: false,
        migrations: [path.join(__dirname, './migrations/*.+(js|ts)')],
        logging: false,
        database: process.env.DB_NAME,
        schema: process.env.DB_SCHEMA,
        host: process.env.DB_HOST,
        port: +process.env.DB_PORT,
        username: process.env.DB_USERNAME,
        password: process.env.DB_PASSWORD,
        ssl: IS_PROD ? { rejectUnauthorized: true } : false,
    },
    paymentOptions: {
        paymentMethodHandlers: [dummyPaymentHandler],
    },
    // When adding or altering custom field definitions, the database will
    // need to be updated. See the "Migrations" section in README.md.
    customFields: {},
    plugins: [
	HealthPlugin,
	MetricsPlugin,
        GraphiqlPlugin.init(),
        AssetServerPlugin.init({
            route: 'assets',
            assetUploadDir: path.join(__dirname, '../static/assets'),


            storageStrategyFactory: IS_PROD
                ? configureS3AssetStorage({
                    bucket: s3AssetBucketName!,
                    credentials: fromContainerMetadata(),
                    nativeS3Configuration: {
                        region: awsRegion,
                    },
                })
                : undefined,
         }),

	 StripePlugin.init({
             storeCustomersInStripe: false,
         }),


     DefaultSchedulerPlugin.init(),
     DefaultJobQueuePlugin.init({ useDatabaseForBuffer: true }),
     DefaultSearchPlugin.init({ bufferUpdates: false, indexStockStatus: true }),
        ...(IS_DEV
    ? [

       EmailPlugin.init({
            devMode: true,
            outputPath: path.join(__dirname, '../static/email/test-emails'),
            route: 'mailbox',
            handlers: defaultEmailHandlers,
            templateLoader: new FileBasedTemplateLoader(
                path.join(__dirname, '../static/email/templates')
	    ),
            globalTemplateVars: {
                // The following variables will change depending on your storefront implementation.
                // Here we are assuming a storefront running at http://localhost:8080.
                fromAddress: '"example" <noreply@example.com>',
                verifyEmailAddressUrl: 'http://localhost:3001/verify',
                passwordResetUrl: 'http://localhost:3001/reset-password',
                changeEmailAddressUrl: 'http://localhost:3001/account/verify-email'
            },
        }),

      ]

     :[

        EmailPlugin.init({
            handlers: defaultEmailHandlers,

            templateLoader: new FileBasedTemplateLoader(
                path.join(__dirname, '../static/email/templates')
            ),

            transport: {
                type: 'ses',
                SES: {
                    sesClient: new SESv2Client({
                        region: awsRegion!,
                    }),

                        SendEmailCommand,
                },
            },

            globalTemplateVars: {
                fromAddress: emailFromAddress!,
                verifyEmailAddressUrl: `${storefrontUrl}/verify`,
                passwordResetUrl: `${storefrontUrl}/reset-password`,
                changeEmailAddressUrl:
                    `${storefrontUrl}/account/verify-email`,
            },
        }),
    ]),


       DashboardPlugin.init({
            route: 'dashboard',
            appDir: IS_DEV
                ? path.join(__dirname, '../dist/dashboard')
                : path.join(__dirname, 'dashboard'),
        }),
     ],
};
