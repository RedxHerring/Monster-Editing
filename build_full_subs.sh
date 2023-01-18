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

# get new custom subs
mkdir -p gdrive-subs
unzip -q -d gdrive-subs drive-download*.zip

# Copy the NFLX-Subs as the baseline for the final product
cp -R NFLX-Subs Full-Subs

# Now add the english subs from https://nyaa.si/view/1610638
# The main addition here is it has titles and signs tracks, which are convenient for watching the dub.


# Now loop through the custom subs and replace the nflx subs with them
cd gdrive-subs

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
    python ../../find_replace_lines.py "$sub" "Audio File:" ""
    python ../../find_replace_lines.py "$sub" "Video File:" ""
    python ../../find_replace_lines.py "$sub" "PlayResX:" "PlayResX: 1440"
    python ../../find_replace_lines.py "$sub" "PlayResY:" "PlayResY: 1080"
    python ../../find_replace_lines.py "$sub" "Style: Monster," "Style: Monster,Jesaya Free,72,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,3.375,1.6875,2,20,20,90,1"
    python ../../find_replace_lines.py "$sub" "Style: Bible Verse," "Style: Bible Verse,X-Files,27,&H00908B87,&H000000FF,&H00F3F3F1,&H00000000,0,0,0,0,92,100,0,0,1,0,0,2,20,20,23,1"
    python ../../find_replace_lines.py "$sub" "Style: Default," "Style: Default,Jesaya Free,72,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,3.375,1.6875,2,20,20,90,1"
    python ../../find_replace_lines.py "$sub" "Style: Monster - Default," "Style: Monster - Default,Jesaya Free,72,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,3.375,1.6875,2,20,20,90,1"
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