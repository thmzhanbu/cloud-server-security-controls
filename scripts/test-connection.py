"""Print a machine-readable connectivity result; expected outcome is explicit."""
import argparse
import json
import socket
from datetime import datetime, timezone

p = argparse.ArgumentParser()
p.add_argument("host")
p.add_argument("--expect", choices=("allowed", "blocked"), required=True)
a = p.parse_args()
try:
    with socket.create_connection((a.host, 5432), timeout=5) as s:
        banner = s.recv(256).decode().strip()
    outcome = "allowed"
    detail = banner
except (TimeoutError, socket.timeout):
    outcome = "blocked"
    detail = "Connection timed out; correlate with listener health and destination policy."
except OSError as e:
    outcome = "error"
    detail = str(e)
passed = outcome == a.expect
print(json.dumps({"utc": datetime.now(timezone.utc).isoformat(), "destination": a.host,
                  "port": 5432, "expected": a.expect, "observed": outcome,
                  "passed": passed, "detail": detail}))
raise SystemExit(0 if passed else 1)
