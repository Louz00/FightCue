import dotenv from "dotenv";
import { Pool } from "pg";

import { runSchemaMigrations } from "./migrations.js";

dotenv.config();

const connectionString = process.env.DATABASE_URL ?? process.env.FIGHTCUE_DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL or FIGHTCUE_DATABASE_URL is required to run migrations");
}

const pool = new Pool({ connectionString });

try {
  await runSchemaMigrations(pool);
  console.log("FightCue schema migrations completed.");
} finally {
  await pool.end();
}
