#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/intel/oneapi/mkl/2022.2.0/lib/intel64
# MKL_DPCPP_ROOT=/opt/intel/oneapi/mkl/2022.2.0
# MKL_INTEL64=${MKL_DPCPP_ROOT}/lib/intel64

COMPILER_LIB=/opt/intel/oneapi/compiler/2023.0.0/linux/lib
COMPILER_LIB2=/opt/intel/oneapi/compiler/2023.0.0/linux/compiler/lib/intel64_lin
# export LD_PRELOAD=${MKL_INTEL64}libmkl_intel_lp64.so.2:${MKL_INTEL64}/libmkl_intel_ilp64.so.2:${MKL_INTEL64}/libmkl_sequential.so.2:${MKL_INTEL64}/libmkl_core.so.2:${MKL_INTEL64}/libmkl_sycl.so.2:${COMPILER_LIB}/libsycl.so.5
MKL_LIB22=/opt/intel/oneapi/mkl/2022.2.0/lib/intel64
MKL_LIB23=/opt/intel/oneapi/mkl/2023.0.0/lib/intel64
PYTHON39_LIB=/opt/intel/oneapi/intelpython/python3.9/lib
# export LD_PRELOAD=${MKL_INTEL64}libmkl_intel_lp64.so.2:${MKL_INTEL64}/libmkl_intel_ilp64.so.2:${MKL_INTEL64}/libmkl_sequential.so.2:${MKL_INTEL64}/libmkl_core.so.2:${MKL_INTEL64}/libmkl_sycl.so.2:${COMPILER_LIB}/libsycl.so.5
source /opt/intel/oneapi/setvars.sh
usepython39=0
if [[ usepython39 -eq 1 ]]; then
    export LD_LIBRARY_PATH=$PYTHON39_LIB
    python3.9 Upscaling/test.py
else
export LD_PRELOAD=${MKL_LIB23}/libmkl_sycl.so.3
    export LD_LIBRARY_PATH=$COMPILER_LIB:$COMPILER_LIB2:$MKL_LIB22:$MKL_LIB23
    python Upscaling/test.py
fi
# echo "MKL_DPCPP_ROOT is $MKL_DPCPP_ROOT"
# echo "LD_LIBRARY_PATH result is $LD_LIBRARY_PATH"
