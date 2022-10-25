#!/bin/sh
cd Orig
# for i in *.mkv; do ffmpeg -i "$i" -map 0:v -c copy "../MP4/${i%.*}.mp4" ;done
#for i in *.mkv; do mkvextract tracks "$i" 3:"../Subs/${i%.*}1.srt"; done
# for i in *.mkv; do mkvextract tracks "$i" 4:"../Subs/${i%.*}TitlesnSigns.srt"; done
#for i in *.mkv; do mkvextract tracks "$i" 5:"../Subs/${i%.*}3.srt"; done
#for i in *.mkv; do mkvextract tracks "$i" 6:"../Subs/${i%.*}4.srt"; done
# for i in *.mkv; do ffmpeg -i "$i" -vn -an -codec:s:0 srt "../Subs/${i%.mkv}.srt"; done
# for i in *.mkv; do ffmpeg -i "$i" -vn -an -codec:s:0 ass "../Subs/${i%.mkv}.ass"; done
for i in *.mkv; do ffmpeg -i "$i" -map 0:2 "../WAV/${i%.*}LR.wav" ;done
cd -
