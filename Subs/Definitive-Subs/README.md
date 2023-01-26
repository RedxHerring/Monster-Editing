In kdenlive, we edit together the videos, and we add the titles and signs subtitles in place where we want them.
Just before rednering, copy the srt for the titles and signs from Editing into the directory, either removing or renaming the subtitle in Editing.
After rendering the kdenlive files into video, we will have the video and audio without subtitles burned in.
Take that video and feed it into pyTranscriber, which will interpret the audio to generate an srt. 
Copy those to this directory as well.
Run sh edit_definitive_subs to convert these srt files into .ass files with some 