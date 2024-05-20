pwd0=$(pwd)
mkdir -p Orig720p/MP4
# For the name we save, we want to match the format used by the Upscale project, which is
# EpXXepisodetitle.ass. The title is actually not contained, so we settle for EpXX.ass
for vid in Orig720p/*.mkv; do
    rest=$(sed -e 's#.*/Monster \(\)#\1#' <<< "$vid") # find first Monster
    epnum=$(cut -c 1-2<<< $rest)
    out_name="Ep$epnum"
    echo "Processing video $vid, as $out_name"
    ffmpeg -n -loglevel warning -i "$vid" -map v:0 "$pwd0/Orig720p/MP4/$out_name.mp4"
done
