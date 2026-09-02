#!/usr/bin/env bash
set -euo pipefail

# KiroCrew binds loopback only (127.0.0.1:5476). Umbrel's app_proxy reaches this
# container over the Docker network, so we bridge 0.0.0.0:8117 -> 127.0.0.1:5476.

INTERNAL_PORT="${KIROCREW_INTERNAL_PORT:-5476}"
PUBLIC_PORT="${KIROCREW_PORT:-8117}"

echo "[start.sh] launching kirocrew gateway on 127.0.0.1:${INTERNAL_PORT}"
# --no-open: no browser inside a container.
kirocrew gateway --no-open --port "${INTERNAL_PORT}" &
KC_PID=$!

# Wait for the loopback listener to come up before bridging.
echo "[start.sh] waiting for kirocrew to bind 127.0.0.1:${INTERNAL_PORT} ..."
for i in $(seq 1 60); do
  if socat -T1 - TCP:127.0.0.1:"${INTERNAL_PORT}",connect-timeout=1 </dev/null >/dev/null 2>&1; then
    echo "[start.sh] kirocrew is up"
    break
  fi
  # If kirocrew died, exit so the container restarts and logs surface.
  if ! kill -0 "${KC_PID}" 2>/dev/null; then
    echo "[start.sh] kirocrew process exited early" >&2
    wait "${KC_PID}" || true
    exit 1
  fi
  sleep 2
done

echo "[start.sh] bridging 0.0.0.0:${PUBLIC_PORT} -> 127.0.0.1:${INTERNAL_PORT}"
socat TCP-LISTEN:"${PUBLIC_PORT}",fork,reuseaddr TCP:127.0.0.1:"${INTERNAL_PORT}" &
SOCAT_PID=$!

# If either process dies, take the container down so Umbrel restarts it.
wait -n "${KC_PID}" "${SOCAT_PID}"
echo "[start.sh] a child process exited; shutting down" >&2
kill "${KC_PID}" "${SOCAT_PID}" 2>/dev/null || true
exit 1
