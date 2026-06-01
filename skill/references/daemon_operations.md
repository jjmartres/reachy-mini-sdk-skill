# Daemon Operations (v1.8.0)

Practical guide to operating the Reachy Mini daemon: who owns the hardware, how to
take/relinquish control, motor modes, media acquisition, and recovering from a stuck
app. Endpoint shapes are in `daemon_api.md`; this doc is the "how to drive it safely"
companion.

The daemon is a FastAPI service on port 8000 that owns the hardware and runs the motor
control loop (~50 Hz). All movement, state, and media flow through it — you never talk to
the motors directly.

## Who holds the robot? (the app lock)

Only one app or session controls the robot at a time. Check before driving it from a
script:

```bash
curl -s localhost:8000/api/daemon/robot-app-lock-status
# {"state": "free" | "local_app" | "remote_session", "holder_name": "..."}
```

- `free` — nothing owns the robot; safe to drive directly over REST or with the SDK.
- `local_app` — an installed app (started via the AppManager) holds it.
- `remote_session` — a remote SDK/session holds it.

### Recovering from a crashed app

If an app crashed but the daemon still lists it as current (so the slot looks occupied),
inspect and clear it:

```bash
curl -s localhost:8000/api/apps/current-app-status     # may show state "error" + traceback
curl -s -X POST localhost:8000/api/apps/stop-current-app
```

After `stop-current-app`, `current-app-status` returns `null` and the lock returns to
`free`. A crashed process may already be gone at the OS level — the record is what's
holding the slot.

## Motor modes

Mode is a **path segment**, not a JSON body: `POST /api/motors/set_mode/{mode}`.

| Mode | Behavior | Use when |
|------|----------|----------|
| `enabled` | Active position control; holds commanded pose | Normal operation / driving the robot |
| `disabled` | Compliant; motors free, movable by hand | Manual posing, recording by hand |
| `gravity_compensation` | Holds against gravity but yields to a push | Hand-guiding, kinesthetic teaching |

```bash
curl -s localhost:8000/api/motors/status                       # {"mode": "..."}
curl -s -X POST localhost:8000/api/motors/set_mode/gravity_compensation
```

SDK equivalents: `mini.enable_motors()`, `mini.disable_motors()`,
`mini.enable_gravity_compensation()`, `mini.disable_gravity_compensation()`.

## Media acquisition

Camera/audio are a shared resource the daemon hands out. Acquire before use, release when
done so other apps (or the wobbling idle animation) can have it back.

```bash
curl -s -X POST localhost:8000/api/media/acquire
curl -s localhost:8000/api/media/status
curl -s -X POST localhost:8000/api/media/release
```

Idle "wobbling" can be toggled with `POST /api/media/wobbling/{enable,disable}`. Sounds:
`GET /api/media/sounds`, `POST /api/media/play_sound` (`{"file": "..."}`), and
`POST /api/media/stop_sound`.

## Driving the robot directly over REST

When the lock is `free` and motors are `enabled`, you can drive it without the SDK.
Units: head `x,y,z` in **meters**, `roll,pitch,yaw` in **radians**; antennas and
`body_yaw` in **radians**. Interpolation: `linear | minjerk | ease_in_out | cartoon`.

```bash
# A gentle look-right with antennas, then read state back
curl -s -X POST localhost:8000/api/move/goto -H 'Content-Type: application/json' -d '{
  "head_pose": {"pitch": -0.15, "yaw": 0.35},
  "antennas": [0.5, -0.5],
  "body_yaw": 0.2,
  "duration": 1.5,
  "interpolation": "minjerk"
}'
curl -s localhost:8000/api/state/full      # head_pose, body_yaw, antennas_position, doa
```

Built-in animations and recovery:

- `POST /api/move/play/wake_up` — wake-up animation (also `mini.wake_up()`)
- `POST /api/move/play/goto_sleep` — park to sleep pose (also `mini.goto_sleep()`)
- `GET /api/move/running` — list in-flight moves; `POST /api/move/stop` (`{"uuid": ...}`) to cancel one

## Daemon health and lifecycle

```bash
curl -s localhost:8000/api/daemon/status        # state, version, backend control-loop stats
curl -s localhost:8000/api/daemon/hardware-id
curl -s -X POST localhost:8000/api/daemon/restart
```

## Safety

- Keep head angles inside the mechanism's range (roughly ±0.5 rad pitch/roll, ±0.78 rad
  yaw) and use moderate durations (0.5-2.0 s) — the daemon clamps, but smooth commands
  avoid jerk.
- Return to a neutral pose before releasing control, and consider `goto_sleep` /
  `disable_motors` when leaving the robot idle for a while.
- Never assume the lock is yours — re-check `robot-app-lock-status` if a move silently
  does nothing; another holder may have taken it.
