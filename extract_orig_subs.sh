# We will use this file to get the subs from the 1080p source from https://archive.org/details/Monster-Upscaled

cd Orig

file_path="../Subs/Orig-Subs-unedited/"
rm -r $file_path
mkdir -p $file_path
suffix=".ass"
for vid in *.mkv; do
    # For the name we save, we will use EpXX.ass
    searchstring="Chapter " # note the space at the end
    rest=${vid#*$searchstring}
    epnum=$(cut -c 1-2<<< $rest)
    for strm in {0..15}; do
        lang_text=$(ffprobe -v error -hide_banner -of default=noprint_wrappers=0 -print_format flat  -select_streams s:$strm -show_entries stream=index:stream_tags=language "$vid" | grep language)
        lang=$(echo $lang_text | cut -d '"' -f 2)
        if [[ "$lang" == "" ]]; then # nothing there
            echo "No more subtitle streams in this file"
            break
        fi
        tag_text=$(ffprobe -v error -show_streams -select_streams s:$strm "$vid" | grep :title)
        title=${tag_text##*=}
        
        echo "Processing video $vid, stream $strm, language $lang with title $title"
        mkdir -p "$file_path$lang/"
        out_name="Ep$epnum"
        if [[ "$title" == *"Title"* ]]; then # titles and signs track
            out_name="$out_name-titlesnsigns"
        fi
        full_out_name="$file_path$lang/$out_name$suffix"
        ffmpeg -n -loglevel error -i "$vid" -map s:$strm "$full_out_name"
        echo "ffmpeg -n -loglevel error -i $vid -map s:$strm $full_out_name"
    done
done
cd ../Subs
rm -r Orig-Subs-edited
cp -r Orig-Subs-unedited Orig-Subs-edited
cd Orig-Subs-edited
sh ../../edit_subs_in_dir.sh .
