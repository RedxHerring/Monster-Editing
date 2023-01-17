# Loop through Orig, grab the video and audio, then add

SAVdir='Monster [Ultimate Collection] By Kira [SEV]/Monster [2004-2005] DVDRip x265 AC-3 DD 2.0 Kira [SEV]/'

for mkv in Orig/*.mkv; do
    vid_name=${mkv:5}
    echo "Preparing $vid_name..."
    epnum=$(echo $vid_name | grep -E -o [0-9]{2})
    epnum=${epnum:0:2}
    SAVmkv=$(ls "$SAVdir" | grep "Chapter $epnum")
    echo "Found $SAVmkv, will use for english dub"
    SAVmkv="$SAVdir$SAVmkv"
    outmkv="Output/$vid_name"

    # Set up inputs.txt, which will contain video and subtitle inputs
    rm -f inputs.txt
    # Set up map-fonts.txt, which will contain font streams from the original input
    rm -f map-fonts.txt
    # Set up outputs.txt, which will contain video and subtitle output parameters
    rm -f outputs.txt
    # Search Full-Subs for ones matchign the episode
    nsubs=0
    for sub in $(find Subs/Full-Subs -type f -name '*.ass'); do
        subepnum=$(echo $sub | grep -E -o [0-9]{2})
        if [[ "$epnum" == "$subepnum" ]]; then
            echo "-i $sub" >> inputs.txt
            nsubs=$(expr $nsubs + 1)
        fi
    done
    echo "Adding $nsubs additional subtitle files"

    # Now we need to find which streams have fonts that we need to copy over
    nfontsi=0
    for fontline in $(ffprobe -v error -hide_banner -of default=noprint_wrappers=0 -print_format flat -show_entries stream=index:stream_tags=mimetype "$mkv" | grep font); do
        strm=$(echo $fontline | grep -E -o [0-9]{2}) # assume 2-digit number
        if [[ "$strm" == "" ]]; then # actually 1 digit
            strm="$(echo $fontline | grep -E -o [0-9]{1})"
        fi
        echo "-map 0:$strm" >> map-fonts.txt
        nfontsi=$(expr $nfontsi + 1)
    done
    echo "Adding $nfontsi font files from original mkv"
    
    # Now we need to add additional font files from Full-Subs
    nfonts=0
    for font in $(find Subs/Full-Subs \( -iname "*.ttf" -or -iname "*.otf" \)); do
        if [[ $font == *"Subs/Full-Subs/"* ]]; then # extra check since it seems to pick up extra files otherwise
            echo "-attach $font" >> inputs.txt
            echo "-metadata:s:t:$nfonts mimetype=application/x-truetype-font" >> outputs.txt
            nfonts=$(expr $nfonts + 1)
        fi
    done
    echo "Adding $nfonts additional font files"
    # if [[ "$epnum" == "15" ]]; then # extra audio file
    #     ffmpeg -i "$mkv" -i "$SAVmkv" \ # video inputs
    #     'cat inputs.txt | xargs echo'\
    #     -map 0:v -map 0:a:0 -map 0:a:1 -map 1:a:1 -map 0:s:1\ # mapping
    #     -c:v librav1e -speed 2 # video encoding
    # else

    # fi

done



# guide for having a bunch of inputs into ffmpeg https://superuser.com/questions/242584/how-to-provide-multiple-input-to-ffmpeg
# guide to add fonts https://superuser.com/questions/1586716/how-to-add-fonts-to-mkv-container-with-ffmpeg
# good guide for librav1e https://askubuntu.com/questions/1189174/how-do-i-use-ffmpeg-and-rav1e-to-create-high-quality-av1-files

