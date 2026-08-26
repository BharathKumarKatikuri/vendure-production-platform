#!/usr/bin/env bash

IMAGE="${1:-vendure-production:security-test-12}"

TMP_DIR=$(mktemp -d)
REPORT="$TMP_DIR/trivy.json"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v trivy-cache:/root/.cache/trivy \
    -v "$TMP_DIR:/output" \
    aquasec/trivy:0.74.0 \
    image \
    --quiet \
    --scanners vuln \
    --severity HIGH,CRITICAL \
    --ignore-unfixed \
    --exit-code 1 \
    --format json \
    --output /output/trivy.json \
    "$IMAGE"

TRIVY_EXIT=$?

python3 - "$REPORT" "$TRIVY_EXIT" <<'PY'
import json
import sys

report_file = sys.argv[1]
trivy_exit = int(sys.argv[2])

with open(report_file) as f:
    data = json.load(f)

high = 0
critical = 0

for result in data.get("Results", []):
    for vuln in result.get("Vulnerabilities") or []:
        severity = vuln.get("Severity", "").upper()

        if severity == "HIGH":
            high += 1
        elif severity == "CRITICAL":
            critical += 1

print()
print("==============================")
print(" SECURITY GATE")
print("==============================")
print(f"HIGH:      {high}")
print(f"CRITICAL:  {critical}")

if trivy_exit == 0 and high == 0 and critical == 0:
    print("RESULT:    PASS ✅")
    print("==============================")
    sys.exit(0)
else:
    print("RESULT:    FAIL ❌")
    print("==============================")
    sys.exit(1)
PY
