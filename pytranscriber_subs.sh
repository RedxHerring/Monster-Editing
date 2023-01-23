# Using the pyTranscriber tool (https://pytranscriber.github.io/), we can extract srt files from the english audio.
# We will assume these are in Subs/pyTranscriber-Subs/eng/

cd Subs/pyTranscriber-Subs/eng/

for sub in *.srt; do
    searchstring="Chapter " # note the space at the end
    rest=${sub#*$searchstring}
    epnum=$(cut -c 1-2<<< $rest)
    out_name="Ep$epnum.ass"
    echo "Converting $sub to $out_name"
    ffmpeg -y -i "$sub" $out_name
done