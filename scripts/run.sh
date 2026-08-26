#!/usr/bin/env bash
set -eu

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ -n "${JMETER_BIN:-}" ]; then
  : # Use the explicit executable selected by the caller.
elif [ -n "${JMETER_HOME:-}" ]; then
  JMETER_BIN="$JMETER_HOME/bin/jmeter"
elif command -v jmeter >/dev/null 2>&1; then
  JMETER_BIN="$(command -v jmeter)"
else
  JMETER_BIN="$ROOT_DIR/apache-jmeter/bin/jmeter"
fi
CONFIG_FILE="${1:-config/benchmark.properties}"
RESULT_DIR="${RESULT_DIR:-results}"
JTL_FILE="${JTL_FILE:-$RESULT_DIR/result.jtl}"
REPORT_DIR="${REPORT_DIR:-$RESULT_DIR/report}"
shift || true

if [ ! -f "$CONFIG_FILE" ]; then
  printf 'Configuration file not found: %s\n' "$CONFIG_FILE" >&2
  printf 'Copy config/benchmark.properties.example first.\n' >&2
  exit 1
fi

if [ ! -x "$JMETER_BIN" ]; then
  printf 'JMeter executable not found or not executable: %s\n' "$JMETER_BIN" >&2
  exit 1
fi

printf 'Using JMeter: %s\n' "$JMETER_BIN"

mkdir -p "$RESULT_DIR"
rm -f "$JTL_FILE"
rm -rf "$REPORT_DIR"

"$JMETER_BIN" -n \
  -t jmeter/benchmark.jmx \
  -q "$CONFIG_FILE" \
  -l "$JTL_FILE" \
  -e -o "$REPORT_DIR" \
  "$@"
