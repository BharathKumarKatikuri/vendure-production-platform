import { bootstrap, runMigrations } from "@vendure/core";
import { config } from "./vendure-config";

async function main() {
  try {
    await runMigrations(config);

    if (process.exitCode && process.exitCode !== 0) {
      throw new Error("Database migration failed");
    }

    await bootstrap(config);
  } catch (err) {
    console.error(err);
    process.exitCode = 1;
  }
}

void main();
