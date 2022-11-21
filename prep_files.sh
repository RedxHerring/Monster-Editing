#!/bin/sh
cd Orig
# Uncomment the following to extract subtitles from the 1080p source. Change the track selected as needed.
# for i in *.mkv; do mkvextract tracks "$i" 4:"../Subs/${i%.*}TitlesnSigns.srt"; done

# Uncomment the following to extract the English audio from the 1080p mkv source. Change the mapping as needed to select different languages
file_path="../WAV/"
suffix="LR.wav"
for i in *.mkv; do
    if test -f "$file_path${i%.*}$suffix"; then
        echo "$file_path${i%.*}$suffix already exists"
    else
        ffmpeg -i "$i" -map 0:2 "$file_path${i%.*}$suffix" ;
    fi
done
cd -
# Note: Chapter/Episode 15 has an extra audio track of Japanese with a different version of the "Be My Baby" song, so for this case you will have to use the above line as a standard and then extract the desired audio channel

# If using the 720p source from YouTube, the mappings are a bit different, so use this command instead
# cd Orig720p
# for i in *.mkv; do ffmpeg -i "$i" -vn "../WAV/${i%.*}LR.wav" ;done
# cd - 
