# In this case we assume Full-Subs has already been built to a satisfactory level, and we only want to add/change a few files

cd Subs/Full-Subs-additions

epnums=() # initialize array of episode numbers
for lang in *; do # loop through directories
    mkdir -p ../Full-Subs/$lang 
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

cd ../Full-Subs

sh ../../edit_subs_in_dir.sh . 1 # 1 designates skipping spanish subs

# Rename any fontfiles with whitespace
for lang in *; do
    cd "$lang"
    for font in *.ttf *.otf; do
        echo "Checking $font" 
        font_nws=${font// /_} # no white space
        if [ "$font" != "$font_nws" ]; then # Contains whitespace
            echo "Renaming $font to $font_nws"
            mv "$font" "$font_nws"
            fontname=$(basename -- "$font") # remove path
            fontname="${fontname%.*}" # remove extension
            fontname_nws=$(basename -- "$font_nws") # remove path
            fontname_nws="${fontname_nws%.*}" # remove extension
            # Replace all cases of that string in all subtitle files
            find -type f -exec sed -i "s/$fontname/$fontname_nws/g" {} +
        fi
    done
    cd ../ # back to Full-Subs
done

cd ../ # back to Subs
zip -r Full-Subs.zip Full-Subs > nul
rm nul

cd ../ # back to top directory
# Rebuild the episodes with edited subs
echo "Rebuild ${epnums[@]}"
for epnum in ${epnums[@]}; do
    echo "Rebuilding $epnum"
    sh rebuild_mkv.sh "$epnum"
done