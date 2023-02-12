for mkv in Orig/*.mkv; do
    vid_name=${mkv:5}
    epnum=$(echo $vid_name | grep -E -o [0-9]{2})
    epnum=${epnum:0:2}
    sh rebuild1_mkv.sh "$epnum"
done