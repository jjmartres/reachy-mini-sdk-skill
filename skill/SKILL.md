---
name: reachy-mini-sdk
description: Programming guide for Reachy Mini robot using Python SDK v1.8.0 and REST API. Use when controlling Reachy Mini robots, programming movements (head/antennas/body), accessing sensors (camera/microphone/IMU), recording motions, building AI applications, deploying to Hugging Face, or using the daemon REST API. Covers SDK patterns, coordinate systems, interpolation methods, app management, and OpenAPI client generation.
license: MIT (see LICENSE.txt)
---

# Reachy Mini SDK

Programming guide for Reachy Mini - an open-source desktop humanoid robot with 6-DOF head, expressive antennas, and AI integration.

## Hardware

- **Head**: 6-DOF Stewart platform (X,Y,Z + roll,pitch,yaw)
- **Antennas**: 2 servos
- **Body**: 360° yaw rotation
- **Sensors**: Camera, microphone, IMU (Wireless only)

**Daemon**: FastAPI on port 8000 (REST + WebSocket)

## Quick Start

### Installation

See `references/installation.md` for complete setup (uv/pip, platform-specific configs, permissions).

### Basic Connection

```python
from reachy_mini import ReachyMini

# Local
with ReachyMini() as mini:
    pass

# Remote (Wireless)
with ReachyMini(localhost_only=False) as mini:
    pass
```

## Movement

See `references/movement_control.md` for complete guide (450+ lines with all patterns).

### goto_target (Smooth Interpolation)

```python
from reachy_mini.utils import create_head_pose
import numpy as np

# create_head_pose returns a 4x4 numpy ndarray (not a HeadPose object)
mini.goto_target(
    head=create_head_pose(z=10, roll=15, degrees=True, mm=True),
    antennas=np.deg2rad([45, 45]),
    body_yaw=np.deg2rad(30),
    duration=2.0,
    method="minjerk"  # linear | minjerk | ease_in_out | cartoon
)
```

### set_target (Direct Control)

For high-frequency control (>30Hz):

```python
mini.set_target(
    head=create_head_pose(z=5, mm=True),
    antennas=[0.5, -0.5]
)
```

### Coordinates

- **Head**: Position in meters, orientation in radians
- **Antennas**: Radians (±1.5)
- **Body**: Radians (full 360°)

## Sensors

See `references/sensors.md` for camera, audio, IMU details.

```python
# Camera (BGR numpy array)
frame = mini.media.get_frame()

# Audio (16kHz stereo)
samples = mini.media.get_audio_sample()
mini.media.push_audio_sample(samples)  # Non-blocking

# IMU (Wireless only) - mini.imu is a property returning a dict, or None
data = mini.imu
if data is not None:
    accel, gyro, quat = data["accelerometer"], data["gyroscope"], data["quaternion"]
```

## Motion Recording

```python
mini.start_recording()
# Move robot (e.g. by hand in gravity_compensation, or via goto_target)
frames = mini.stop_recording()   # returns a list of timestamped joint frames
```

`stop_recording()` returns a list of frame dicts (there is no `Motion` class on v1.8.0).
Replay an authored move with `mini.play_move(move)` / `mini.async_play_move(move)`, or
play a saved dataset move over REST:
`POST /api/move/play/recorded-move-dataset/{dataset_name}/{move_name}`.

## REST API

See `references/daemon_api.md` for all 85 endpoints (v1.8.0).
See `references/openapi_usage.md` for client generation.

### Direct HTTP Control

```python
import requests

# Move via API (head_pose: x,y,z in meters; roll,pitch,yaw in radians)
requests.post("http://localhost:8000/api/move/goto", json={
    "head_pose": {"x": 0, "y": 0, "z": 0.01, "roll": 0, "pitch": 0, "yaw": 0},
    "antennas": [0.5, -0.5],
    "body_yaw": 0.2,
    "duration": 2.0,
    "interpolation": "minjerk"
})

# Get state
state = requests.get("http://localhost:8000/api/state/full").json()
```

### Generate Clients

See `references/openapi_schema.json` for OpenAPI v3.1.0 spec.

```bash
# Python
openapi-generator-cli generate -i openapi_schema.json -g python -o client/

# TypeScript
openapi-typescript openapi_schema.json -o types.ts

# Go, Rust, Java, etc. (50+ languages supported)
```

## App Management

```python
# Install app
requests.post("http://localhost:8000/api/apps/install", json={
    "name": "hand_tracker",
    "source": "hf_space",
    "space_id": "pollen-robotics/hand_tracker_v2"
})

# Start app
requests.post("http://localhost:8000/api/apps/start-app/hand_tracker")
```

## Motor Modes

The mode is a **path segment** (`/api/motors/set_mode/{mode}`), not a JSON body:

```python
# Compliant (manual movement)
requests.post("http://localhost:8000/api/motors/set_mode/disabled")

# Active control
requests.post("http://localhost:8000/api/motors/set_mode/enabled")

# Gravity compensation
requests.post("http://localhost:8000/api/motors/set_mode/gravity_compensation")

# Current mode
requests.get("http://localhost:8000/api/motors/status").json()  # {"mode": "..."}
```

SDK equivalents: `mini.enable_motors()`, `mini.disable_motors()`,
`mini.enable_gravity_compensation()`, `mini.disable_gravity_compensation()`.

## AI Integration

See `references/ai_integration.md` for LLM patterns, vision models, multimodal apps, and HuggingFace deployment.

### Example: Object Detection

```python
from transformers import pipeline

detector = pipeline("object-detection")
frame = mini.media.get_frame()
results = detector(frame)

# React to detections
for obj in results:
    if obj['label'] == 'person':
        mini.goto_target(antennas=np.deg2rad([45, 45]), duration=0.5)
```

## Common Patterns

### Greeting Sequence

```python
def greet():
    mini.goto_target(head=create_head_pose(z=5, mm=True), duration=0.5)
    mini.goto_target(antennas=np.deg2rad([45, 45]), duration=0.5)
    for _ in range(2):
        mini.goto_target(head=create_head_pose(pitch=-10, degrees=True), duration=0.3)
        mini.goto_target(head=create_head_pose(pitch=10, degrees=True), duration=0.3)
```

### Scanning Motion

```python
for angle in [-60, -30, 0, 30, 60]:
    mini.goto_target(
        body_yaw=np.deg2rad(angle),
        head=create_head_pose(z=5, mm=True),
        duration=1.0
    )
```

## Reference Files

- **installation.md** - Setup for Wireless/Lite/Simulation
- **movement_control.md** - Complete movement guide (450+ lines)
- **sensors.md** - Camera, microphone, IMU access
- **ai_integration.md** - AI models, LLMs, apps, deployment
- **daemon_api.md** - REST API reference (85 endpoints, v1.8.0)
- **openapi_schema.json** - OpenAPI v3.1.0 spec for client generation
- **openapi_usage.md** - Using OpenAPI for automation
- **api_quick_reference.md** - Quick reference card

## Platform Notes

- **Wireless**: Raspberry Pi, WiFi, includes IMU, use `localhost_only=False` from PC
- **Lite**: USB connection, no IMU, use `localhost_only=True`
- **Simulation**: MuJoCo-based, no hardware needed

## Safety

- SDK enforces limits automatically
- Test in simulation first
- Use appropriate durations (0.5-2.0s typically)
- Always use context managers (`with ReachyMini()`)

## Version

SDK v1.8.0, OpenAPI v3.1.0

Source: https://github.com/pollen-robotics/reachy_mini/tree/1.8.0
