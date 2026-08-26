#!/usr/bin/env bash
set -eu

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

JMETER_HOME="${JMETER_HOME:-./apache-jmeter}"
JMETER_BIN="${JMETER_BIN:-$JMETER_HOME/bin/jmeter}"
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

mkdir -p "$RESULT_DIR"
rm -f "$JTL_FILE"
rm -rf "$REPORT_DIR"

"$JMETER_BIN" -n \
  -t jmeter/benchmark.jmx \
  -q "$CONFIG_FILE" \
  -l "$JTL_FILE" \
  -e -o "$REPORT_DIR" \
  "$@"
