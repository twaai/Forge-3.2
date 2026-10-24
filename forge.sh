#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if ! command -v node >/dev/null 2>&1; then
  echo "[FORGE 3.2] Node.js 24.22.1 or newer is required: https://nodejs.org/" >&2
  exit 1
fi

# the embedded runtime carries undici too: 24.22.1 is the security release that
# brings it to 7.30.1, the CVE-2026-109869 fix
if ! node -e 'const [a,b,c]=process.versions.node.split(".").map(Number);process.exit(a>24||(a===24&&(b>22||(b===22&&c>=1)))?0:1)'; then
  echo "[FORGE 3.2] Node.js 24.22.1 or newer is required. Found: $(node -v)" >&2
  exit 1
fi

cd "$ROOT"

if [ ! -d node_modules ]; then
  echo "[FORGE 3.2] Installing Node dependencies..."
  npm install --no-fund --no-audit
fi

npm run build

exec node "$ROOT/dist/main.js" "$@"
