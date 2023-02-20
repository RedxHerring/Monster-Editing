if [[ $# -lt 2 ]]; then 
    skip_spa=0
else
    skip_spa=$2
fi

cd "$1"

# Fix any missed namings in all files
find -type f -exec sed -i "s/Schubert/Schuwald/g" {} +
find -type f -exec sed -i "s/Runge/Lunge/g" {} +
find -type f -exec sed -i "s/Names1,,/Names,,/g" {} +
find -type f -exec sed -i "s/Names2,,/Names,,/g" {} +
find -type f -exec sed -i "s/Location,,/Names,,/g" {} +
find -type f -exec sed -i "s/Monster-Title,,/Title,,/g" {} +

for sub in $(find . -type f -name '*.ass'); do
    lang=$(echo $(basename $(dirname $sub)))
    if [[ $lang == "spa" ]] && [[ skip_spa = 1 ]]; then
        continue
    fi
    epnum=$(echo $sub | grep -E -o [0-9]{2})
    echo "Editing $sub"
    python ../../find_replace_lines.py "$sub" "Audio File:" ""
    python ../../find_replace_lines.py "$sub" "Video File:" ""
    python ../../find_replace_lines.py "$sub" "PlayResX:" "PlayResX: 720" # using reduced size for compatibility
    python ../../find_replace_lines.py "$sub" "PlayResY:" "PlayResY: 480" # keep in mind this dramatically changes font scalin since it thinks there is a smaller cnavas than there actually is
   
    # First reset/remove style lines
    python ../../find_replace_lines.py "$sub" "Style: Title," ""
    python ../../find_replace_lines.py "$sub" "Style: Titles1," ""
    python ../../find_replace_lines.py "$sub" "Style: Names," ""
    python ../../find_replace_lines.py "$sub" "Style: Names1," ""
    python ../../find_replace_lines.py "$sub" "Style: Names2," ""
    python ../../find_replace_lines.py "$sub" "Style: Location," ""
    python ../../find_replace_lines.py "$sub" "Style: X-Files," ""
    python ../../find_replace_lines.py "$sub" "Style: Monster-Title," ""

    # Then put in place new style lines
    if [ $epnum -eq 1 ]; then
        sed -i "s/X-Files,,/Bible,,/g" $sub
        python ../../find_replace_lines.py "$sub" "Style: Bible," ""
        python ../../find_replace_lines.py "$sub" "Style: Default," "Style: Default,Jesaya Free,28,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,1.5,0.75,2,10,10,10,1" \
        "Style: Title,Arial,40,&H00FFFFFF,&H00000000,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0.5,1,2,30,30,25,0" \
        "Style: Titles1,Times New Roman,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0.5,1,2,10,10,40,1" \
        "Style: Names,Arial,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0,0,2,10,10,20,1" \
        "Style: Bible,X-Files,13,&H00908B87,&H000000FF,&H00F3F3F1,&H00000000,0,0,0,0,92,100,0,0,1,0,0,2,20,20,23,1"
    else
        python ../../find_replace_lines.py "$sub" "Style: Default," "Style: Default,Jesaya Free,28,&H00FFFFFF,&H000000FF,&H00101010,&H80303030,-1,0,0,0,100,100,0,0,1,1.5,0.75,2,10,10,20,1" \
        "Style: Title,Arial,40,&H00FFFFFF,&H00000000,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0.5,1,2,30,30,25,0" \
        "Style: Titles1,Times New Roman,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,0.5,1,2,10,10,40,1" \
        "Style: Names,Arial,32,&H00FFFFFF,&H000000FF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0,0,2,10,10,20,1"
    fi   
    
    # Remove excessive empty lines
    echo "$(cat -s $sub)" > $sub
done