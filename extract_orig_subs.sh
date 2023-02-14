# We will use this file to get the subs from the 1080p source from https://archive.org/details/Monster-Upscaled

cd Orig

file_path="../Subs/Orig-Subs/"
rm -r $file_path
mkdir -p $file_path
suffix=".ass"
for vid in *.mkv; do
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
        # For the name we save, we will use EpXX.ass
        searchstring="Chapter " # note the space at the end
        rest=${vid#*$searchstring}
        epnum=$(cut -c 1-2<<< $rest)
        out_name="Ep$epnum"
        if [[ "$title" == *"Title"* ]]; then # titles and signs track
            out_name="$out_name-titlesnsigns"
        fi
        ffmpeg -n -loglevel error -i "$vid" -map s:$strm "$file_path$lang/$out_name$suffix"
        echo "ffmpeg -n -loglevel error -i "$vid" -map s:$strm "$file_path$lang/$out_name$suffix""
    done
done
cd "$file_path"
# Fix any missed namings in all files
find -type f -exec sed -i "s/Schubert/Schuwald/g" {} +
find -type f -exec sed -i "s/Runge/Lunge/g" {} +
find -type f -exec sed -i "s/Names1,,/Names,,/g" {} +
find -type f -exec sed -i "s/Names2,,/Names,,/g" {} +
find -type f -exec sed -i "s/Location,,/Names,,/g" {} +
find -type f -exec sed -i "s/Monster-Title,,/Title,,/g" {} +

for sub in $(find . -type f -name '*.ass'); do
    epnum=$(echo $sub | grep -E -o [0-9]{2})
    echo "Editing $sub"
    # First reset style lines
    python ../../find_replace_lines.py "$sub" "Style: Title," ""
    python ../../find_replace_lines.py "$sub" "Style: Titles1," ""
    python ../../find_replace_lines.py "$sub" "Style: Names," ""
    python ../../find_replace_lines.py "$sub" "Style: Names1," ""
    python ../../find_replace_lines.py "$sub" "Style: Names2," ""
    python ../../find_replace_lines.py "$sub" "Style: Location," ""
    
    python ../../find_replace_lines.py "$sub" "Style: Monster-Title," ""

    # Then put in place new style lines
    if [ $epnum -eq 1 ]; then
        python ../../find_replace_lines.py "$sub" "Style: Bible-Verse," ""
        python ../../find_replace_lines.py "$sub" "Style: X-Files," ""
        python ../../find_replace_lines.py "$sub" "Style: Default," "Style: Default,Jesaya Free,28,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,1.5,0.75,2,10,10,10,1" \
        "Style: Title,Arial,40,&H00FFFFFF,&H00000000,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0.5,1,2,30,30,25,0" \
        "Style: Titles1,Times New Roman,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0.5,1,2,10,10,40,1" \
        "Style: Names,Arial,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0,0,2,10,10,20,1" \
        "Style: Bible-Verse,X-Files,13,&H00908B87,&H000000FF,&H00F3F3F1,&H00000000,0,0,0,0,92,100,0,0,1,0,0,2,20,20,23,1"
    else
        python ../../find_replace_lines.py "$sub" "Style: Default," "Style: Default,Jesaya Free,28,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,1.5,0.75,2,10,10,20,1" \
        "Style: Title,Arial,40,&H00FFFFFF,&H00000000,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0.5,1,2,30,30,25,0" \
        "Style: Titles1,Times New Roman,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0.5,1,2,10,10,40,1" \
        "Style: Names,Arial,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0,0,2,10,10,20,1"
    fi   
    
    # Remove excessive empty lines
    echo "$(cat -s $sub)" > $sub
done