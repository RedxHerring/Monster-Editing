# Assume we have extracted the most recent version of the subs from 
# https://drive.google.com/drive/folders/1OHbgqLScQ8VOe4kA-1lHASBomXwfZTvP
# into Subs/Finalized Subtitles
# We also assume that we have the netflix subs from the NFLX rip in
# Subs/NFLX-Subs, per extract_nflx_subs.sh

cd Subs
unzip Finalized*.zip
# Copy the NFLX-Subs as the baseline for the final product
cp -R NFLX-Subs Full-Subs

# Now loop through the custom subs and replace the nflx subs with them
cd Finalized\ Subtitles/
# First extract the spanish subs compressed with 7z
for compressed in *.7z; do
    mkdir temp
    7z x "$compressed" -otemp > nul
    cd temp
    for sub in *.ass; do
        echo "Spanish sub $sub"
        # Need to find episode number using fact that only number in name is episode number
        epnum=$(echo $sub | grep -E -o [0-9]{2})
        if [[ "$epnum" == "" ]]; then # empty string
            epnum="0$(echo $sub | grep -E -o [0-9]{1})"
        fi
        if [ ${#epnum} -eq 0 ]; then # still empty string
            continue
        fi
        out_name="Ep${epnum:0:2}.ass" # take first 2 numbers for episode in case there are other numbers in name ie 511
        echo "Moving $out_name..."
        mv -f "$sub" "../../Full-Subs/spa/$out_name"
    done
    cd ../
    cp -n temp/* ../Full-Subs/spa/
    rm -r temp
    rm "$compressed"
done

# Now put the english subs in eng/
for sub in *.ass; do
    echo "English sub $sub"
    epnum=$(echo $sub | grep -E -o [0-9]{2})
    if [[ "$epnum" == "" ]]; then
        epnum="0$(echo $sub | grep -E -o [0-9]{1})"
    fi
    out_name="Ep${epnum:0:2}.ass"
    echo "Moving $out_name..."
    mv -f "$sub" "../Full-Subs/eng/$out_name"
done
cd ../ # back to Subs/
rm -r Finalized\ Subtitles/

# All subtitles need to be formatted correctly for 1080p
for sub in $(find Full-Subs -type f -name '*.ass'); do
    python ../find_replace_lines.py "$sub" "Audio File:" ""
    python ../find_replace_lines.py "$sub" "Video File:" ""
    python ../find_replace_lines.py "$sub" "PlayResX:" "PlayResX: 1440"
    python ../find_replace_lines.py "$sub" "PlayResY:" "PlayResY: 1080"
    python ../find_replace_lines.py "$sub" "Style: Monster," "Style: Default,Jesaya Free,72,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,3.375,1.6875,2,20,20,90,1"
    python ../find_replace_lines.py "$sub" "Style: Bible Verse," "Style: Bible Verse,X-Files,27,&H00908B87,&H000000FF,&H00F3F3F1,&H00000000,0,0,0,0,92,100,0,0,1,0,0,2,20,20,23,1"
    python ../find_replace_lines.py "$sub" "Style: Default," "Style: Default,Jesaya Free,72,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,3.375,1.6875,2,20,20,90,1"
    python ../find_replace_lines.py "$sub" "Style: Monster - Default," "Style: Monster - Default,Jesaya Free,72,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,3.375,1.6875,2,20,20,90,1"
done

zip -r Full-Subs.zip Full-Subs > nul
rm nul