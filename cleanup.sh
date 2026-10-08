#!/usr/bin/env bash
# See AGENTS.md / README.md.
exec python3 "$(dirname "$0")/kit.py" cleanup "$@"
