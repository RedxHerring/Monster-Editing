# We will use this file to get the subs from the 480p source from https://nyaa.si/view/1611098

cd Monster.S01.480p.NF.WEB-DL.DDP2.0.x264-Emmid

file_path="../Subs/NFLX-Subs/"
mkdir -p $file_path
suffix=".ass"
for vid in *.mp4; do
    for strm in {0..15}; do
        lang_text=$(ffprobe -v error -hide_banner -of default=noprint_wrappers=0 -print_format flat  -select_streams s:$strm -show_entries stream=index:stream_tags=language $vid | grep language)
        lang=$(echo $lang_text | cut -d '"' -f 2)
        echo "Processing video $vid, stream $strm, language $lang"
        mkdir -p "$file_path$lang/"
        # For the name we save, we want to match the format used by the Upscale project, which is
        # EpXXepisodetitle.ass. The title is actually not contained, so we settle for EpXX.ass
        searchstring="E"
        rest=${vid#*$searchstring}
        epnum=$(cut -c 1-2<<< $rest)
        out_name="Ep$epnum"
        ffmpeg -y -i "$vid" -map s:$strm "$file_path$lang/$out_name$suffix"
    done
done

cd $file_path

# All subtitles need to be formatted correctly for 1080p
for sub in $(find . -type f -name '*.ass'); do
    echo "Editing $sub"
    epnum=$(echo $sub | grep -E -o [0-9]{2})
    python ../../find_replace_lines.py "$sub" "Audio File:" ""
    python ../../find_replace_lines.py "$sub" "Video File:" ""
    python ../../find_replace_lines.py "$sub" "PlayResX:" "PlayResX: 720" # using reduced size for compatibility
    python ../../find_replace_lines.py "$sub" "PlayResY:" "PlayResY: 480" # keep in mind this dramatically changes font scalin since it thinks there is a smaller cnavas than there actually is
    # Replace and edit Monster style name
    style0="Monster" # style to replace
    style1="Default" # style to replace with
    python ../../find_replace_lines.py "$sub" "Style: $style0," "Style: $style1,Jesaya Free,72,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,3.375,1.6875,2,20,20,90,1"
    sed -i "s/$style0,,/$style1,,/g" $sub

    # Replace all similar cases
    style0="Monster - Default" # style to replace
    python ../../find_replace_lines.py "$sub" "Style: $style0," "Style: $style1,Jesaya Free,72,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,3.375,1.6875,2,20,20,90,1"
    sed -i "s/$style0,,/$style1,,/g" $sub
    
    # Now we need to edit these cases we just replaced now that they're all matching, ie replace Default with Default but also add some lines
    style0="Titles1"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""
    style0="Default" # style to replace
    if [ $epnum -eq 1 ]; then
        python ../../find_replace_lines.py "$sub" "Style: $style1," "Style: $style1,Jesaya Free,28,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,1.5,0.75,2,10,10,10,1" \
        "Style: Title,Arial,32,&H00FFFFFF,&H00000000,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0.5,1,2,30,30,30,0" \
        "Style: Titles1,Times New Roman,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0.5,1,2,10,10,40,1" \
        "Style: Bible-Verse,X-Files,27,&H00908B87,&H000000FF,&H00F3F3F1,&H00000000,0,0,0,0,92,100,0,0,1,0,0,2,20,20,23,1"
        # Edit Bible verse in episode 1
        style0="Bible Verse" # style to replace
        style1="Bible-Verse"
        python ../../find_replace_lines.py "$sub" "Style: $style0," "Style: $style1,X-Files,12,&H00908B87,&H000000FF,&H00F3F3F1,&H00000000,0,0,0,0,92,100,0,0,1,0,0,2,20,20,23,1"
        sed -i "s/$style0,,/$style1,,/g" $sub
    else
        python ../../find_replace_lines.py "$sub" "Style: $style1," "Style: $style1,Jesaya Free,28,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,1.5,0.75,2,10,10,20,1" \
        "Style: Title,Arial,32,&H00FFFFFF,&H00000000,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0.5,1,2,30,30,30,0" \
        "Style: Titles1,Times New Roman,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0.5,1,2,10,10,40,1"
    fi
    # For Titles and Signs, make the style name a single word without dashes
    style0="Monster-Title"
    style1="Title"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""
    sed -i "s/$style0,,/$style1,,/g" $sub

    style0="Monster - Episode Title"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""
    sed -i "s/$style0,/$style1,/g" $sub

    style0="Episode"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""
    sed -i "s/$style0,,/$style1,,/g" $sub

    style0="Monster - Prologue"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""

    

    style0="X-Files"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""
    if [ $epnum -eq 1 ]; then
        sed -i "s/$style0,,/$style1,,/g" $sub
    fi
    python ../../shift_sub_times.py $sub -2 # move sub times 2 seconds earlier
done

find -type f -exec sed -i "s/Runge/Lunge/g" {} +
find -type f -exec sed -i "s/Schubert/Schuwald/g" {} +
