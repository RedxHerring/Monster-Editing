
SEVdir='Monster [Ultimate Collection] By Kira [SEV]/Original Soundtracks [2004]'
out_dir=Audio/SEVwav

dir="Monster - Original Soundtrack [2004]"
full_dir="$out_dir/$dir"
mkdir -p ${full_dir// /_}
for afile in  "$SEVdir/$dir"/*.flac; do
    out_name=""$out_dir/$dir"/$(basename "${afile%.*}").wav"
    # echo "$out_name"
    out_name="${out_name// /_}"
    # echo "ffmpeg -n -loglevel warning -i "$afile" $out_name"
    ffmpeg -n -loglevel warning -i "$afile" $out_name
done

dir="Monster - Original Soundtrack II [2004]"
full_dir="$out_dir/$dir"
mkdir -p ${full_dir// /_}
for afile in  "$SEVdir/$dir"/*.flac; do
    out_name=""$out_dir/$dir"/$(basename "${afile%.*}").wav"
    # echo "$out_name"
    out_name="${out_name// /_}"
    # echo "ffmpeg -n -loglevel warning -i "$afile" $out_name"
    ffmpeg -n -loglevel warning -i "$afile" $out_name
done

dir="Various Artists - Monster Remix -Octopus- [2004]"
full_dir="$out_dir/$dir"
mkdir -p ${full_dir// /_}
for afile in  "$SEVdir/$dir"/*.flac; do
    out_name=""$out_dir/$dir"/$(basename "${afile%.*}").wav"
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
