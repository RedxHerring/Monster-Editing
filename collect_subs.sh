# Assume we have extracted th most recent version of the subs from 
# https://drive.google.com/drive/folders/1OHbgqLScQ8VOe4kA-1lHASBomXwfZTvP
# into Subs/Finalized Subtitles

cd Subs/Finalized\ Subtitles/
mkdir -p fonts

for compressed in *.7z; do
    mkdir temp
    7z x compressed -otemp;
    cd temp
    for sub in *.ass; do
        mv sub ../sub
    done
    cd -
    cp -n temp/* fonts/
    rm -r temp
    rm compressed
done

