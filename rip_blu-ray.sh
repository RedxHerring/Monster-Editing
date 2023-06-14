# Take as input the location of the mounted blue-ray disc.
# Rip all titles from the disc into Blu-Ray/Ripped-Titles
# Instruct the user to name and copy episodes over into Blu-Ray/Episodes
# Use ffmpeg to re-encode

rip_path="Blu-Ray/Ripped-Titles"
mkdir -p $rip_path

# for title in {0..15}; do
#     mplayer -dumpstream br://$title -nocache -bluray-device $1 -dumpfile "$rip_path/title$title.mpg"
# done
ep_path="Blu-Ray/Episodes"
mkdir -p $ep_path
echo "Titles from $1 saved in $rip_path. View and rename them (note there may be some repeats you'll have to delete), then copy to $ep_path for encoding."
read -p "When finished renaming, press Enter to start re-encoding" </dev/tty
out_path="Blu-Ray/Encoded"
mkdir -p $out_path
echo "Encoding all *mpg videos in $ep_path, and saving them in $out_path."

for vid in Blu-Ray/Episodes/*mpg; do
    filename=$(basename -- "$vid")
    out_name="${filename%.*}"
    echo "re-encoding $vid into $out_path/$out_name.webm."
    ffmpeg -loglevel warning -i $vid -c:v libvpx-vp9 -b:v 0 -crf 30 -pass 1 -an -f null /dev/null && \
    ffmpeg -loglevel warning -i $vid -map v:0 -map a:0 -map a:1 -map s:0 -map s:1  -c:v libvpx-vp9 -b:v 0 -crf 30 -pass 2 -c:a libopus -af "channelmap=channel_layout=5.1" "$out_path/$out_name.webm"
done
