# Take as input the location of the mounted blue-ray disc.
# Rip all titles from the disc into Blu-Ray/Ripped-Titles
# Instruct the user to name and copy episodes over into Blu-Ray/Episodes
# Use ffmpeg to re-encode

over_write=true

rip_path="Blu-Ray/Ripped-Titles"
mkdir -p $rip_path

# for title in {0..15}; do
#     mplayer -dumpstream br://$title -nocache -bluray-device $1 -dumpfile "$rip_path/title$title.mpg"
# done
echo "Titles from $1 saved in $rip_path. View and rename them, deleting any repeats or undesired videos."
read -p "When finished renaming, press Enter to start encoding process." </dev/tty
out_path="Blu-Ray/Encoded"
mkdir -p $out_path
echo "Encoding all *mpg videos in $rip_path, and saving them in $out_path."

for vid in $rip_path/*mpg; do
    filename=$(basename -- "$vid")
    out_name="${filename%.*}"
    fullname_out="$out_path/$out_name-av1.mkv"
    if [  -f "$fullname_out" ] && [ $over_write = false ]; then
        echo "$fullname_out already exists"
    else
        echo "re-encoding $vid into $fullname_out."
        ffmpeg -y -loglevel verbose -init_hw_device qsv=hw -filter_hw_device hw -i $vid -map v:0 -map a:0 -map a:1 -map s:0 -map s:1 -vf "crop=1440:1080" \
        -c:v av1_qsv -preset veryslow -global_quality:v 20 -look_ahead 1 -extbrc 0 -look_ahead_depth 36 -pix_fmt yuv420p10le -c:a:0 libvorbis -q:a:0 7 -c:a:1 libopus -b:a:1 108000 -vbr:a on -c:s copy "$fullname_out"
        fullname_out="$out_path/$out_name-h265.mkv"
        echo "re-encoding $vid into $fullname_out."
        ffmpeg -y -loglevel warning -init_hw_device qsv=hw -filter_hw_device hw -i $vid -map v:0 -map a:0 -map a:1 -map s:0 -map s:1 -vf "crop=1440:1080" \
        -c:v hevc_qsv -preset veryslow -global_quality:v 18 -look_ahead 1 -scenario:v archive -pix_fmt p010le -c:a:0 libvorbis -q:a:0 7 -c:a:1 libopus -b:a:1 108000 -vbr:a on -c:s copy "$fullname_out"
    fi
done
