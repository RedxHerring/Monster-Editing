
# Make sure to conda activate ipex in advance

source /opt/intel/oneapi/setvars.sh
export LD_PRELOAD=/usr/lib/libstdc++.so.6.0.32

# whisper $1 --model large-v2 --task translate --language de --logprob_threshold -.4 --beam_size 10 --patience 2 --output_format srt --output_dir Subs
lang=$(echo $(basename $1))
mkdir -p Subs/$lang
for afile in "$1/"*.flac; do
    whisper "$afile" --model large-v2 --task translate --language de --logprob_threshold -.4 --beam_size 10 --patience 2 --output_format srt --output_dir Subs/$lang/
done
# sudo intel_gpu_top
