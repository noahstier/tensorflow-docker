# install bazel, tensorflow's build tool

wget https://github.com/bazelbuild/bazel/releases/download/0.15.1/bazel-0.15.1-installer-linux-x86_64.sh \
  -O bazel_installer.sh

bash bazel_installer.sh

# build tensorflow

git clone --branch r1.11 https://github.com/tensorflow/tensorflow
cd tensorflow

export PYTHON_BIN_PATH=/opt/conda/bin/python
export PYTHON_LIB_PATH=/opt/conda/lib

export TF_CUDA_VERSION=9.2
export TF_CUDNN_VERSION=7
export CUDA_TOOLKIT_PATH=/usr/local/cuda
export CUDNN_INSTALL_PATH=/usr/lib/x86_64-linux-gnu

# compiler options
export GCC_HOST_COMPILER_PATH=/usr/bin/gcc
export CC_OPT_FLAGS=-march=native
export TF_CUDA_CLANG=0 # set to 1 to use clang instead of gcc

# set this to a comma-separated list according to your gpus.
# capabilities per gpu: https://developer.nvidia.com/cuda-gpus
export TF_CUDA_COMPUTE_CAPABILITIES=6.1

# accelerated computation options
export TF_NEED_CUDA=1  # use nvidia gpus as computation backend
export TF_NEED_JEMALLOC=1  # a supposedly better malloc implementation
export TF_ENABLE_XLA=0  # optimizing compiler (aot / jit) for tensorflow graphs
export TF_NEED_OPENCL=0 # use a bunch of different cpus and gpus as backend
export TF_NEED_OPENCL_SYCL=0 # c++ programming model for opencl
export TF_NEED_TENSORRT=0 # optimized neural net inference
export TF_NEED_NGRAPH=0 # optimizing compiler for deep neural networks

# needed for TF_NEED_OPENCL_SYCL
export HOST_CXX_COMPILER=/usr/bin/g++
export HOST_C_COMPILER=/usr/bin/gcc
export TF_NEED_COMPUTECPP=1
export COMPUTECPP_TOOLKIT_PATH=/usr/local/computecpp

# needed for TF_NEED_TENSORRT

# deployment platform options
export TF_NEED_GCP=0 # google cloud platform
export TF_NEED_AWS=0 # amazon s3 file system

# distributed training options
export TF_NEED_KAFKA=0
export TF_NEED_HDFS=0
export TF_NEED_GDR=0
export TF_NEED_VERBS=0
export TF_NEED_MPI=0

# android-compatible build
export TF_SET_ANDROID_WORKSPACE=0

export TF_NCCL_VERSION=1.3

./configure

# If RAM is an issue on your system, limit RAM usage with --local_resources 2048,.5,1.0
bazel build \
  --config=opt \
  --config=cuda \
  --config=mkl \
  //tensorflow/tools/pip_package:build_pip_package

bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg

conda uninstall -y tensorflow-gpu tensorflow-gpu-base tensorflow-tensorboard
