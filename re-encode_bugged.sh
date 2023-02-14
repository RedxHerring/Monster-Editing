# Episodes 14, 20-23 are bugged. We need to fix them.

bugged_epnums=("14" "20" "21" "22" "23")
mkdir -p "output/Orig-copy"
for epnum in "${bugged_epnums[@]}"; do
    Origmkv=$(ls Orig/ | grep "Chapter $epnum")
    echo "Found $Origmkv, will remove duplicate channels"
    input="Orig/$Origmkv"
    output="Output/Orig-copy/$(basename "$Origmkv")_v2.mkv"
    ffmpeg -y -i "$input" -map v:0 -map a:0 -map a:1 -map s:0 -map s:1 -map s:2 -map 0:t -c copy \
    -map_metadata 0 -map_metadata:s:v:0 0:s:v:0 -map_metadata:s:a:0 0:s:a:0 -map_metadata:s:a:1 0:s:a:1 \
    -map_metadata:s:s:0 0:s:s:0 -map_metadata:s:s:1 0:s:s:1 -map_metadata:s:s:2 0:s:s:2 \
    -map_metadata:s:t 0:s:t "$output"
done
