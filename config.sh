#!/bin/bash

# Derectory Default
MRT_DIR="${HOME}/MRT"

# Code Name Of Device
DEVICE_CODENAME="ginkgo"

# Kernel Source
KERNEL_SOURCE="https://github.com/denialinden/android_kernel_xiaomi_ginkgo"
KERNEL_BRANCH="Fourteen"

# Directory kernel
KERNEL_DIR="${MRT_DIR}/${DEVICE_CODENAME}"

# Toolchain Directory
TC_DIR="${MRT_DIR}/toolchain/linux-x86"
CLANG_DIR="${MRT_DIR}/toolchain/linux-x86/clang-r510928"
GCC_64_DIR="${MRT_DIR}/toolchain/aarch64-linux-android-4.9"
GCC_32_DIR="${MRT_DIR}/toolchain/arm-linux-androideabi-4.9"
AK3_DIR="${MRT_DIR}/android/AnyKernel3"

# Default config
export PATH="${CLANG_DIR}/bin:${PATH}"
export KBUILD_BUILD_USER="M•R•T"
export KBUILD_BUILD_HOST="Project"
export KBUILD_BUILD_VERSION="1"

SECONDS=0 # builtin bash timer
ZIPNAME="MRT-Kernel-${DEVICE_CODENAME}-$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M").zip"
DEFCONFIG="vendor/ginkgo-perf_defconfig"
