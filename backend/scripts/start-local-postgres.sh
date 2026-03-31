#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${ROOT_DIR}/.local/postgres"
RUN_DIR="${ROOT_DIR}/.local/run"
LOG_FILE="${ROOT_DIR}/postgres.log"
PORT="${POSTGRES_PORT:-5432}"
DB_NAME="${POSTGRES_DB:-fightcue}"
DB_USER="${POSTGRES_USER:-postgres}"

mkdir -p "${RUN_DIR}"

if [ ! -d "${DATA_DIR}" ]; then
  initdb -D "${DATA_DIR}" --username="${DB_USER}" --auth=trust
fi

pg_ctl -D "${DATA_DIR}" -l "${LOG_FILE}" -o "-k ${RUN_DIR} -p ${PORT}" start

createdb -h "${RUN_DIR}" -p "${PORT}" -U "${DB_USER}" "${DB_NAME}" 2>/dev/null || true

cat <<EOF
FightCue local PostgreSQL is running.
Socket dir: ${RUN_DIR}
Port: ${PORT}
Database: ${DB_NAME}
User: ${DB_USER}

Example DATABASE_URL:
postgres://${DB_USER}@127.0.0.1:${PORT}/${DB_NAME}
EOF
