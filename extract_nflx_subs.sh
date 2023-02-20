# We will use this file to get the subs from the 480p source from https://nyaa.si/view/1611098

cd Monster.S01.480p.NF.WEB-DL.DDP2.0.x264-Emmid

file_path="../Subs/NFLX-Subs/"
mkdir -p $file_path
suffix=".ass"
for vid in *.mp4; do
    for strm in {0..15}; do
        lang_text=$(ffprobe -v error -hide_banner -of default=noprint_wrappers=0 -print_format flat  -select_streams s:$strm -show_entries stream=index:stream_tags=language $vid | grep language)
        lang=$(echo $lang_text | cut -d '"' -f 2)
        echo "Processing video $vid, stream $strm, language $lang"
        mkdir -p "$file_path$lang/"
        # For the name we save, we want to match the format used by the Upscale project, which is
        # EpXXepisodetitle.ass. The title is actually not contained, so we settle for EpXX.ass
        searchstring="E"
        rest=${vid#*$searchstring}
        epnum=$(cut -c 1-2<<< $rest)
        out_name="Ep$epnum"
        ffmpeg -y -i "$vid" -map s:$strm "$file_path$lang/$out_name$suffix"
    done
done

cd ../Subs
# Extract Brazilain Portunguese subs downloaded from https://drive.google.com/drive/folders/1n7U2ZaSOXUezZNYXLJaA8CVz8EZvMStf
unzip -oqd brazil-subs 'Monster 2004-2005 (legendas)-20230217T233120Z-001.zip'
mkdir -p NFLX-Subs/bra
cd brazil-subs/*
for sub in *.srt; do
    searchstring="E"
    rest=${sub#*$searchstring}
    epnum=$(cut -c 1-2<<< $rest)
    out_name="../../NFLX-Subs/bra/Ep$epnum.ass"
    ffmpeg -y -loglevel warning -i $sub $out_name
done

cd ../../NFLX-Subs

# All subtitles need to be formatted correctly for 1080p
for sub in $(find . -type f -name '*.ass'); do
    echo "Shifting times for $sub"
    python ../../shift_sub_times.py $sub -1.5 # move sub times 2 seconds earlier
done

cd eng
# Add all available titles and signs lines to each track
for sub in *.ass; do
    searchstring="Ep"
    rest=${sub#*$searchstring}
    epnum=$(cut -c 1-2<<< $rest)
    sub_titles="../../Orig-Subs/eng/Ep$epnum-titlesnsigns.ass"
    awk '/Title,,/' $sub_titles >> $sub
done
cd ../ # back to NFLX-Subs

sh ../../edit_subs_in_dir.sh .

cd ../
zip -r NFLX-Subs.zip NFLX-Subs > nul
rm nul