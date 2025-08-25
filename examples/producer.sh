#!/usr/bin/env bash
set -euo pipefail
: "${DATA_DIR:=/data}"
: "${SHM_OUT:=/dev/shm/outbox}"
: "${EXPORT_HTTP:=0}"

mkdir -p "$DATA_DIR" "$SHM_OUT"

# produce a test file every minute
( while true; do echo "$(date) hello from producer" >> "$DATA_DIR/app.log"; sleep 60; done ) &

# if SHM is available, periodically copy a snapshot to SHM for backup service
( while true; do
    mkdir -p "$SHM_OUT"
    tar -C "$DATA_DIR" -cf "$SHM_OUT/snapshot.tar" .
    sleep 120
  done ) &

# optional: simple HTTP export on :9000 for the non-SHM SDL
if [[ "$EXPORT_HTTP" = "1" ]]; then
  while true; do
    # serve tarball on demand
    { printf "HTTP/1.1 200 OK\r\nContent-Type: application/x-tar\r\n\r\n";
      tar -C "$DATA_DIR" -cf - .; } | nc -l -p 9000 -q 1
  done
else
  # keep container alive
  tail -f /dev/null
fi
