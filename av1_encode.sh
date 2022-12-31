# This bash script will take files output from kdenlive, ideally lossless ones, and re-encode as av1 to beocme much smaller

cd Output/

for i in *.mp4; do
    ffmpeg -init_hw_device qsv=hw -filter_hw_device hw -i "$i" -c:v av1_qsv "${i%.*}GPU.mkv"
done
# ffmpeg -init_hw_device qsv=hw -filter_hw_device hw -f rawvideo -pix_fmt yuv420p -s:v 1920x1080 -i Monster_1-4_Murder_and_Execution_1080p_24fps.mp4 -vf hwupload=extra_hw_frames=64,format=qsv -c:v av1_qsv -b:v 5M Monster_1-4_Murder_and_Execution_1080p_24fps_GPU.mkv

# https://trac.ffmpeg.org/wiki/Hardware/QuickSync