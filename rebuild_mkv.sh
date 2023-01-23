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
    ninputs=2 # assume 2 video inputs

    # Set up inputs.txt, which will contain video and subtitle inputs
    rm -f inputs.txt
    # Set up mappings.txt, which will contain subtitle mappings
    rm -f mappings.txt
    # Set up map-fonts.txt, which will contain font streams from the original input
    rm -f map-fonts.txt
    # Set up outputs.txt, which will contain video and subtitle output parameters
    rm -f outputs.txt
    # Search Full-Subs for ones matching the episode
    nsubs=0
    for sub in $(find Subs/Full-Subs -type f -name '*.ass'); do
        subepnum=$(echo $sub | grep -E -o [0-9]{2})
        if [[ "$epnum" == "$subepnum" ]]; then # valid episode
            # find language
            lang=$(echo $(basename $(dirname $sub)))
            if [[ $lang == "ara" ]]; then
                sub_text="Arabic"
            elif [[ $lang == "deu" ]]; then
                sub_text="Dutch"
            elif [[ $lang == "eng" ]]; then
                sub_text="English"
            elif [[ $lang == "ind" ]]; then
                sub_text="Indonesian"
            elif [[ $lang == "ita" ]]; then
                sub_text="Italian"
            elif [[ $lang == "msa" ]]; then
                sub_text="Malay"
            elif [[ $lang == "pol" ]]; then
                sub_text="Polish"
            elif [[ $lang == "por" ]]; then
                sub_text="Portuguese"
            elif [[ $lang == "ron" ]]; then
                sub_text="Romanian"
            elif [[ $lang == "spa" ]]; then
                sub_text="Spanish"
            elif [[ $lang == "tha" ]]; then
                sub_text="Thai"
            elif [[ $lang == "tur" ]]; then
                sub_text="Turkish"
            elif [[ $lang == "vie" ]]; then
                sub_text="Vietnamese"
            elif [[ $lang == "jpn" ]]; then
                sub_text="Japanese"
            elif [[ $lang == "zho" ]]; then
                sub_text="Chinese"
            fi
            if [[ "$lang" == "eng" ]] && [[ "$sub" != *"itles"* ]]; then
                idefault=$nsubs # pick this subs track as default in ffmpeg
            elif [[ "$lang" == "eng" ]] && [[ "$sub" == *"itles"* ]]; then
                sub_text="$sub_text-Titles+Signs"
            fi
            echo "Found $sub_text subtitles"
            echo "-metadata:s:s:$nsubs language=$lang -metadata:s:s:$nsubs title=$sub_text" >> outputs.txt
            echo "-i $sub" >> inputs.txt
            echo "-map $ninputs" >> mappings.txt
            nsubs=$(expr $nsubs + 1) # iterate after since titles and signs will be added
            ninputs=$(expr $ninputs + 1)
        fi
    done
    echo "Adding $nsubs additional subtitle files"

    # Now we need to find which streams have fonts that we need to copy over
    nfonts=0
    for fontline in $(ffprobe -v error -hide_banner -of default=noprint_wrappers=0 -print_format flat -show_entries stream=index:stream_tags=mimetype "$mkv" | grep font); do
        strm=$(echo $fontline | grep -E -o [0-9]{2}) # assume 2-digit number
        if [[ "$strm" == "" ]]; then # actually 1 digit
            strm="$(echo $fontline | grep -E -o [0-9]{1})"
        fi
        echo "-map 0:$strm" >> map-fonts.txt
        nfonts=$(expr $nfonts + 1)
    done
    echo "Adding $nfonts font files from original mkv"
    
    # Now we need to add additional font files from Full-Subs
    for font in $(find Subs/Full-Subs \( -iname "*.ttf" -or -iname "*.otf" \)); do
        if [[ $font == *"Subs/Full-Subs/"* ]]; then # extra check since it seems to pick up extra files otherwise
            echo "-attach "$font"" >> inputs.txt
            echo "-metadata:s:t:$nfonts mimetype=application/x-truetype-font" >> outputs.txt
            nfonts=$(expr $nfonts + 1) # note since streams are 0-indexed we make sure to iterate after using the value as the index
        fi
    done
    echo "Adding $nfonts additional font files"

    #Now run actual ffmpeg command
    if [[ "$epnum" == "15" ]]; then # extra audio file
        echo "ffmpeg -y -init_hw_device qsv=hw -filter_hw_device hw -i $mkv -i $SAVmkv $(cat inputs.txt | xargs echo) -map 0:v -map 0:a:0 -map 0:a:1 -map 1:a:1 -map 0:s:1 $(cat map-fonts.txt | xargs echo) -c:v av1_qsv -c:a libopus -c:s copy -map_metadata -1 -map_metadata:s:t 0:s:t $(cat outputs.txt | xargs echo) $outmkv"
        # ffmpeg params
        ffmpeg -y -loglevel warning -init_hw_device qsv=hw -filter_hw_device hw \
        -i "$mkv" -i "$SAVmkv" $(cat inputs.txt | xargs echo) \
        -map 0:v:0 -map 1:a:0 -map 0:a:1 -map 1:a:1 -map 0:t $(cat mappings.txt | xargs echo) $(cat map-fonts.txt | xargs echo) \
        -c:v av1_qsv -c:a libopus -c:s copy -c:t copy \
        -map_metadata 0 -map_metadata:s:v 0:s:v -map_metadata:s:a:0 1:s:a:0 -map_metadata:s:a:1 0:s:a:1 -map_metadata:s:a:2 1:s:a:1 -map_metadata:s:t 0:s:t $(cat outputs.txt | xargs echo) \
        -disposition:s:s:"$idefault" forced "$outmkv"
    else
        echo "ffmpeg -y -init_hw_device qsv=hw -filter_hw_device hw -i $mkv -i $SAVmkv $(cat inputs.txt | xargs echo) -map 0:v -map 1:a:0 -map 1:a:1 $(cat map-fonts.txt | xargs echo) -c:v av1_qsv -c:a libopus  -c:t copy -map_metadata 0 -map_metadata:s:v 0:s:v -map_metadata:s:a:0 1:s:a:0 -map_metadata:s:a:1 1:s:a:1 -map_metadata:s:t 0:s:t $(cat outputs.txt | xargs echo)  $outmkv"
        # ffmpeg params
        ffmpeg -y -loglevel warning -init_hw_device qsv=hw -filter_hw_device hw \
        -i "$mkv" -i "$SAVmkv" $(cat inputs.txt | xargs echo) \
        -map 0:v:0 -map 1:a:0 -map 1:a:1 -map 0:t $(cat mappings.txt | xargs echo) $(cat map-fonts.txt | xargs echo) \
        -c:v av1_qsv -c:a libopus -c:s copy -c:t copy \
        -map_metadata 0 -map_metadata:s:v 0:s:v -map_metadata:s:a:0 1:s:a:0 -map_metadata:s:a:1 1:s:a:1 -map_metadata:s:t 0:s:t $(cat outputs.txt | xargs echo) \
        -disposition:s:s:"$idefault" forced "$outmkv"
    fi

done



# guide for having a bunch of inputs into ffmpeg https://superuser.com/questions/242584/how-to-provide-multiple-input-to-ffmpeg
# guide to add fonts https://superuser.com/questions/1586716/how-to-add-fonts-to-mkv-container-with-ffmpeg
# good guide for librav1e https://askubuntu.com/questions/1189174/how-do-i-use-ffmpeg-and-rav1e-to-create-high-quality-av1-files

