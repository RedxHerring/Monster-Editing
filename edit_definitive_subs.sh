# Convert srt subs to ass, and then edit them in that state

cd Subs/Definitive-Subs

for sub in *.srt; do
    ffmpeg -y -loglevel warning -i $sub "${sub%.*}.ass"
done

for sub in $(find . -type f -name '*.ass' ! -name "Ep*"); do
    
    epnum=$(echo $sub | grep -E -o [0-9]{2})
    epnum1=${epnum:0:2}
    epnum2=${epnum:3:2} # start at 3rd index and take 2 indices
    if [[ $sub = *"kdenlive"* ]]; then
        out_name="Ep$epnum1-$epnum2-titlesnsigns.ass"
    else
        out_name="Ep$epnum1-$epnum2.ass"
    fi
    echo "Editing $sub, saving as $out_name" 

    sed -i 's/‎//g' $sub # remove empty character in all cases in file

    python ../../find_replace_lines.py "$sub" "Audio File:" ""
    python ../../find_replace_lines.py "$sub" "Video File:" ""
    python ../../find_replace_lines.py "$sub" "PlayResX:" "PlayResX: 1440" # using reduced size for compatibility
    python ../../find_replace_lines.py "$sub" "PlayResY:" "PlayResY: 1080" # keep in mind this dramatically changes font scalin since it thinks there is a smaller cnavas than there actually is

    # First reset style lines
    python ../../find_replace_lines.py "$sub" "Style: Title," ""
    python ../../find_replace_lines.py "$sub" "Style: Titles1," ""
    python ../../find_replace_lines.py "$sub" "Style: Bible-Verse," ""

    # Then put in place new style lines
    if [ $epnum1 -eq 1 ]; then
        python ../../find_replace_lines.py "$sub" "Style: Default," "Style: Default,Jesaya Free,50,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,1.5,0.75,2,10,10,10,1" \
        "Style: Title,Arial,32,&H00FFFFFF,&H00000000,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0.5,1,2,30,30,30,0" \
        "Style: Titles1,Times New Roman,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0.5,1,2,10,10,40,1" \
        "Style: Names,Arial,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0,0,2,10,10,10,1" \
        "Style: Bible-Verse,X-Files,27,&H00908B87,&H000000FF,&H00F3F3F1,&H00000000,0,0,0,0,92,100,0,0,1,0,0,2,20,20,23,1"
        
    else
        python ../../find_replace_lines.py "$sub" "Style: Default," "Style: Default,Jesaya Free,50,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,1.5,0.75,2,10,10,20,1" \
        "Style: Title,Arial,32,&H00FFFFFF,&H00000000,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0.5,1,2,30,30,30,0" \
        "Style: Titles1,Times New Roman,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0.5,1,2,10,10,40,1" \
        "Style: Names,Arial,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0,0,2,10,10,10,1"
    fi
    mv -f $sub $out_name # overwrite in this directory
    cp -n $out_name "ass-custom/$out_name" # do not overwrite in this directory
done
