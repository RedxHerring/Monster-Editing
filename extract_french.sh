# We will use this file to get the subs from the 540p source from https://nyaa.si/view/1611098
pwd0=pwd
cd '[Community] Monster [MULTI DVDRIP 540p x265 AC3]'

subs_path="$pwd0/Subs/French-Subs-unedited"
mkdir -p $file_path
mkdir -p "$file_path/fre/"
suffix=".ass"
for vid in *.mkv; do
    # For the name we save, we want to match the format used by the Upscale project, which is
    # EpXXepisodetitle.ass. The title is actually not contained, so we settle for EpXX.ass
    searchstring="Monster "
    rest=${vid#*$searchstring}
    epnum=$(cut -c 1-2<<< $rest)
    out_name="Ep$epnum"
    echo "Processing video $vid, $out_name"
    # Get sub files
    # for strm in {0..1}; do
    #     echo "Processing video $vid, stream s:$strm, language fre"
        
    #     ffmpeg -y -i "$vid" -map s:$strm "$file_path/$lang/$out_name$suffix"
    # done
    # Now extract new fonts
    ffmpeg -dump_attachment:t "" -i "$file" -n 
done
