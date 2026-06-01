# Daemon REST API Reference (v1.8.0)

Complete reference for the Reachy Mini daemon HTTP API, generated from the live
OpenAPI 3.1.0 spec served at `http://<robot>:8000/openapi.json` (rendered at `/docs`).
Base URL: `http://localhost:8000` (local) or `http://<robot-ip>:8000` (remote).

**85 endpoints.** Request/response models are defined in `openapi_schema.json`.

> Units: head pose `x,y,z` in **meters**, `roll,pitch,yaw` in **radians**; antennas and
> body_yaw in **radians**. Interpolation enum: `linear`, `minjerk`, `ease_in_out`, `cartoon`.

## Contents
- [Movement](#movement)
- [State](#state)
- [Motors](#motors)
- [Media (audio acquisition & sounds)](#media-audio-acquisition-sounds)
- [Audio config](#audio-config)
- [Camera](#camera)
- [Volume](#volume)
- [Kinematics](#kinematics)
- [App management](#app-management)
- [Daemon control](#daemon-control)
- [Hugging Face auth](#hugging-face-auth)
- [Firmware / software update](#firmware-software-update)
- [Wi-Fi](#wi-fi)
- [Cache](#cache)
- [Health](#health)
- [Dashboard pages](#dashboard-pages)
- [Misc](#misc)

## Movement

### `POST /api/move/goto`
Goto.

Request body (`application/json`): `GotoModelRequest`
    - `head_pose`: XYZRPYPose | Matrix4x4Pose | null (optional)
    - `antennas`: [number, number] | null (optional)
    - `body_yaw`: number | null (optional)
    - `duration`: number
    - `interpolation`: InterpolationTechnique (optional), default=minjerk

Returns (`application/json`): `MoveUUID`

### `POST /api/move/play/goto_sleep`
Play Goto Sleep.

Returns (`application/json`): `MoveUUID`

### `POST /api/move/play/recorded-move-dataset/{dataset_name}/{move_name}`
Play Recorded Move Dataset.

Parameters:
- `dataset_name` (path, required): string
- `move_name` (path, required): string

Returns (`application/json`): `MoveUUID`

### `POST /api/move/play/wake_up`
Play Wake Up.

Returns (`application/json`): `MoveUUID`

### `GET /api/move/recorded-move-datasets/list/{dataset_name}`
List Recorded Move Dataset.

Parameters:
- `dataset_name` (path, required): string

Returns (`application/json`): `string[]`

### `GET /api/move/running`
Get Running Moves.

Returns (`application/json`): `MoveUUID[]`

### `POST /api/move/set_target`
Set Target.

Request body (`application/json`): `FullBodyTarget`
    - `target_head_pose`: XYZRPYPose | Matrix4x4Pose | null (optional)
    - `target_antennas`: [number, number] | null (optional)
    - `target_body_yaw`: number | null (optional)
    - `timestamp`: string | null (optional)

### `POST /api/move/stop`
Stop Move.

Request body (`application/json`): `MoveUUID`
    - `uuid`: string

## State

### `GET /api/state/doa`
Get Doa.

Returns (`application/json`): `DoAInfo | null`

### `GET /api/state/full`
Get Full State.

Parameters:
- `with_control_mode` (query): boolean
- `with_head_pose` (query): boolean
- `with_target_head_pose` (query): boolean
- `with_head_joints` (query): boolean
- `with_target_head_joints` (query): boolean
- `with_body_yaw` (query): boolean
- `with_target_body_yaw` (query): boolean
- `with_antenna_positions` (query): boolean
- `with_target_antenna_positions` (query): boolean
- `with_passive_joints` (query): boolean
- `with_doa` (query): boolean
- `use_pose_matrix` (query): boolean

Returns (`application/json`): `FullState`

### `GET /api/state/present_antenna_joint_positions`
Get Antenna Joint Positions.

Returns (`application/json`): `[number, number]`

### `GET /api/state/present_body_yaw`
Get Body Yaw.

Returns (`application/json`): `number`

### `GET /api/state/present_head_pose`
Get Head Pose.

Parameters:
- `use_pose_matrix` (query): boolean

Returns (`application/json`): `XYZRPYPose | Matrix4x4Pose`

## Motors

### `POST /api/motors/set_mode/{mode}`
Set Motor Mode.

Parameters:
- `mode` (path, required): MotorControlMode

### `GET /api/motors/status`
Get Motor Status.

Returns (`application/json`): `MotorStatus`

## Media (audio acquisition & sounds)

### `POST /api/media/acquire`
Acquire Media.

### `POST /api/media/play_sound`
Play Sound.

Request body (`application/json`): `PlaySoundRequest`
    - `file`: string

### `POST /api/media/release`
Release Media.

### `GET /api/media/sounds`
List Sounds.

### `POST /api/media/sounds/upload`
Upload Sound.

Request body (`multipart/form-data`): `Body_upload_sound_api_media_sounds_upload_post`
    - `file`: string

### `DELETE /api/media/sounds/{filename}`
Delete Sound.

Parameters:
- `filename` (path, required): string

### `GET /api/media/status`
Media Status.

### `POST /api/media/stop_sound`
Stop Sound.

### `POST /api/media/wobbling/disable`
Disable Wobbling.

### `POST /api/media/wobbling/enable`
Enable Wobbling.

## Audio config

### `POST /api/audio/config/apply`
Apply Audio Config.

Request body (`application/json`): `ApplyAudioConfigRequest`
    - `config`: AudioParamPair[]
    - `verify`: boolean (optional), default=True

Returns (`application/json`): `ApplyAudioConfigResponse`

### `GET /api/audio/config/parameter/{name}`
Read Audio Parameter.

Parameters:
- `name` (path, required): string

Returns (`application/json`): `ReadAudioParameterResponse`

## Camera

### `GET /api/camera/specs`
Get Camera Specs.

Returns (`application/json`): `CameraSpecsResponse`

## Volume

### `GET /api/volume/current`
Get Volume.

Returns (`application/json`): `VolumeResponse`

### `GET /api/volume/microphone/current`
Get Microphone Volume.

Returns (`application/json`): `VolumeResponse`

### `POST /api/volume/microphone/set`
Set Microphone Volume.

Request body (`application/json`): `VolumeRequest`
    - `volume`: integer

Returns (`application/json`): `VolumeResponse`

### `POST /api/volume/set`
Set Volume.

Request body (`application/json`): `VolumeRequest`
    - `volume`: integer

Returns (`application/json`): `VolumeResponse`

### `POST /api/volume/test-sound`
Play Test Sound.

Returns (`application/json`): `TestSoundResponse`

## Kinematics

### `GET /api/kinematics/info`
Get Kinematics Info.

### `GET /api/kinematics/stl/{filename}`
Get Stl File.

Parameters:
- `filename` (path, required): string

### `GET /api/kinematics/urdf`
Get Urdf.

## App management

### `GET /api/apps/check-updates`
Check App Updates.

Parameters:
- `force` (query): boolean

Returns (`application/json`): `AppUpdatesResponse`

### `GET /api/apps/current-app-status`
Current App Status.

Returns (`application/json`): `AppStatus | null`

### `POST /api/apps/install`
Install App.

Request body (`application/json`): `AppInfo`
    - `name`: string
    - `source_kind`: SourceKind
    - `description`: string (optional), default=
    - `url`: string | null (optional)
    - `extra`: object (optional)

### `POST /api/apps/install-private-space`
Install Private Space.

Request body (`application/json`): `PrivateSpaceInstallRequest`
    - `space_id`: string

### `GET /api/apps/job-status/{job_id}`
Job Status.

Parameters:
- `job_id` (path, required): string

Returns (`application/json`): `JobInfo`

### `GET /api/apps/list-available`
List All Available Apps.

Returns (`application/json`): `AppInfo[]`

### `GET /api/apps/list-available/{source_kind}`
List Available Apps.

Parameters:
- `source_kind` (path, required): SourceKind

Returns (`application/json`): `AppInfo[]`

### `POST /api/apps/remove/{app_name}`
Remove App.

Parameters:
- `app_name` (path, required): string

### `POST /api/apps/restart-current-app`
Restart App.

Returns (`application/json`): `AppStatus`

### `POST /api/apps/start-app/{app_name}`
Start App.

Parameters:
- `app_name` (path, required): string

Returns (`application/json`): `AppStatus`

### `POST /api/apps/stop-current-app`
Stop App.

### `POST /api/apps/update/{app_name}`
Update App.

Parameters:
- `app_name` (path, required): string

## Daemon control

### `GET /api/daemon/hardware-id`
Get Robot Hardware Id.

### `POST /api/daemon/restart`
Restart Daemon.

### `GET /api/daemon/robot-app-lock-status`
Get Robot App Lock Status.

Returns (`application/json`): `RobotAppLockStatus`

### `POST /api/daemon/start`
Start Daemon.

Parameters:
- `wake_up` (query, required): boolean

### `GET /api/daemon/status`
Get Daemon Status.

Returns (`application/json`): `DaemonStatus`

### `POST /api/daemon/stop`
Stop Daemon.

Parameters:
- `goto_sleep` (query, required): boolean

## Hugging Face auth

### `GET /api/hf-auth/central-robot-status`
Get Central Robot Status.

### `GET /api/hf-auth/oauth/callback`
Oauth Callback.

Parameters:
- `code` (query): string | null
- `state` (query): string | null
- `error` (query): string | null
- `error_description` (query): string | null

### `GET /api/hf-auth/oauth/configured`
Is Oauth Configured.

### `DELETE /api/hf-auth/oauth/session/{session_id}`
Cancel Oauth Session.

Parameters:
- `session_id` (path, required): string

### `GET /api/hf-auth/oauth/start`
Start Oauth.

Parameters:
- `use_localhost` (query): boolean

### `GET /api/hf-auth/oauth/status/{session_id}`
Get Oauth Status.

Parameters:
- `session_id` (path, required): string

### `POST /api/hf-auth/refresh-relay`
Refresh Relay.

### `GET /api/hf-auth/relay-status`
Get Relay Status.

### `POST /api/hf-auth/save-token`
Save Token.

Request body (`application/json`): `TokenRequest`
    - `token`: string

Returns (`application/json`): `TokenResponse`

### `GET /api/hf-auth/status`
Get Auth Status.

### `DELETE /api/hf-auth/token`
Delete Token.

## Firmware / software update

### `GET /update/available`
Available.

Parameters:
- `pre_release` (query): boolean

### `GET /update/info`
Get Update Info.

Parameters:
- `job_id` (query, required): string

Returns (`application/json`): `JobInfo`

### `GET /update/install-source`
Install Source.

### `POST /update/start`
Start Update.

Parameters:
- `pre_release` (query): boolean

### `POST /update/start-from-ref`
Start Update From Ref.

Parameters:
- `git_ref` (query, required): string

### `GET /update/validate-ref`
Validate Ref.

Parameters:
- `git_ref` (query, required): string

## Wi-Fi

### `POST /wifi/connect`
Connect To Wifi Network.

Parameters:
- `ssid` (query, required): string
- `password` (query, required): string

### `GET /wifi/error`
Get Last Wifi Error.

### `POST /wifi/forget`
Forget Wifi Network.

Parameters:
- `ssid` (query, required): string

### `POST /wifi/forget_all`
Forget All Wifi Networks.

### `POST /wifi/reset_error`
Reset Last Wifi Error.

### `POST /wifi/scan_and_list`
Scan Wifi.

Returns (`application/json`): `string[]`

### `POST /wifi/setup_hotspot`
Setup Hotspot.

Parameters:
- `ssid` (query): string
- `password` (query): string

### `GET /wifi/status`
Get Wifi Status.

Returns (`application/json`): `WifiStatus`

## Cache

### `POST /cache/clear-hf`
Clear Huggingface Cache.

### `POST /cache/reset-apps`
Reset Apps.

## Health

### `POST /health-check`
Health Check.

## Dashboard pages

### `GET /logs`
Logs Page.

### `GET /settings`
Settings.

## Misc

### `GET /`
Dashboard.
