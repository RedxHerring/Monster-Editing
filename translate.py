# Transcribe and translate .wav or .srt files into a desired language.
# The idea is to use whisper for an initial guess and to get timestamps,
# and then to use those timestamps to feed wav segments into seamlessm4t
import sys
import os
from pathlib import Path
from whisper.utils import get_writer
from whisper.transcribe import cli
from seamless_communication.models.inference import Translator

# This module should act as a drop-in placement for whisper, and therefore should be able to be run as below
# whisper japanese.wav --language Japanese --task translate
# It should also be possible to input a directory, 
# and it will recursively pass the additional arguments for each option

def clim4t():
    # fmt: off
    parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("audio", nargs="+", type=str, help="audio file(s) to transcribe")
    parser.add_argument("--output_dir", "-o", type=str, default=".", help="directory to save the outputs")
    args = parser.parse_args().__dict__
    output_dir: str = args.pop("output_dir")
    device: str = args.pop("device")
    os.makedirs(output_dir, exist_ok=True)


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
                # Need to get this segment of dialogue  in audio form.
                # S2TT
                text_output, _ = translator.predict(
                    input=path_to_input_audio,
                    task_str="S2TT",
                    tgt_lang=tgt_lang,
                    text_generation_opts=text_generation_opts,
                    unit_generation_opts=None
                )
    with open(out_file,'w') as file:
        file.writelines(lines)

# whisper "$afile" --model large-v2 --task transcribe --language $language --beam_size 10 --patience 2  --suppress_tokens "" --condition_on_previous_text False \
#         --word_timestamps True  --hallucination_silence_threshold 2 --output_format srt --output_dir Subs/Whisper-Transcribed/$lang/

if __name__ == "__main__":
    # First we run whisper to generate
    if len(sys.argv) == 1: # no cli inputs, run with following parameters
        model_name = "large"
        audio_path = "audio/spa/Ep01.wav" # input a .wav to use whisper
        langin = "spa"
        langout = "eng"
        output_dir = os.path.join("Subs","Whisper-Transcribed",langout)
        temperature = 2
        if (increment := args.pop("temperature_increment_on_fallback")) is not None:
            temperature = tuple(np.arange(temperature, 1.0 + 1e-6, increment))
        else:
            temperature = [temperature]
        # setup srt location
        basename = Path(audio_path).stem
        srtfile = os.path.join(output_dir,audio_path+".srt")
        from whisper import load_model
        model = load_model(model_name)
        result = transcribe(model, audio_path, temperature=temperature, word_timestamps=True, hallucination_silence_threshold=2)
        writer(result, audio_path)
    else:
        if not any('--output_format' == x for x in sys.argv):
            sys.argv.append(" --output_format srt") # make sure we pass the right things to whisper
        cli() # run whisper 
    translate_srt(srt_file=srtfile, out_file="Subs/out.srt", src_lang="deu", tgt_lang="eng")