#!/usr/bin/env bash
# Build a staged copy, then swap it into /opt/strongr and restart systemd.
# A failed health check restores the previous good tree.
set -euo pipefail

src="${HOME}/strongr-src"
prev="${HOME}/strongr-prev"
live=/opt/strongr

cd "$src"
npm ci
npm run build

healthy() {
  node --input-type=module -e "const r = await fetch('http://127.0.0.1:3000/login'); if (!r.ok) process.exit(1)"
}

wait_healthy() {
  local _
  for _ in $(seq 1 20); do
    if healthy; then
      return 0
    fi
    sleep 1
  done
  return 1
}

sudo systemctl stop strongr
rsync -a --delete --exclude data "$src"/ "$live"/
sudo systemctl start strongr

if wait_healthy; then
  rm -rf "$prev"
  mkdir -p "$prev"
  rsync -a --delete "$src"/ "$prev"/
  exit 0
fi

echo "strongr did not answer on :3000 after restart" >&2
sudo systemctl status strongr --no-pager || true

if [ -d "$prev/build" ]; then
  echo "restoring previous release" >&2
  rsync -a --delete --exclude data "$prev"/ "$live"/
  sudo systemctl start strongr || true
fi

exit 1
