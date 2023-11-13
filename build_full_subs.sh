# Assume we have extracted the most recent version of the subs from 
# https://drive.google.com/drive/folders/1OHbgqLScQ8VOe4kA-1lHASBomXwfZTvP
# into Subs/Finalized Subtitles
# We also assume that we have the netflix subs from the NFLX rip in
# Subs/NFLX-Subs, per extract_nflx_subs.sh

cd Subs
# cleanup, if necessary
rm -rf Full-Subs
rm -f Full-Subs.zip
rm -rf gdrive-subs

# Copy the NFLX-Subs as the baseline for the final product
cp -R NFLX-Subs Full-Subs

# Now loop through Subs-Orig and get the Subs from there. We assume this is from extract_orig_subs.sh, and therefore has predictable filename formatting
cd Orig-Subs
for lang in *; do # loop through directories
    for sub in $lang/*.ass; do # loop through subtitle names, including the directory name
        nlines=$(wc -l < $sub)
        if [[ $nlines -lt 50 ]] && [[ "$sub" != *"itle"* ]]; then
            echo "Only $nlines lines in $sub, presumed empty, skipping" 
        else
            echo "Moving $sub to Full-Subs/$sub..."
            cp -f "$sub" "../Full-Subs/$sub"
        fi
    done
    # Now move all remaining files along with it, as they might be important font files
    cp -n $lang/* ../Full-Subs/$lang/
done
cd ../

# get new custom subs
mkdir -p gdrive-subs
# Only one of the following should work, and bash scripts don't end on errors
unzip -q -d gdrive-subs drive-download*.zip
unzip -q -d gdrive-subs Finalized*.zip
unzip -q -d gdrive-subs spa-*.zip

# Now loop through the custom subs and replace the nflx subs with them
cd gdrive-subs
if  [[ ! -d "eng" ]] && [[ ! -d "spa" ]]; then # need to go down by one more directory
    cd *
fi
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
    done
    # Now move all remaining files along with it, as they might be important font files
    cp -n $lang/* ../Full-Subs/$lang/
done

cd ../Full-Subs 

# All subtitles need to be formatted correctly for 1080psh ../../edit_subs_in_dir.sh .
sh ../../edit_subs_in_dir.sh . 1 # don't edit spanish subs

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

# Remove languages that produce bugs in rebuild_mkv.sh
rm -r zho
rm -r jpn

cd ../ # back to Subs/
rm -r gdrive-subs

zip -r Full-Subs.zip Full-Subs > nul
rm nul