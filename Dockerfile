FROM dgx-spark-base

ARG DEBIAN_FRONTEND=noninteractive

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    MAX_JOBS=4 \
    HF_HOME=/huggingface \
    HUGGINGFACE_HUB_CACHE=/huggingface/hub \
    TORCH_HOME=/huggingface/torch \
    XDG_CACHE_HOME=/huggingface/.cache \
    CUDA_HOME=/usr/local/cuda \
    OPENCV_IO_ENABLE_OPENEXR=1 \
    PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

WORKDIR /workspace/TRELLIS.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    ffmpeg \
    git \
    libgl1 \
    libglib2.0-0 \
    libjpeg-dev \
    pkg-config \
    libxext6 \
    libxrender1 \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

COPY . .

RUN python -m pip install --upgrade pip setuptools wheel

RUN python -m pip install \
    packaging \
    psutil \
    cmake \
    pybind11 \
    ninja \
    triton \
    imageio \
    imageio-ffmpeg \
    tqdm \
    easydict \
    opencv-python-headless \
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
    sentencepiece

RUN python -m pip install --no-deps git+https://github.com/EasternJournalist/utils3d.git@9a4eb15e4021b67b12c460c7057d642626897ec8

RUN mkdir -p /tmp/extensions && \
    git clone -b v0.4.0 https://github.com/NVlabs/nvdiffrast.git /tmp/extensions/nvdiffrast && \
    python -m pip install /tmp/extensions/nvdiffrast --no-build-isolation

RUN mkdir -p /tmp/extensions && \
    git clone -b renderutils https://github.com/JeffreyXiang/nvdiffrec.git /tmp/extensions/nvdiffrec && \
    python -m pip install /tmp/extensions/nvdiffrec --no-build-isolation

RUN mkdir -p /tmp/extensions && \
    git clone https://github.com/JeffreyXiang/CuMesh.git /tmp/extensions/CuMesh --recursive && \
    python -m pip install /tmp/extensions/CuMesh --no-build-isolation

RUN mkdir -p /tmp/extensions && \
    git clone https://github.com/JeffreyXiang/FlexGEMM.git /tmp/extensions/FlexGEMM --recursive && \
    python -m pip install /tmp/extensions/FlexGEMM --no-build-isolation

RUN python -m pip install ./o-voxel --no-build-isolation && rm -rf /tmp/extensions

EXPOSE 7860

CMD ["python", "app.py"]