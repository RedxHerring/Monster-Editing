# Monster-Editing
Editing anime adaptation of Naoki Urasawa's Monster in Kdenlive

You can get the 1080p upscales from here:
https://archive.org/details/Monster-Upscaled

You can get the music from here:
https://downloads.khinsider.com/game-soundtracks/album/monster-original-soundtrack-1
https://downloads.khinsider.com/game-soundtracks/album/monster-original-soundtrack-2


In working with this repository, it is necessary to use ssh authenbtication, which often resets itself in some computers.
Once you have the key generated and setup, if any issues arise, you need only use this link: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
or simply use these commands
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

Use ffmpeg-full-git to use intel arc for gpu-based av1 encoding