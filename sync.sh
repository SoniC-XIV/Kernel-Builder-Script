#!/usr/bin/env bash

# Source Configs
source $CONFIG

if ! [ -d "${KERNEL_DIR}" ]; then
    echo "Clonning kernel source..."
    if ! git clone --depth 1 ${KERNEL_SOURCE} -b ${KERNEL_BRANCH} ${MRT_DIR}/${DEVICE_CODENAME}; then
        echo "Cloning failed! Aborting..."
        exit 1
    fi
fi

if ! [ -d "${CLANG_DIR}" ]; then
    echo "Clonning toolchain clang..."
    if ! git clone --depth 1 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 ${TC_DIR}; then
        echo "Cloning failed! Aborting..."
        exit 1
    fi
fi

if ! [ -d "${GCC_64_DIR}" ]; then
    echo "Clonning gcc toolchain arm64..."
    if ! git clone --depth=1 -b lineage-19.1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9.git ${GCC_64_DIR}; then
        echo "Cloning failed! Aborting..."
        exit 1
    fi
fi

if ! [ -d "${GCC_32_DIR}" ]; then
    echo "Clonning gcc toolchain arm..."
    if ! git clone --depth=1 -b lineage-19.1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9.git ${GCC_32_DIR}; then
        echo "Cloning failed! Aborting..."
        exit 1
    fi
fi
