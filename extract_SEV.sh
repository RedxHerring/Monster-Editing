pwd0=$(pwd)
SEV_dir="$pwd0/Monster [Ultimate Collection] By Kira [SEV]/Monster [2004-2005] DVDRip x265 AC-3 DD 2.0 Kira [SEV]"

mkdir -p "$pwd0/Audio"
mkdir -p "$pwd0/Audio/jpn"
mkdir -p "$pwd0/Audio/eng"
for vid in "$SEV_dir"/*.mkv; do
    # For the name we save, we want to match the format used by the Upscale project, which is
    # EpXXepisodetitle.ass. The title is actually not contained, so we settle for EpXX.ass
    searchstring="Chapter "
    rest=${vid#*$searchstring} # find first Monster
    rest=${rest#*$searchstring} # find second Monster
    epnum=$(cut -c 1-2<<< $rest)
    out_name="Ep$epnum"
    echo "Processing video $vid, as $out_name"
    # Japanese first, English second
    ffmpeg -n -loglevel warning -i "$vid" -map a:0 -c:a flac "$pwd0/Audio/jpn/$out_name.flac" -map a:1 -c:a flac "$pwd0/Audio/eng/$out_name.flac"
done
