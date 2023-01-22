# Assume we have extracted the most recent version of the subs from 
# https://drive.google.com/drive/folders/1OHbgqLScQ8VOe4kA-1lHASBomXwfZTvP
# into Subs/Finalized Subtitles
# We also assume that we have the netflix subs from the NFLX rip in
# Subs/NFLX-Subs, per extract_nflx_subs.sh

cd Subs
# cleanup, if necessary
rm -rf Full-Subs
rm -f Full-Subs.zip
rm -rf gdrive-subs

# Copy the NFLX-Subs as the baseline for the final product
cp -R NFLX-Subs Full-Subs

# Now loop through Subs-Orig and get the Subs from there. We assume this is from extract_orig_subs.sh, and therefore has predictable filename formatting
cd Orig-Subs
for lang in *; do # loop through directories
    for sub in $lang/*.ass; do # loop through subtitle names, including the directory name
        nlines=$(wc -l < $sub)
        if [[ $nlines -lt 50 ]] && [[ "$sub" != *"itle"* ]]; then
            echo "Only $nlines lines in $sub, presumed empty, skipping" 
        else
            echo "Moving $sub to Full-Subs/$sub..."
            cp -f "$sub" "../Full-Subs/$sub"
        fi
    done
    # Now move all remaining files along with it, as they might be important font files
    cp -n $lang/* ../Full-Subs/$lang/
done
cd ../

# get new custom subs
mkdir -p gdrive-subs
# Only one of the following should work, and bash scripts don't end on errors
unzip -q -d gdrive-subs drive-download*.zip
unzip -q -d gdrive-subs Finalized*.zip

# Now loop through the custom subs and replace the nflx subs with them
cd gdrive-subs
if  [[ ! -d "eng" ]]; then # need to go down by one more directory
    cd *
fi
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
    done
    # Now move all remaining files along with it, as they might be important font files
    cp -n $lang/* ../Full-Subs/$lang/
done

cd ../Full-Subs 

# All subtitles need to be formatted correctly for 1080p
for sub in $(find . -type f -name '*.ass'); do
    epnum=$(echo $sub | grep -E -o [0-9]{2})
    python ../../find_replace_lines.py "$sub" "Audio File:" ""
    python ../../find_replace_lines.py "$sub" "Video File:" ""
    python ../../find_replace_lines.py "$sub" "PlayResX:" "PlayResX: 720" # using reduced size for compatibility
    python ../../find_replace_lines.py "$sub" "PlayResY:" "PlayResY: 480" # keep in mind this dramatically changes font scalin since it thinks there is a smaller cnavas than there actually is
    # Replace and edit Monster style name
    style0="Monster" # style to replace
    style1="Default" # style to replace with
    python ../../find_replace_lines.py "$sub" "Style: $style0," "Style: $style1,Jesaya Free,72,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,3.375,1.6875,2,20,20,90,1"
    find -type f -exec sed -i "s/$style0,,/$style1,,/g" {} +

    # Replace all similar cases
    style0="Monster - Default" # style to replace
    python ../../find_replace_lines.py "$sub" "Style: $style0," "Style: $style1,Jesaya Free,72,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,3.375,1.6875,2,20,20,90,1"
    find -type f -exec sed -i "s/$style0,,/$style1,,/g" {} +
    
    # Now we need to edit these cases we just replaced now that they're all matching, ie replace Default with Default but also add some lines
    style0="Titles1"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""
    style0="Default" # style to replace
    if [ $epnum -eq 1 ]; then
        python ../../find_replace_lines.py "$sub" "Style: $style1," "Style: $style1,Jesaya Free,28,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,1.5,0.75,2,10,10,10,1" \
        "Style: Title,Arial,32,&H00FFFFFF,&H00000000,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0.5,1,2,30,30,30,0" \
        "Style: Titles1,Times New Roman,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0.5,1,2,10,10,40,1" \
        "Style: Bible-Verse,X-Files,27,&H00908B87,&H000000FF,&H00F3F3F1,&H00000000,0,0,0,0,92,100,0,0,1,0,0,2,20,20,23,1"
    else
        python ../../find_replace_lines.py "$sub" "Style: $style1," "Style: $style1,Jesaya Free,28,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,1.5,0.75,2,10,10,20,1" \
        "Style: Title,Arial,32,&H00FFFFFF,&H00000000,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0.5,1,2,30,30,30,0" \
        "Style: Titles1,Times New Roman,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0.5,1,2,10,10,40,1"
    fi
    # For Titles and Signs, make the style name a single word without dashes
    style0="Monster-Title"
    style1="Title"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""
    find -type f -exec sed -i "s/$style0,,/$style1,,/g" {} +

    style0="Monster - Episode Title"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""
    find -type f -exec sed -i "s/$style0,/$style1,/g" {} +

    style0="Episode"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""
    find -type f -exec sed -i "s/$style0,,/$style1,,/g" {} +

    style0="Monster - Prologue"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""

    # Edit Bible verse in episode 1
    style0="Bible Verse" # style to replace
    style1="Bible-Verse"
    python ../../find_replace_lines.py "$sub" "Style: $style0," "Style: $style1,X-Files,12,&H00908B87,&H000000FF,&H00F3F3F1,&H00000000,0,0,0,0,92,100,0,0,1,0,0,2,20,20,23,1"
    find -type f -exec sed -i "s/$style0,,/$style1,,/g" {} +

    style0="X-Files"
    python ../../find_replace_lines.py "$sub" "Style: $style0," ""
    if [ $epnum -eq 1 ]; then
        find -type f -exec sed -i "s/$style0,,/$style1,,/g" {} +
    fi
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

# Remove languages that produce bugs in rebuild_mkv.sh
rm -r zho
rm -r jpn

cd ../ # back to Subs/
rm -r gdrive-subs

zip -r Full-Subs.zip Full-Subs > nul
rm nul