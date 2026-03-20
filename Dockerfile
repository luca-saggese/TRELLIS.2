FROM dgx-spark-base

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HOME=/huggingface \
    HUGGINGFACE_HUB_CACHE=/huggingface/hub \
    TORCH_HOME=/huggingface/torch \
    XDG_CACHE_HOME=/huggingface/.cache \
    OPENCV_IO_ENABLE_OPENEXR=1 \
    PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

WORKDIR /workspace/TRELLIS.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    ffmpeg \
    git \
    libgl1 \
    libglib2.0-0 \
    libjpeg-dev \
    libxext6 \
    libxrender1 \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install \
    imageio \
    imageio-ffmpeg \
    tqdm \
    easydict \
    opencv-python-headless \
    ninja \
    trimesh \
    transformers \
    gradio==6.0.1 \
    tensorboard \
    pandas \
    lpips \
    zstandard \
    kornia \
    timm \
    huggingface_hub \
    safetensors \
    sentencepiece && \
    python -m pip install git+https://github.com/EasternJournalist/utils3d.git@9a4eb15e4021b67b12c460c7057d642626897ec8 && \
    python -m pip install flash-attn==2.7.3 --no-build-isolation && \
    mkdir -p /tmp/extensions && \
    git clone -b v0.4.0 https://github.com/NVlabs/nvdiffrast.git /tmp/extensions/nvdiffrast && \
    python -m pip install /tmp/extensions/nvdiffrast --no-build-isolation && \
    git clone -b renderutils https://github.com/JeffreyXiang/nvdiffrec.git /tmp/extensions/nvdiffrec && \
    python -m pip install /tmp/extensions/nvdiffrec --no-build-isolation && \
    git clone https://github.com/JeffreyXiang/CuMesh.git /tmp/extensions/CuMesh --recursive && \
    python -m pip install /tmp/extensions/CuMesh --no-build-isolation && \
    git clone https://github.com/JeffreyXiang/FlexGEMM.git /tmp/extensions/FlexGEMM --recursive && \
    python -m pip install /tmp/extensions/FlexGEMM --no-build-isolation && \
    python -m pip install ./o-voxel --no-build-isolation && \
    rm -rf /tmp/extensions

EXPOSE 7860

CMD ["python", "app.py"]