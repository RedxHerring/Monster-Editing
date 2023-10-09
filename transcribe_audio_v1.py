# source /opt/intel/oneapi/setvars.sh
# export LD_PRELOAD=/usr/lib/libstdc++.so.6.0.32
# import whisper
# import sys

# if len(sys.argv) > 1:
#     audio_file = sys.argv[1]
# else:
#     audio_file = "Audio/ger/Ep01.flac"

# model = whisper.load_model("large")
# result = model.transcribe(audio_file)
# print(result["text"])

# Import the required libraries
import sys
import speech_recognition as sr
import requests
import json

# Define the language codes and the corresponding models
lang_codes = {"de": "German", "fr": "French", "ja": "Japanese", "en": "English"}
models = {"de": "facebook/wav2vec2-large-xlsr-53-german", 
          "fr": "facebook/wav2vec2-large-xlsr-53-french",
          "ja": "facebook/wav2vec2-large-xlsr-53-japanese",
          "en": "facebook/wav2vec2-base-960h"}

# Get the audio file and the language code as arguments
audio_file = sys.argv[1]
lang_code = sys.argv[2]

# Check if the language code is valid
if lang_code not in lang_codes:
    print("Invalid language code. Please use one of these: de, fr, ja, en")
    sys.exit()

# Load the speech recognition module
recognizer = sr.Recognizer()

# Load the audio file as a source
with sr.AudioFile(audio_file) as source:
    # Record the audio data
    audio_data = recognizer.record(source)

    # Use the appropriate model to transcribe or translate the audio data
    model = models[lang_code]
    base_url = "https://api-inference.huggingface.co/models/"
    headers = {"Authorization": f"Bearer {API_TOKEN}"}
    payload = audio_data.get_wav_data()
    response = requests.post(base_url + model, headers=headers, data=payload)
    response.raise_for_status()
    result = response.json()

    # Extract the text from the result
    text = result["text"]

    # If the language is not English, translate the text using DeepL API
    if lang_code != "en":
        base_url = "https://api.deepl.com/v2/translate"
        params = {"auth_key": DEEPL_API_KEY, 
                  "text": text, 
                  "target_lang": "EN"}
        response = requests.get(base_url, params=params)
        response.raise_for_status()
        result = response.json()

        # Extract the translated text from the result
        text = result["translations"][0]["text"]

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
.git/To run this script, you will need to install some libraries and obtain some API keys. You can install speech_recognition and requests using pip install speech_recognition requests. You will also need to install torch and transformers to use the Hugging Face models. You can do that using pip install torch transformers.

You will need to obtain an API token from Hugging Face to use their models. You can do that by creating a free account on their website here and then copying your token from your profile settings here. You will need to set an environment variable called API_TOKEN with your token value before running the script.

You will also need to obtain an API key from DeepL to use their translation service. You can do that by creating a free account on their website here and then copying your key from your account settings [here]. You will need to set an environment variable called DEEPL_API_KEY with your key value before running the script.

The models that I used for this script are from the Hugging Face model hub. They are based on the wav2vec2 architecture and trained on large multilingual datasets. You can find more information about them [here]. They are suitable for speech recognition and translation tasks. However, you can also try other models from the model hub that suit your needs. You can browse the available models [here].
'''