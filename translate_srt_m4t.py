import numpy as np
import torch
from seamless_communication.models.inference import Translator

def translate_srt(srt_file, out_file, src_lang, tgt_lang):
    # Initialize a Translator object with a multitask model, vocoder on the GPU.
    translator = Translator("seamlessM4T_large", vocoder_name_or_card="vocoder_36langs", device=torch.device("cuda"))
    with open(srt_file,'r') as file:
        lines = file.readlines()
        idx = 0
        # line_types = ['index','timestamp','dialogue']
        idxt = 0 #  0, 1 or 2
        while idx < len(lines):
            if not len(lines[idx]): # empty line, skip
                idx += 1
                continue
            if lines[idx][0].isdigit() and not idxt: # looking for a digit and we got it
                idx += 1
                idxt = 1 # Now we want to look for timestamp
                continue
            if " --> " in lines[idx][0] and idxt == 1: # timestamp, next is dialogue
                idx += 1
                idxt = 2 # Now we want to look for dialogue
                continue
            if len(lines[idx]) and idxt != 1: # allow either 0 or 2
                # T2TT
                idxt = 0 # open to new index integer for next set of lines
                translated_text_from_text, _, _ = translator.predict(lines[idx], "t2tt", tgt_lang, src_lang=src_lang)
                lines[idx] = str(translated_text_from_text)
    with open(out_file,'w') as file:
        file.writelines(lines)

if __name__ == "__main__":
    translate_srt(srt_file="Subs/Ep07_v1.srt", out_file="Subs/out.srt", src_lang="deu", tgt_lang="eng")