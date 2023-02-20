import intel_extension_for_pytorch
import torch
from diffusers import StableDiffusionPipeline

model_id="runwayml/stable-diffusion-v1-5"
prompt = "vivid red hot air ballons over paris in the evening"
pipe = StableDiffusionPipeline.from_pretrained(
    model_id,
    torch_dtype=torch.float16,  # this can be torch.float32 as well
    revision="fp16",
    use_auth_token="<the token you generated>")
pipe = pipe.to("xpu")
image = pipe(prompt).images[0]
image.save(f"{prompt[:5]}.png")