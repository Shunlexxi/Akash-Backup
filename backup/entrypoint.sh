#!/usr/bin/env bash
set -euo pipefail

: "${RESTIC_REPOSITORY:?missing}"
: "${RESTIC_PASSWORD:?missing}"
: "${RESTIC_BACKUP_PATH:=/tmp/ingest}"
: "${RESTIC_CRON:=0 * * * *}"
: "${RESTIC_FORGET_ARGS:=--keep-daily 7 --keep-weekly 4 --prune}"
: "${HEALTHCHECK_PORT:=8081}"

mkdir -p "$RESTIC_BACKUP_PATH"

# Optional: pull a tar stream from producer if PRODUCER_URL is set
if [[ -n "${PRODUCER_URL:-}" ]]; then
  echo "Boot: pulling initial export from ${PRODUCER_URL} ..."
  curl -fsSL "$PRODUCER_URL" | tar -x -C "$RESTIC_BACKUP_PATH" || true
fi

# Initialize repo if needed
restic snapshots >/dev/null 2>&1 || restic init

# Healthcheck server (very simple)
(
  while true; do { echo -e "HTTP/1.1 200 OK\r\n\r\nOK"; } | nc -l -p "$HEALTHCHECK_PORT" -q 1 >/dev/null 2>&1 || true; done
) &

# Cron job: backup + prune
echo "$RESTIC_CRON /bin/bash -lc 'restic backup --one-file-system --exclude-file=/app/include-exclude.txt \"$RESTIC_BACKUP_PATH\" && restic forget $RESTIC_FORGET_ARGS && restic check --read-data-subset=1%'" > /etc/crontabs/root

crond -f -L /dev/stdout
