
''' Remember:
conda activate intel310
source /opt/intel/oneapi/setvars.sh
export LD_PRELOAD=/usr/lib/libstdc++.so.6.0.32
'''
import intel_extension_for_pytorch as ipex
import numpy as np
import torch
from transformers import AutoProcessor, SeamlessM4TModel

if torch.cuda.is_available():
    device = "cuda"
elif find_spec('torch.xpu') is not None and torch.xpu.is_available():
    device = "xpu"
else:
    device = "cpu"

def translate_srt(srt_file, out_file, src_lang, tgt_lang):
    # Initialize a Translator object with a multitask model, vocoder on the GPU.
    processor = AutoProcessor.from_pretrained("facebook/hf-seamless-m4t-large")
    model = SeamlessM4TModel.from_pretrained("facebook/hf-seamless-m4t-large").to(device)
    if device == 'xpu':
        model = ipex.optimize(model)
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
                # Now follow/adapt https://huggingface.co/facebook/hf-seamless-m4t-large
                text_inputs = processor(text = lines[idx], src_lang="eng", return_tensors="pt").to(device)
                output_tokens = model.generate(**text_inputs, tgt_lang="fra", generate_speech=False)
                translated_text_from_text = processor.decode(output_tokens[0].tolist(), skip_special_tokens=True)
                lines[idx] = str(translated_text_from_text)
    os.makedirs(os.path.dirname(out_file),exist_ok=True)
    with open(out_file,'w') as file:
        file.writelines(lines)

if __name__ == "__main__":
    translate_srt(srt_file="Subs/Whisper-Transcribed/spa/Ep01.srt", out_file="Subs/M4T-Translated/spa/eng/Ep01.srt", src_lang="spa", tgt_lang="eng")