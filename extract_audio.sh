in_dir=$1 #'Monster [Ultimate Collection] By Kira [SEV]/Original Soundtracks [2004]'
out_dir=$2 #Audio/SEVwav

mkdir -p ${out_dir// /_}
for afile in  "$in_dir"/*.webm; do
    out_name=""$out_dir"/$(basename "${afile%.*}").wav"
    # echo "$out_name"
    out_name="${out_name// /_}"
    # echo "ffmpeg -n -loglevel warning -i "$afile" $out_name"
    ffmpeg -n -loglevel warning -i "$afile" $out_name
done


# for dir in "$SEVdir"/* ; do
#     # echo "$SEVdir/$dir"
#     for afile in  "$SEVdir"/$dir/*.flac; do
#         echo "$afile"
#     done
# done
        # ffmpeg -i $
# for vid in $SAVdir*.mkv; do

# find "$SAVdir" -type f -name "*.flac" -exec sh -c 'echo "transcoding $0 to Audio/SAVwav"; ffmpeg -i "$0" -vn -map a:0 "Audio/SAVwav/${$0%.*}.wav"' {} \;
# find "$SAVdir" -type f -name "*.flac" -exec sh -c 'echo "$0"' {} \;

# To dowload wav from online video use for example:
# yt-dlp -x --audio-format wav https://www.youtube.com/watch?v=86n7reItMzs