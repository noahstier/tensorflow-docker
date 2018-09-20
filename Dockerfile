FROM nvidia/cuda:9.2-cudnn7-devel-ubuntu16.04
MAINTAINER Noah Stier <nstier@toyon.com>

RUN apt-get -y update --fix-missing && \
    apt-get -y install --no-install-recommends --fix-missing \
      apt-utils \
      autoconf \
      automake \
      build-essential \
      ca-certificates \
      cmake \
      cpio \
      curl \
      dialog \
      gcc \
      gfortran \
      git \
      gpp \
      g++ \
      htop \
      libatlas-base-dev \
      libav-tools \
      libboost-all-dev \
      libcupti-dev \
      libncurses5-dev \
      libreadline-dev \
      locate \
      make \
      npm \
      pkg-config \
      python-dev \
      python-software-properties \
      sed \
      software-properties-common \
      tmux \
      unzip \
      vim \
      wget \
      zlib1g-dev \
      zsh && \
  rm -rf /var/lib/apt/lists/*

# a minimal anaconda installation
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /root/.bashrc && \
    curl https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

RUN /opt/conda/bin/conda update -y conda && \
    /opt/conda/bin/conda config --prepend channels intel && \
    /opt/conda/bin/conda config --append channels conda-forge && \
    /opt/conda/bin/conda install -y intelpython3_core python=3 \
      beautifulsoup4 \
      bokeh \
      cython \
      gdal \
      geopandas \
      h5py \
      imageio \
      ipyparallel \
      ipython \
      jupyter_contrib_nbextensions \
      jupyter \
      jupyterhub \
      jupyterlab \
      jupyter_nbextensions_configurator \
      libiconv \
      mathjax \
      matplotlib \
      msgpack-python \
      nbpresent \
      networkx \
      numpy \
      opencv=3 \
      pandas \
      pillow \
      plotly \
      pyproj \
      pyyaml \
      readline \
      requests \
      scikit-bio \
      scikit-image \
      scikit-learn \
      scikit-rf \
      scipy \
      scrapy \
      setuptools \
      six \
      sympy \
      tensorflow-gpu=1.10 \
      tornado=4.5 && \
    /opt/conda/bin/conda clean -tipsy

RUN /opt/conda/bin/jupyter nbextension enable nbpresent --py && \
  /opt/conda/bin/jupyter serverextension enable nbpresent --py && \
  /opt/conda/bin/ipcluster nbextension enable && \
  /opt/conda/bin/jupyter serverextension enable --py jupyterlab && \
  /opt/conda/bin/jupyter contrib nbextension install --symlink && \
  /opt/conda/bin/ipcluster nbextension enable

RUN echo 'export PATH=/julia-9d11f62bcb/bin:$PATH' >> /root/.bashrc && \
  wget https://julialang-s3.julialang.org/bin/linux/x64/0.6/julia-0.6.4-linux-x86_64.tar.gz \
  -O julia.tar.gz && \
  tar xvf julia.tar.gz && \
  rm julia.tar.gz

RUN /julia-9d11f62bcb/bin/julia -e 'ENV["PYTHON"] = "/opt/conda/bin/python"; Pkg.add("PyCall")'
RUN /opt/conda/bin/pip install julia

RUN /julia-9d11f62bcb/bin/julia -e 'Pkg.add("Knet")'
RUN /julia-9d11f62bcb/bin/julia -e 'Pkg.add("Flux")'
RUN /julia-9d11f62bcb/bin/julia -e 'ENV["JUPYTER"] = "/opt/conda/bin/jupyter"; Pkg.add("IJulia")'

ADD build_tensorflow.sh /root
RUN bash build_tensorflow.sh
