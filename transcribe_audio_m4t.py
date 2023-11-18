
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
from transformers import AutoProcessor, SeamlessM4TModel
processor = AutoProcessor.from_pretrained("facebook/hf-seamless-m4t-large")
model = SeamlessM4TModel.from_pretrained("facebook/hf-seamless-m4t-large")

model = model.to('xpu')

# Define the language codes and the corresponding models
lang_codes = {"deu": "German", "fre": "French", "jpn": "Japanese", "eng": "English", "spa": "Spanish"}
models = {"deu": "meta/seamlessm4t-de-en", 
          "fre": "meta/seamlessm4t-fr-en",
          "jpn": "meta/seamlessm4t-ja-en",
          "eng": "meta/seamlessm4t-en"}

# Get the audio file and the language code as arguments
audio_file = sys.argv[1]
lang_code = sys.argv[2]

# Check if the language code is valid
if lang_code not in lang_codes:
    print("Invalid language code. Please use one of these: de, fr, ja, en")
    sys.exit()

# from audio
audio, fs = librosa.load(audio_file, sr=16000)

audio_inputs = processor(audios=audio[0:fs*30], return_tensors="pt") # process 10 seconds
audio_inputs.to('xpu')
model = ipex.optimize(model)

output_tokens = model.generate(**audio_inputs, tgt_lang="deu", generate_speech=False)
# S2TT
translated_text_from_audio = processor.decode(output_tokens[0], skip_special_tokens=True)
processor.decode()
# Format the text as a subtitle file
subtitles = ""
counter = 1
for line in text.split("\n"):
    # Skip empty lines
    if not line.strip():
        continue

    # Calculate the start and end time of each line based on the average speech rate
    duration = len(line.split()) / 150 # 150 words per minute
    start_time = counter * duration - duration
    end_time = counter * duration

    # Format the time as hours:minutes:seconds,milliseconds
    start_time = "{:02d}:{:02d}:{:02d},{:03d}".format(int(start_time // 3600), 
                                                      int(start_time % 3600 // 60), 
                                                      int(start_time % 60), 
                                                      int(start_time % 1 * 1000))
    end_time = "{:02d}:{:02d}:{:02d},{:03d}".format(int(end_time // 3600), 
                                                    int(end_time % 3600 // 60), 
                                                    int(end_time % 60), 
                                                    int(end_time % 1 * 1000))

    # Add the subtitle number, time range, and text to the subtitles string
    subtitles += f"{counter}\n{start_time} --> {end_time}\n{line}\n\n"

    # Increment the counter
    counter += 1

# Write the subtitles to a file with the same name as the audio file but with .srt extension
output_file = audio_file.rsplit(".", 1)[0] + ".srt"
with open(output_file, "w") as f:
    f.write(subtitles)

# Print a success message
print(f"Subtitle file {output_file} created successfully.")

'''
To run this script, you will need to install some libraries and obtain an API token. You can install fairseq2 and requests using pip install fairseq2 requests. You will also need to install torch and transformers to use the Hugging Face models. You can do that using pip install torch transformers.

You will need to obtain an API token from Hugging Face to use their models. You can do that by creating a free account on their website here and then copying your token from your profile settings here. You will need to set an environment variable called API_TOKEN with your token value before running the script.

The models that I used for this script are from the Hugging Face model hub. They are based on the SeamlessM4T architecture and trained on large multimodal datasets. You can find more information about them here. They are suitable for speech recognition and translation tasks. However, you can also try other models from the model hub that suit your needs. You can browse the available models [here].
'''