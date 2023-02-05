# In this case we assume Full-Subs has already been built to a satisfactory level, and we only want to add/change a few files

cd Subs/Full-Subs-additions

epnums=() # initialize array of episode numbers
for lang in *; do # loop through directories
    for sub in $lang/*.ass; do # loop through subtitle names, including the directory name
        echo "Subtitle file $sub"
        epnum=$(echo $sub | grep -E -o [0-9]{2})
        if [[ "$epnum" == "" ]]; then
            epnum="0$(echo $sub | grep -E -o [0-9]{1})"
        fi
        out_name="Ep${epnum:0:2}.ass"
        echo "Moving $sub to Full-Subs/$lang/$out_name..."
        mv -f "$sub" "../Full-Subs/$lang/$out_name"
        if [[ ! " ${epnums[*]} " =~ " ${epnum} " ]]; then # episode number not yet encountered
            epnums+=("${epnum}")
        fi  
    done
    # Now move all remaining files along with it, as they might be important font files
    cp -n $lang/* ../Full-Subs/$lang/
    rm $lang/*
done

cd ../Full-Subs

# All subtitles need to be formatted correctly for 1080p, but we assume much has already been done
for sub in $(find . -type f -name '*.ass'); do
    lang=$(echo $(basename $(dirname $sub)))
    if [[ $lang == "spa" ]]; then
        continue
    fi
    epnum=$(echo $sub | grep -E -o [0-9]{2})
    echo "Editing $sub"
    # First reset style lines
    python ../../find_replace_lines.py "$sub" "Style: Title," ""
    python ../../find_replace_lines.py "$sub" "Style: Titles1," ""
    python ../../find_replace_lines.py "$sub" "Style: Names," ""
    python ../../find_replace_lines.py "$sub" "Style: Bible-Verse," ""

    # Then put in place new style lines
    if [ $epnum -eq 1 ]; then
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

# Rename any fontfiles with whitespace
for lang in *; do
    cd "$lang"
    for font in *.ttf *.otf; do
        echo "Checking $font" 
        font_nws=${font// /_} # no white space
        if [ "$font" != "$font_nws" ]; then # Contains whitespace
            echo "Renaming $font to $font_nws"
            mv "$font" "$font_nws"
            fontname=$(basename -- "$font") # remove path
            fontname="${fontname%.*}" # remove extension
            fontname_nws=$(basename -- "$font_nws") # remove path
            fontname_nws="${fontname_nws%.*}" # remove extension
            # Replace all cases of that string in all subtitle files
            find -type f -exec sed -i "s/$fontname/$fontname_nws/g" {} +
        fi
    done
    cd ../ # back to Full-Subs
done


cd ../../ # back to top directory
# Rebuild the episodes with edited subs
for epnum in "${epnums[@]}"; do
echo "Rebuilding $epnum"
    sh rebuild1_mkv.sh "$epnum"
done