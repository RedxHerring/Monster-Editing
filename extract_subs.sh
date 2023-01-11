# We will use this file to get the subs from the 480p source from https://nyaa.si/view/1611098

cd Monster.S01.480p.NF.WEB-DL.DDP2.0.x264-Emmid

file_path="NFLX-Subs/"
mkdir -p $file_path
suffix=".ass"
for vid in *.mp4; do
    for strm in {0..15}; do
        lang_text=$(ffprobe -v error -hide_banner -of default=noprint_wrappers=0 -print_format flat  -select_streams s:$strm -show_entries stream=index:stream_tags=language $vid | grep language)
        lang=$(echo $lang_text | cut -d '"' -f 2)
        echo "Processing video $vid, stream $strm, language $lang"
        mkdir -p "$file_path$lang/"
        if test -f "$file_path$lang/${vid%.*}$suffix"; then
            echo "$file_path${vid%.*}$suffix already exists"
        else
            ffmpeg -i "$vid" -map s:$strm "$file_path$lang/${vid%.*}$suffix" ;
            echo "ffmpeg -i $vid -map s:$strm $file_path$lang/${vid%.*}$suffix"
        fi
    done
done
cd-