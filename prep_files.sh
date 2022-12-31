#!/bin/sh
cd Orig
# Uncomment the following to extract subtitles from the 1080p source. Change the track selected as needed.
for i in *.mkv; do mkvextract tracks "$i" 4:"../Subs/${i%.*}TitlesnSigns.srt"; done
file_path="../Subs/"
suffix="TitlesnSigns.ass"
for i in *.mkv; do
    if test -f "$file_path${i%.*}$suffix"; then
        echo "$file_path${i%.*}$suffix already exists"
    else
        mkvextract tracks "$i" 4:"$file_path${i%.*}$suffix" ;
    fi
done

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
# Note: Chapter/Episode 15 has an extra audio track of Japanese with a different version of the "Be My Baby" song, so for this case you will have to use the above line as a standard and then extract the desired audio channel

# Uncomment the following to extract the video from the 1080p mkv source.
# file_path="../MP4/"
# suffix=".mp4"
# for i in *.mkv; do
#     if test -f "$file_path${i%.*}$suffix"; then
#         echo "$file_path${i%.*}$suffix already exists"
#     else
#         ffmpeg -i "$i" -map 0:v:0 "$file_path${i%.*}$suffix" ;
#     fi
# done

# If using the 720p source from YouTube, the mappings are a bit different, so use this command instead
# cd Orig720p
# for i in *.mkv; do ffmpeg -i "$i" -vn "../WAV/${i%.*}LR.wav" ;done

cd - 
