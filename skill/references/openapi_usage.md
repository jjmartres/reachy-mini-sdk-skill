# Using the OpenAPI Spec (v1.8.0)

The daemon serves a live OpenAPI 3.1.0 document. It is the single source of truth for
the REST surface — always prefer it over hand-written docs when they disagree.

- Interactive docs (Swagger UI): `http://<robot>:8000/docs`
- Raw spec: `http://<robot>:8000/openapi.json`
- A snapshot is bundled here as `openapi_schema.json` (85 paths as of SDK v1.8.0).

## Refresh the bundled snapshot

```bash
curl -s http://localhost:8000/openapi.json -o openapi_schema.json
```

If endpoints or schemas drift from this skill's prose, re-pull the spec and regenerate
`daemon_api.md` from it — the prose is derived, the spec is authoritative.

## Generate typed clients

```bash
# Python (openapi-generator)
openapi-generator-cli generate -i openapi_schema.json -g python -o client_py/

# TypeScript types only
openapi-typescript openapi_schema.json -o reachy_api.ts

# Go / Rust / Java / etc. — swap the -g target (50+ generators)
openapi-generator-cli generate -i openapi_schema.json -g rust -o client_rs/
```

## Quick inspection without a generator

```bash
# List every path + method
python3 - <<'PY'
import json
d = json.load(open("openapi_schema.json"))
for p in sorted(d["paths"]):
    for m, op in d["paths"][p].items():
        if m in ("get","post","put","delete","patch"):
            print(f"{m.upper():6} {p}  - {op.get('summary','')}")
PY

# Dump one request-body schema (e.g. the move payload)
python3 -c "import json;print(json.dumps(json.load(open('openapi_schema.json'))['components']['schemas']['GotoModelRequest'],indent=2))"
```

## Minimal direct calls (no client needed)

```python
import requests
B = "http://localhost:8000"

# Move the head: x,y,z in meters, roll/pitch/yaw in radians
requests.post(f"{B}/api/move/goto", json={
    "head_pose": {"z": 0.01, "yaw": 0.35},
    "antennas": [0.5, -0.5],
    "body_yaw": 0.2,
    "duration": 1.5,
    "interpolation": "minjerk",   # linear | minjerk | ease_in_out | cartoon
})

# Read full state
print(requests.get(f"{B}/api/state/full").json())

# Set motor mode (mode is a PATH segment, not a JSON body)
requests.post(f"{B}/api/motors/set_mode/gravity_compensation")
```

## Notes

- The daemon owns the hardware. Only one app/session holds the robot lock at a time;
  check `GET /api/daemon/robot-app-lock-status` (`free` | `local_app` | `remote_session`)
  before driving it from a script, and stop the current app with
  `POST /api/apps/stop-current-app` if it crashed and is holding the slot.
- `GET /api/state/full` includes `doa` (direction-of-arrival) on v1.8.0.
