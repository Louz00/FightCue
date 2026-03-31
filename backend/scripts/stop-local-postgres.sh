#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${ROOT_DIR}/.local/postgres"

if [ ! -d "${DATA_DIR}" ]; then
  echo "No local FightCue PostgreSQL data directory found."
  exit 0
fi

pg_ctl -D "${DATA_DIR}" stop
