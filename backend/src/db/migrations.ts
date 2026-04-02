import { readdir, readFile } from "node:fs/promises";
import path from "node:path";

import type { Pool, PoolClient } from "pg";

import type { SchemaMigrationStatus } from "../store/user-state-store.types.js";

type Queryable = Pick<Pool, "query"> | Pick<PoolClient, "query">;

export async function runSchemaMigrations(pool: Pool): Promise<SchemaMigrationStatus> {
  await ensureSchemaMigrationsTable(pool);
  const migrationFiles = await listMigrationFiles();
  const appliedMigrations = await loadAppliedMigrationNames(pool);

  for (const migrationFile of migrationFiles) {
    if (appliedMigrations.has(migrationFile)) {
      continue;
    }

    const sql = await readFile(path.join(resolveMigrationsDir(), migrationFile), "utf8");
    const client = await pool.connect();

    try {
      await client.query("BEGIN");
      await client.query(sql);
      await client.query(
        `INSERT INTO schema_migrations (migration_name, applied_at)
         SELECT $1, NOW()
          WHERE NOT EXISTS (
            SELECT 1
              FROM schema_migrations
             WHERE migration_name = $1
          )`,
        [migrationFile],
      );
      await client.query("COMMIT");
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
  }

  return getSchemaMigrationStatus(pool);
}

export async function getSchemaMigrationStatus(
  pool: Queryable,
): Promise<SchemaMigrationStatus> {
  await ensureSchemaMigrationsTable(pool);
  const migrationFiles = await listMigrationFiles();
  const appliedRows = await pool.query<{
    migration_name: string;
    applied_at: string;
  }>(
    `SELECT migration_name, applied_at
       FROM schema_migrations
      ORDER BY applied_at ASC, migration_name ASC`,
  );
  const appliedMigrationNames = appliedRows.rows.map((row) => row.migration_name);

  return {
    totalCount: migrationFiles.length,
    appliedCount: appliedMigrationNames.length,
    pendingCount: Math.max(migrationFiles.length - appliedMigrationNames.length, 0),
    latestAppliedMigration:
      appliedMigrationNames.length > 0
        ? appliedMigrationNames[appliedMigrationNames.length - 1]
        : undefined,
  };
}

async function ensureSchemaMigrationsTable(pool: Queryable): Promise<void> {
  await pool.query(
    `CREATE TABLE IF NOT EXISTS schema_migrations (
       migration_name TEXT,
       applied_at TIMESTAMPTZ
     )`,
  );
}

async function listMigrationFiles(): Promise<string[]> {
  const migrationsDir = resolveMigrationsDir();
  const entries = await readdir(migrationsDir, { withFileTypes: true });
  return entries
    .filter((entry) => entry.isFile() && entry.name.endsWith(".sql"))
    .map((entry) => entry.name)
    .sort((left, right) => left.localeCompare(right));
}

async function loadAppliedMigrationNames(pool: Queryable): Promise<Set<string>> {
  const result = await pool.query<{ migration_name: string }>(
    `SELECT migration_name
       FROM schema_migrations`,
  );
  return new Set(result.rows.map((row) => row.migration_name));
}

function resolveMigrationsDir(): string {
  const migrationsDir = path.resolve(process.cwd(), "migrations");
  return migrationsDir;
}
