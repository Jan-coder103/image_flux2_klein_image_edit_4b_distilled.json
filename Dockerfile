# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# 1. Install git (required for updating ComfyUI)
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

# 1. Update ComfyUI Core to the latest version
# We also update the requirements to prevent "ModuleNotFoundError"
RUN cd /comfyui && \
    git switch master 2>/dev/null || git switch -c master origin/master && \
    git pull origin master && \
    pip install --upgrade --no-cache-dir -r requirements.txt

# Install GGUF support (crucial for specific models)
# Using --mode remote to ensure we get the latest registry info
RUN comfy-node-install ComfyUI-GGUF --mode remote

# Download the specific GGUF models defined in your workflow
# UNET: Flux.2 Klein 4B (GGUF Q8_0)
RUN comfy model download --url https://huggingface.co/unsloth/FLUX.2-klein-4B-GGUF/resolve/main/flux-2-klein-4b-Q8_0.gguf --relative-path models/unet --filename flux-2-klein-4b-Q8_0.gguf

# CLIP: Qwen3-4B (GGUF Q4_K_M)
RUN comfy model download --url https://huggingface.co/unsloth/Qwen3-4B-GGUF/resolve/main/Qwen3-4B-Q4_K_M.gguf --relative-path models/text_encoders --filename Qwen3-4B-Q4_K_M.gguf

# VAE: Flux2 VAE
RUN comfy model download --url https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors --relative-path models/vae --filename flux2-vae.safetensors

# LoRA: The nipple-diffusion LoRA seen in your Klein workflow
RUN comfy model download --url https://huggingface.co/UnifiedHorusRA/TheFourHorsemen/resolve/main/NippleDiffusion_-_Flux2_Klein/Flux_2_Klein_4B/nipplediffusion-f2-klein-4b.safetensors --relative-path models/loras --filename nipplediffusion-f2-klein-4b.safetensors

# No COPY workflow_api.json needed here since you send it via API request!
