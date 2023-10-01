# We will use this file to get the subs from the 540p source from https://nyaa.si/view/1611098
pwd0=$(pwd)
Fr_dir="$pwd0/[Community] Monster [MULTI DVDRIP 540p x265 AC3]"

subs_path="$pwd0/Subs/French-Subs-unedited"
mkdir -p $subs_path
mkdir -p "$subs_path/fre"
cd $subs_path/fre
mkdir -p "$pwd0/Audio"
mkdir -p "$pwd0/Audio/fre"
for vid in "$Fr_dir"/*.mkv; do
    # For the name we save, we want to match the format used by the Upscale project, which is
    # EpXXepisodetitle.ass. The title is actually not contained, so we settle for EpXX.ass
    searchstring="Monster "
    rest=${vid#*$searchstring} # find first Monster
    rest=${rest#*$searchstring} # find second Monster
    epnum=$(cut -c 1-2<<< $rest)
    out_name="Ep$epnum"
    echo "Processing video $vid, $out_name"
    # Japanese first, French second, only want French
    ffmpeg -n -loglevel warning -i "$vid" -map a:1 -c:a flac "$pwd0/Audio/fre/$out_name.flac"
    # Get sub files
    ffmpeg -n -loglevel warning -i "$vid" -map s:0 "$out_name.ass"
    ffmpeg -n -loglevel warning -i "$vid" -map s:1 "$out_name-titlesnsigns.ass"
    # Now extract new fonts
    ffmpeg -n -loglevel warning -dump_attachment:t "" -i "$vid" -n 
done
