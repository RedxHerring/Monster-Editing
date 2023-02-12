# We will use this file to get the subs from the 1080p source from https://archive.org/details/Monster-Upscaled

cd Orig

file_path="../Subs/Orig-Subs/"
mkdir -p $file_path
suffix=".ass"
for vid in *.mkv; do
    for strm in {0..15}; do
        lang_text=$(ffprobe -v error -hide_banner -of default=noprint_wrappers=0 -print_format flat  -select_streams s:$strm -show_entries stream=index:stream_tags=language "$vid" | grep language)
        lang=$(echo $lang_text | cut -d '"' -f 2)
        if [[ "$lang" == "" ]]; then # nothing there
            echo "No more subtitle strams in this file"
            break
        fi
        tag_text=$(ffprobe -v error -show_streams -select_streams s:$strm "$vid" | grep :title)
        title=${tag_text##*=}
        
        echo "Processing video $vid, stream $strm, language $lang with title $title"
        mkdir -p "$file_path$lang/"
        # For the name we save, we will use EpXX.ass
        searchstring="Chapter " # note the space at the end
        rest=${vid#*$searchstring}
        epnum=$(cut -c 1-2<<< $rest)
        out_name="Ep$epnum"
        if [[ "$title" == *"Title"* ]]; then # titles and signs track
            out_name="$out_name-titlesnsigns"
        fi
        ffmpeg -y -loglevel error -i "$vid" -map s:$strm "$file_path$lang/$out_name$suffix"
        echo "ffmpeg -y -loglevel error -i "$vid" -map s:$strm "$file_path$lang/$out_name$suffix""
    done
done
cd "$file_path"
# Fix any missed namings in all files
 find -type f -exec sed -i "s/Schubert/Schuwald/g" {} +
 find -type f -exec sed -i "s/Runge/Lunge/g" {} +