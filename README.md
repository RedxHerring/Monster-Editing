# Monster-Editing
Editing anime adaptation of Naoki Urasawa's Monster in Kdenlive

You can get the 1080p upscales from here:
https://archive.org/details/Monster-Upscaled

You can get the music from here:
https://downloads.khinsider.com/game-soundtracks/album/monster-original-soundtrack-1
https://downloads.khinsider.com/game-soundtracks/album/monster-original-soundtrack-2


Once you have the key generated and setup, use the following commands to activate your ssh key in that shell environmnet.
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

To save the conda environment used for ML transcription and translation, use
```bash
conda env export > environment.yml
```

To reinstall the environment use 
```bash
conda env create -f environment.yml
```

To dowload wav from online video use for example (per https://ostechnix.com/yt-dlp-tutorial/):
```bash
yt-dlp -x --audio-quality 0 --audio-format wav https://www.youtube.com/watch?v=86n7reItMzs
```