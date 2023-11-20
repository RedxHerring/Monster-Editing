
''' Remember:
conda activate ipex
source /opt/intel/oneapi/setvars.sh
export LD_PRELOAD=/usr/lib/libstdc++.so.6.0.32
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.conda/envs/ipex/lib/python3.11/site-packages/nvidia/cuda_runtime/lib/
source /etc/profile

https://huggingface.co/facebook/hf-seamless-m4t-large might not be built for cuda only, so there may be hope

'''

# Import the required libraries
import intel_extension_for_pytorch as ipex
import numpy as np
import librosa
import sys
import torch
from transformers import AutoProcessor, SeamlessM4TForSpeechToText

def transcribe_audio(audio_file,lang_code):
    processor = AutoProcessor.from_pretrained("facebook/hf-seamless-m4t-large")
    model = SeamlessM4TForSpeechToText.from_pretrained("facebook/hf-seamless-m4t-large")

    model = model.to('xpu')

    # from audio
    audio, fs = librosa.load(audio_file, sr=16000)

    audio_inputs = processor(audios=audio[0:fs*10], return_tensors="pt") # process 60 seconds
    audio_inputs.to('xpu')
    model = ipex.optimize(model)

    output_tokens = model.generate(**audio_inputs, tgt_lang=lang_code, generate_speech=False)
    # S2TT
    translated_text_from_audio = processor.decode(output_tokens[0].tolist()[0], skip_special_tokens=True)
    translated_text_from_audio = processor.decode()
    # Format the text as a subtitle file

if __name__ == "__main__":
    # Get the audio file and the language code as arguments
    # audio_file = sys.argv[1]
    # lang_code = sys.argv[2]
    audio_file = "Audio/fre/Ep07.flac"
    lang_code = "eng"
    transcribe_audio(audio_file,lang_code)