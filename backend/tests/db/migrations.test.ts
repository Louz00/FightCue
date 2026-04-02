import test from "node:test";
import assert from "node:assert/strict";

import { newDb } from "pg-mem";

import { getSchemaMigrationStatus, runSchemaMigrations } from "../../src/db/migrations.js";

test("runSchemaMigrations tracks applied schema files exactly once", async () => {
  const db = newDb();
  const { Pool } = db.adapters.createPg();
  const pool = new Pool();

  try {
    const firstStatus = await runSchemaMigrations(pool);
    assert.equal(firstStatus.totalCount, 2);
    assert.equal(firstStatus.appliedCount, 2);
    assert.equal(firstStatus.pendingCount, 0);
    assert.equal(firstStatus.latestAppliedMigration, "002_user_push_devices.sql");

    const secondStatus = await runSchemaMigrations(pool);
    assert.equal(secondStatus.totalCount, 2);
    assert.equal(secondStatus.appliedCount, 2);
    assert.equal(secondStatus.pendingCount, 0);

    const rows = await pool.query<{ migration_name: string }>(
      `SELECT migration_name
         FROM schema_migrations
        ORDER BY migration_name ASC`,
    );
    assert.deepEqual(
      rows.rows.map((row) => row.migration_name),
      ["001_user_state.sql", "002_user_push_devices.sql"],
    );
  } finally {
    await pool.end();
  }
});

test("getSchemaMigrationStatus reports pending migrations before the runner executes", async () => {
  const db = newDb();
  const { Pool } = db.adapters.createPg();
  const pool = new Pool();

  try {
    const status = await getSchemaMigrationStatus(pool);
    assert.equal(status.totalCount, 2);
    assert.equal(status.appliedCount, 0);
    assert.equal(status.pendingCount, 2);
    assert.equal(status.latestAppliedMigration, undefined);
  } finally {
    await pool.end();
  }
});
