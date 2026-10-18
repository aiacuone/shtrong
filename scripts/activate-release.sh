#!/usr/bin/env bash
# Build a staged copy, then swap it into /opt/shtrong and restart systemd.
# A failed health check restores the previous good tree.
set -euo pipefail

src="${HOME}/shtrong-src"
prev="${HOME}/shtrong-prev"
live=/opt/shtrong

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

sudo systemctl stop shtrong
rsync -a --delete --exclude data "$src"/ "$live"/
sudo systemctl start shtrong

if wait_healthy; then
  rm -rf "$prev"
  mkdir -p "$prev"
  rsync -a --delete "$src"/ "$prev"/
  exit 0
fi

echo "shtrong did not answer on :3000 after restart" >&2
sudo systemctl status shtrong --no-pager || true

if [ -d "$prev/build" ]; then
  echo "restoring previous release" >&2
  rsync -a --delete --exclude data "$prev"/ "$live"/
  sudo systemctl start shtrong || true
fi

exit 1
