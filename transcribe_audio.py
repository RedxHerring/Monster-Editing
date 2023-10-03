# source /opt/intel/oneapi/setvars.sh
# export LD_PRELOAD=/usr/lib/libstdc++.so.6.0.32
import whisper
import sys

if len(sys.argv) > 1:
    audio_file = sys.argv[1]
else:
    audio_file = "Audio/ger/Ep01.flac"

model = whisper.load_model("large")
result = model.transcribe(audio_file)
print(result["text"])

