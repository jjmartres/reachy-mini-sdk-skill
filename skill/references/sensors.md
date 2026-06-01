# Sensors Reference

Guide to accessing Reachy Mini's sensors: camera, microphone, and IMU.

## Camera Access

### Get Frame

```python
from reachy_mini import ReachyMini

with ReachyMini(media_backend="default") as mini:
    frame = mini.media.get_frame()
    # frame: numpy array (height, width, 3), dtype uint8, BGR format
```

### Media Backends

**"default"**: OpenCV + Sounddevice (recommended)
- Works locally and remotely
- Simple setup
- Good performance

**"gstreamer"**: GStreamer for both camera and audio
- Requires GStreamer installation
- Better for advanced streaming
- Lower latency

**"webrtc"**: Automatic for remote connections
- Used when `localhost_only=False`
- Streams via WebRTC
- Handles network efficiently

### Camera Examples

**Display camera feed:**
```python
import cv2

with ReachyMini(media_backend="default") as mini:
    while True:
        frame = mini.media.get_frame()
        cv2.imshow("Reachy Mini Camera", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    cv2.destroyAllWindows()
```

**Save frame:**
```python
frame = mini.media.get_frame()
cv2.imwrite("reachy_view.jpg", frame)
```

**Process with AI:**
```python
from transformers import pipeline

detector = pipeline("object-detection")

frame = mini.media.get_frame()
# Convert BGR to RGB
frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
results = detector(frame_rgb)
```

## Microphone Access

### Record Audio

```python
from reachy_mini import ReachyMini

with ReachyMini(media_backend="default") as mini:
    samples = mini.media.get_audio_sample()
    # samples: numpy array (num_samples, 2), dtype float32
    # Sampled at 16kHz, stereo
```

### Audio Properties

```python
# Get sample rate
input_rate = mini.media.get_input_audio_samplerate()  # 16000 Hz
output_rate = mini.media.get_output_audio_samplerate()  # 16000 Hz

# Get channels
input_channels = mini.media.get_input_channels()  # 2 (stereo)
output_channels = mini.media.get_output_channels()  # 1 or 2
```

### Play Audio

```python
import time

# Play samples (non-blocking)
mini.media.push_audio_sample(samples)

# Wait for playback to complete
duration = len(samples) / mini.media.get_output_audio_samplerate()
time.sleep(duration)
```

### Audio Examples

**Record and playback:**
```python
from scipy.signal import resample
import time

with ReachyMini(media_backend="default") as mini:
    # Record
    print("Recording...")
    samples = mini.media.get_audio_sample()
    
    # Resample if needed
    input_rate = mini.media.get_input_audio_samplerate()
    output_rate = mini.media.get_output_audio_samplerate()
    
    if input_rate != output_rate:
        new_length = int(len(samples) * output_rate / input_rate)
        samples = resample(samples, new_length)
    
    # Play
    print("Playing...")
    mini.media.push_audio_sample(samples)
    time.sleep(len(samples) / output_rate)
```

**Speech recognition:**
```python
from transformers import pipeline
import torch

recognizer = pipeline("automatic-speech-recognition", model="openai/whisper-base")

samples = mini.media.get_audio_sample()
# Convert to mono if needed
if samples.shape[1] == 2:
    samples_mono = samples.mean(axis=1)
else:
    samples_mono = samples.squeeze()

# Recognize speech
result = recognizer(samples_mono, sampling_rate=16000)
print(f"Recognized: {result['text']}")
```

**Text-to-speech:**
```python
from transformers import pipeline
import numpy as np

synthesizer = pipeline("text-to-speech", model="facebook/mms-tts-eng")

text = "Hello, I am Reachy Mini!"
speech = synthesizer(text)

# Convert to correct format
samples = np.array(speech["audio"]).astype(np.float32)
if samples.ndim == 1:
    samples = samples.reshape(-1, 1)

mini.media.push_audio_sample(samples)
```

## IMU Access (Wireless Only)

### Get IMU Data

On v1.8.0 `mini.imu` is a **property** that returns a dict (or `None` on the Lite
version, in simulation, or before the first sample at 50 Hz). It is not a method.

```python
with ReachyMini() as mini:
    imu_data = mini.imu
    if imu_data is not None:
        print(f"Accelerometer: {imu_data['accelerometer']}")
        print(f"Gyroscope: {imu_data['gyroscope']}")
        print(f"Quaternion: {imu_data['quaternion']}")
        print(f"Temperature: {imu_data['temperature']}")
    else:
        print("IMU not available (Lite version or no data yet)")
```

### IMU Data Structure

```python
imu_data["accelerometer"]  # [x, y, z] in m/s²
imu_data["gyroscope"]      # [x, y, z] in rad/s
imu_data["quaternion"]     # [w, x, y, z] orientation quaternion
imu_data["temperature"]    # float, °C
```

### IMU Examples

**Detect motion:**
```python
import numpy as np

threshold = 2.0  # m/s²

imu_data = mini.imu
if imu_data is not None:
    accel_magnitude = np.linalg.norm(imu_data["accelerometer"])
    if accel_magnitude > threshold:
        print("Motion detected!")
```

**Monitor orientation (quaternion -> euler):**
```python
from scipy.spatial.transform import Rotation as R

imu_data = mini.imu
w, x, y, z = imu_data["quaternion"]
roll, pitch, yaw = R.from_quat([x, y, z, w]).as_euler("xyz", degrees=True)

print(f"Roll: {roll:.1f}°  Pitch: {pitch:.1f}°  Yaw: {yaw:.1f}°")
```

## Best Practices

**Camera:**
- Process frames efficiently
- Consider frame rate for your application
- Handle connection loss gracefully
- Convert BGR to RGB for most AI models

**Audio:**
- Check sample rates before processing
- Use non-blocking push_audio_sample()
- Handle stereo/mono conversion as needed
- Buffer audio for smooth playback

**IMU:**
- Only available on Wireless version
- Check availability before use
- Filter noisy readings if needed
- Consider sensor fusion for accurate orientation

## Troubleshooting

**No camera frames:**
- Check media_backend selection
- Verify USB connection
- Test with cv2.VideoCapture() directly
- Restart daemon

**No audio:**
- Check media_backend
- Verify microphone/speaker connections
- Test sample rates match
- Check system audio settings

**IMU not available:**
- Verify Wireless version (not Lite)
- Check daemon includes IMU support
- Ensure proper initialization

**High latency (remote):**
- Use "webrtc" backend
- Check network bandwidth
- Reduce frame rate if needed
- Consider running locally
