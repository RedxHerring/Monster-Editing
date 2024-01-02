# This bash script will take files output from kdenlive, ideally lossless ones, and re-encode as av1 to beocme much smaller

cd $1

for vid in *.mp4; do
    ffmpeg -n -loglevel warning -init_hw_device qsv=hw -filter_hw_device hw -i $vid -map 0 -c:v av1_qsv -preset veryslow \
        -global_quality:v 20 -extbrc 0 -look_ahead_depth 36 -pix_fmt p010le -c:a:0  libopus -b:a 108000 -vbr:a on "${vid%.*}.mkv"
done
# ffmpeg -init_hw_device qsv=hw -filter_hw_device hw -f rawvideo -pix_fmt yuv420p -s:v 1920x1080 -i Monster_1-4_Murder_and_Execution_1080p_24fps.mp4 -vf hwupload=extra_hw_frames=64,format=qsv -c:v av1_qsv -b:v 5M Monster_1-4_Murder_and_Execution_1080p_24fps_GPU.mkv
# burn subs using https://trac.ffmpeg.org/wiki/HowToBurnSubtitlesIntoVideo
# -vf subtitles=../../Subs/Definitive-Subs/Ep01-04.ass
# https://trac.ffmpeg.org/wiki/Hardware/QuickSync