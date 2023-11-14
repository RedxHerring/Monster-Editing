
# Make sure to conda activate ipex in advance

function get_language() { # input shorthand $lang and get full language name
    if [[ $1 == "ara" ]]; then
        echo "Arabic"
    elif [[ $1 == "bra" ]]; then
        echo "Brazilian-Portuguese"
    elif [[ $1 == "deu" ]]; then
        echo "German"
    elif [[ $1 == "eng" ]]; then
        echo "English"
    elif [[ $1 == "fre" ]]; then
        echo "French"
    elif [[ $1 == "ind" ]]; then
        echo "Indonesian"
    elif [[ $1 == "ita" ]]; then
        echo "Italian"
    elif [[ $1 == "msa" ]]; then
        echo "Malay"
    elif [[ $1 == "pol" ]]; then
        echo "Polish"
    elif [[ $1 == "por" ]]; then
        echo "Portuguese"
    elif [[ $1 == "ron" ]]; then
        echo "Romanian"
    elif [[ $1 == "spa" ]]; then
        echo "Spanish"
    elif [[ $1 == "tha" ]]; then
        echo "Thai"
    elif [[ $1 == "tur" ]]; then
        echo "Turkish"
    elif [[ $1 == "vie" ]]; then
        echo "Vietnamese"
    elif [[ $1 == "jpn" ]]; then
        echo "Japanese"
    elif [[ $1 == "zho" ]]; then
        echo "Chinese"
    fi
}

source /opt/intel/oneapi/setvars.sh
export LD_PRELOAD=/usr/lib/libstdc++.so.6.0.32

# whisper $1 --model large-v2 --task translate --language de --logprob_threshold -.4 --beam_size 10 --patience 2 --output_format srt --output_dir Subs
lang=$(echo $(basename $1))
mkdir -p Subs/Whisper-Transcribed/$lang
language=$(get_language $lang)
for afile in "$1"*.flac; do
    echo "Transcribing $afile into  Subs/Whisper-Transcribed/$lang/"
    whisper "$afile" --model large-v3 --task transcribe --language $language --beam_size 10 --patience 2   --suppress_tokens "" --condition_on_previous_text False --output_format srt --output_dir Subs/Whisper-Transcribed/$lang/
done
# sudo intel_gpu_top
