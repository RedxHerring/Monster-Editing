import numpy as np
import torch
from seamless_communication.models.inference import Translator

def translate_srt(audio_file, out_file, src_lang, tgt_lang):
    # Initialize a Translator object with a multitask model, vocoder on the GPU.
    translator = Translator("seamlessM4T_large", vocoder_name_or_card="vocoder_36langs", device=torch.device("cuda:0"))
    with open(audio_file,'r') as file:
        lines = file.readlines()
        # srt files are conveninet bc they have text every 4 lines starting from the 3rd, so we can just do this
        for idx in np.arange(2,len(lines),4):
            # T2TT
            lines[idx], _, _ = translator.predict(lines[idx], "t2tt", tgt_lang, src_lang=src_lang)
    with open(out_file,'w') as file:
        file.writelines(lines)

if __name__ == "__main__":
    translate_srt(audio_file="in.srt", out_file="out.srt", src_lang="spa", tgt_lang="end")