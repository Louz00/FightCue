import { readdir, readFile } from "node:fs/promises";
import path from "node:path";

import type { Pool } from "pg";

export async function runSchemaMigrations(pool: Pool): Promise<void> {
  const migrationsDir = path.resolve(process.cwd(), "migrations");
  const entries = await readdir(migrationsDir, { withFileTypes: true });
  const migrationFiles = entries
    .filter((entry) => entry.isFile() && entry.name.endsWith(".sql"))
    .map((entry) => entry.name)
    .sort((left, right) => left.localeCompare(right));

  for (const migrationFile of migrationFiles) {
    const sql = await readFile(path.join(migrationsDir, migrationFile), "utf8");
    await pool.query(sql);
  }
}

