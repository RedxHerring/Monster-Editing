pwd0=$(pwd)
Ger_dir="$pwd0/Blu-Ray/Ripped-Titles"

subs_path="$pwd0/Subs/German-Subs-unedited"
mkdir -p $subs_path
mkdir -p "$subs_path/ger/"
cd $subs_path/ger
mkdir -p "$pwd0/Audio"
mkdir -p "$pwd0/Audio/ger"
for vid in "$Ger_dir"/*.mpg; do
    # For the name we save, we want to match the format used by the Upscale project, which is
    # EpXXepisodetitle.ass. The title is actually not contained, so we settle for EpXX.ass
    searchstring="Ep"
    rest=${vid#*$searchstring} # find first Monster
    rest=${rest#*$searchstring} # find second Monster
    epnum=$(cut -c 1-2<<< $rest)
    out_name="Ep$epnum"
    echo "Processing video $vid, $out_name"
    # German first, Japanese second
    ffmpeg -n -loglevel warning -i "$vid" -map a:0 -c:a flac "$pwd0/Audio/ger/$out_name.flac"
    # Subs are a weird format, so we'll just map them directly whenever we need them
done
