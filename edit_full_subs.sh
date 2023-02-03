# In this case we assume Full-Subs has already been built to a satisfactory level, and we only want to add/change a few files

cd Subs/Full-Subs-additions

epnums=() # initialize array of episode numbers
for lang in *; do # loop through directories
    for sub in $lang/*.ass; do # loop through subtitle names, including the directory name
        echo "Subtitle file $sub"
        epnum=$(echo $sub | grep -E -o [0-9]{2})
        if [[ "$epnum" == "" ]]; then
            epnum="0$(echo $sub | grep -E -o [0-9]{1})"
        fi
        out_name="Ep${epnum:0:2}.ass"
        echo "Moving $sub to Full-Subs/$lang/$out_name..."
        mv -f "$sub" "../Full-Subs/$lang/$out_name"
        if [[ ! " ${epnums[*]} " =~ " ${epnum} " ]]; then # episode number not yet encountered
            epnums+=("${epnum}")
        fi  
    done
    # Now move all remaining files along with it, as they might be important font files
    cp -n $lang/* ../Full-Subs/$lang/
    rm $lang/*
done

# Rebuild the
for epnum in "${epnums[@]}"; do
echo "Rebuilding $epnum"
    sh rebuild1_mkv "$epnum"
done