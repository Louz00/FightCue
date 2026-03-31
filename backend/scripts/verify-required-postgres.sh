#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATABASE_URL_VALUE="${DATABASE_URL:-${FIGHTCUE_DATABASE_URL:-}}"

if [ -z "${DATABASE_URL_VALUE}" ]; then
  echo "DATABASE_URL or FIGHTCUE_DATABASE_URL is required."
  exit 1
fi

echo "Checking PostgreSQL availability..."
pg_isready -d "${DATABASE_URL_VALUE}"

echo "Running FightCue schema migrations..."
(cd "${ROOT_DIR}" && npm run migrate)

echo "FightCue PostgreSQL runtime path is ready for required-database mode."
