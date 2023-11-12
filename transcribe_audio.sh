
# Make sure to conda activate ipex in advance

source /opt/intel/oneapi/setvars.sh
export LD_PRELOAD=/usr/lib/libstdc++.so.6.0.32

# whisper $1 --model large-v2 --task translate --language de --logprob_threshold -.4 --beam_size 10 --patience 2 --output_format srt --output_dir Subs
lang=$(echo $(basename $1))
mkdir -p Subs/Whisper-Transcribed/$lang
lan=$(cut -c 1-2<<< $lang)
for afile in "$1"*.flac; do
    echo "Transcribing $afile into  Subs/Whisper-Transcribed/$lang/"
    whisper "$afile" --model large-v3 --task transcribe --language $lan --beam_size 10 --patience 2   --suppress_tokens "" --condition_on_previous_text False --output_format srt --output_dir Subs/Whisper-Transcribed/$lang/
done
# sudo intel_gpu_top
