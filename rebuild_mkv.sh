# Given an epnum in the input, rebuild that mkv

function get_language() { # input shorthand $lang and get full language name
    if [[ $1 == "ara" ]]; then
        echo "Arabic"
    elif [[ $1 == "bra" ]]; then
        echo "Brazilian-Portuguese"
    elif [[ $1 == "deu" ]]; then
        echo "German"
    elif [[ $1 == "eng" ]]; then
        echo "English"
    elif [[ $1 == "fre" ]]; then
        echo "French"
    elif [[ $1 == "ind" ]]; then
        echo "Indonesian"
    elif [[ $1 == "ita" ]]; then
        echo "Italian"
    elif [[ $1 == "msa" ]]; then
        echo "Malay"
    elif [[ $1 == "pol" ]]; then
        echo "Polish"
    elif [[ $1 == "por" ]]; then
        echo "Portuguese"
    elif [[ $1 == "ron" ]]; then
        echo "Romanian"
    elif [[ $1 == "spa" ]]; then
        echo "Spanish"
    elif [[ $1 == "tha" ]]; then
        echo "Thai"
    elif [[ $1 == "tur" ]]; then
        echo "Turkish"
    elif [[ $1 == "vie" ]]; then
        echo "Vietnamese"
    elif [[ $1 == "jpn" ]]; then
        echo "Japanese"
    elif [[ $1 == "zho" ]]; then
        echo "Chinese"
    fi
}

pwd0=$(pwd)

epnum=$1 # episode number should be first and only argument
Origmkv=$(ls Orig/ | grep "Chapter $epnum")
echo "Found $Origmkv, will use for high-res video source"
Origmkv="Orig/$Origmkv"
vid_name=${Origmkv:5}
echo "Preparing $vid_name..."

outmkv="Output/$vid_name"
ninputs=1 # assume 1 video input: 1080p upscaled
# Set up inputs.txt, which will contain video and subtitle inputs
rm -f inputs.txt
# Set up mappings.txt, which will contain subtitle mappings
rm -f mappings.txt
# Set up attach-fonts.txt, which will contain font files in Subs/Full-Subs, which will be added before fonts streams from video inputs
rm -f attach-fonts.txt
# Set up outputs.txt, which will contain video and subtitle output metadata
rm -f outputs.txt

# Add Audio tracks in defined order so we can add the write metadata titles later
nainputs=0
cd Audio
for lang in *; do
    if [ ! -f "Audio/$lang/Ep$epnum.flac" ]; then # dub flac not available, might not be a lnaguage dir, ie music instead, etc.
        continue
    fi
    echo "-i Audio/$lang/Ep$epnum.flac" >> $pwd0/inputs.txt
    echo "-map $ninputs" >> $pwd0/mappings.txt
    if [[ $lang == "deu" ]]; then # need to use different codec for 5.1
        echo "-c:a:$nainputs libvorbis -q:a:$nainputs 7" >> $pwd0/mappings.txt
    else
        echo "-c:a:$nainputs libopus -b:a:$nainputs 108000" >> $pwd0/mappings.txt
    fi
    if [[ "$lang" == "eng" ]]; then
        iadefault=$nainputs
        echo "Found default audio track number $iadefault in Audio/$lang/Ep$epnum.flac"
    fi
    echo "-metadata:s:a:$nainputs language=$lang -metadata:s:a:$nainputs title=$(get_language $lang)-Audio" >> $pwd0/outputs.txt
    ninputs=$(expr $ninputs + 1)
    nainputs=$(expr $nainputs + 1)
    if [[ "$epnum" == "15" ]] && [[ $lang == "jpn" ]]; then # extra audio file
        echo "-i Audio/jpn/Ep15Orig.flac" >> $pwd0/inputs.txt
        echo "-map $ninputs" >> $pwd0/mappings.txt
        echo "-metadata:s:a:$nainputs language=jpn -metadata:s:a:$nainputs title=Japanese-Broadcast-Audio" >> $pwd0/outputs.txt
        ninputs=$(expr $ninputs + 1)
        nainputs=$(expr $nainputs + 1)
    fi
done

# Search Full-Subs for subtitle files matching the episode
nsubs=0
nfonts=0
cd $pwd0/Subs/Full-Subs/
for lang in *; do
    echo "Looking for $lang subtitle files." 
    cd $pwd0/Subs/Full-Subs/$lang
    for sub in *.ass; do
        subepnum=$(echo $sub | grep -E -o [0-9]{2})
        if [[ "$epnum" == "$subepnum" ]]; then # valid episode
            sub_text=$(get_language $lang)
            if [[ "$lang" == "eng" ]] && [[ "$sub" == *"itles"* ]]; then
                isdefault=$nsubs # pick this subs track as default in ffmpeg
                echo "Found default subtitle track number $isdefault in Subs/Full-Subs/$lang/Ep$epnum.ass"
            fi
            if [[ "$lang" == "eng" ]] && [[ "$sub" == *"itles"* ]]; then
                sub_text="$sub_text-Titles+Signs"
            elif [[ "$lang" == "jpn" ]] && [[ "$sub" == *"roadcast"* ]]; then
                sub_text="$sub_text-Original_Broadcast"
            fi
            echo "Found $sub_text subtitles"
            echo "-metadata:s:s:$nsubs language=$lang -metadata:s:s:$nsubs title=$sub_text" >> $pwd0/outputs.txt
            echo "-i $pwd0/Subs/Full-Subs/$lang/$sub" >> $pwd0/inputs.txt
            echo "-map $ninputs" >> $pwd0/mappings.txt
            nsubs=$(expr $nsubs + 1) # iterate after since titles and signs will be added
            ninputs=$(expr $ninputs + 1)
        fi
    done
    # Within this directory look for ttf, TTF and otf files
    for font in *.TTF; do
        if [ "${#font}" -gt 5 ]; then
            echo
            echo "-attach $pwd0/Subs/Full-Subs/$lang/$font -metadata:s:t:$nfonts filename=$font -metadata:s:t:$nfonts mimetype=application/x-truetype-font" >> $pwd0/attach-fonts.txt
            nfonts=$(expr $nfonts + 1)
        fi
    done
    for font in *.ttf; do
        if [ "${#font}" -gt 5 ]; then
            echo
            echo "-attach $pwd0/Subs/Full-Subs/$lang/$font -metadata:s:t:$nfonts filename=$font -metadata:s:t:$nfonts mimetype=application/x-truetype-font" >> $pwd0/attach-fonts.txt
            nfonts=$(expr $nfonts + 1)
        fi
    done
    for font in *.OTF; do
        if [ "${#font}" -gt 5 ]; then
            echo "-attach $pwd0/Subs/Full-Subs/$lang/$font -metadata:s:t:$nfonts filename=$font -metadata:s:t:$nfonts mimetype=application/vnd.ms-opentype" >> $pwd0/attach-fonts.txt
            nfonts=$(expr $nfonts + 1)
        fi
    done
    for font in *.otf; do
        if [ "${#font}" -gt 5 ]; then
            echo "-attach $pwd0/Subs/Full-Subs/$lang/$font -metadata:s:t:$nfonts filename=$font -metadata:s:t:$nfonts mimetype=application/vnd.ms-opentype" >> $pwd0/attach-fonts.txt
            nfonts=$(expr $nfonts + 1)
        fi
    done
done
cd $pwd0
echo "Adding $nsubs subtitle files"

# Now run actual ffmpeg command
echo "ffmpeg -y -loglevel warning -init_hw_device qsv=hw -filter_hw_device hw -i $Origmkv $(cat inputs.txt | xargs echo) \
-map 0:v:0 $(cat mappings.txt | xargs echo) $(cat attach-fonts.txt | xargs echo) -map 0:t \
-c:v hevc_qsv -preset veryslow -global_quality:v 21 -look_ahead 1 -scenario:v archive -pix_fmt p010le  -c:s copy -c:t copy \
-map_metadata 0 -map_metadata:s:v:0 0:s:v:0 -map_metadata:s:t 0:s:t $(cat outputs.txt | xargs echo) \
-disposition:a:$iadefault forced -disposition:s:$isdefault forced $outmkv"
# ffmpeg params
ffmpeg -y -loglevel warning -init_hw_device qsv=hw -filter_hw_device hw -i "$Origmkv" $(cat inputs.txt | xargs echo) \
-map 0:v:0 $(cat mappings.txt | xargs echo) $(cat attach-fonts.txt | xargs echo) -map 0:t \
-c:v hevc_qsv -preset veryslow -global_quality:v 21 -look_ahead 1 -scenario:v archive -pix_fmt p010le  -c:s copy -c:t copy \
-map_metadata 0 -map_metadata:s:v:0 0:s:v:0 -map_metadata:s:t 0:s:t $(cat outputs.txt | xargs echo) \
-disposition:a:"$iadefault" forced -disposition:s:"$isdefault" forced "$outmkv"


# guide for having a bunch of inputs into ffmpeg https://superuser.com/questions/242584/how-to-provide-multiple-input-to-ffmpeg
# guide to add fonts https://superuser.com/questions/1586716/how-to-add-fonts-to-mkv-container-with-ffmpeg

