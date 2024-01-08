#!/usr/bin/env bash

# Source Configs
source $CONFIG
cd ${KERNEL_DIR}

function info() {
    KERNEL_VERSION=$(cat $KERNEL_DIR/out/.config | grep Linux/arm64 | cut -d " " -f3)
    UTS_VERSION=$(cat $KERNEL_DIR/out/include/generated/compile.h | grep UTS_VERSION | cut -d '"' -f2)
    TOOLCHAIN_VERSION=$(cat $KERNEL_DIR/out/include/generated/compile.h | grep LINUX_COMPILER | cut -d '"' -f2)
    TRIGGER_SHA="$(git rev-parse HEAD)"
    LATEST_COMMIT="$(git log --pretty=format:'%s' -1)"
    COMMIT_BY="$(git log --pretty=format:'by %an' -1)"
    BRANCH="$(git rev-parse --abbrev-ref HEAD)"
}

function push() {
    cd ${HOME}
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$TG_TOKEN/sendDocument" \
        -F chat_id="$TG_CHAT_ID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="
==========================
<b>👤 Owner:</b> $KBUILD_BUILD_USER
<b>🏚️ Linux version:</b> $KERNEL_VERSION
<b>🌿 Branch:</b> $KERNEL_BRANCH
<b>🎁 Top commit:</b> $LATEST_COMMIT
<b>🧧 SHA1:</b> $(sha1sum "$ZIP" | cut -d' ' -f1)
<b>📚 MD5:</b> $(md5sum "$ZIP" | cut -d' ' -f1)
<b>👩‍💻 Commit author:</b> $COMMIT_BY
<b>🐧 UTS version:</b> $UTS_VERSION
<b>💡 Compiler:</b> $TOOLCHAIN_VERSION
==========================
<b>🔋 For all change, look in:</b> <a href=\"$KERNEL_SOURCE/commits/$KERNEL_BRANCH\">Here</a>

Compile took $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
}

if [[ $1 = "-r" || $1 = "--regen" ]]; then
    make O=out ARCH=arm64 $DEFCONFIG savedefconfig
    cp out/defconfig arch/arm64/configs/$DEFCONFIG
    exit
fi

if [[ $1 = "-c" || $1 = "--clean" ]]; then
    rm -rf out
fi

KBUILD_COMPILER_STRING="$("$GCC_64_DIR"/bin/aarch64-linux-android-gcc --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"
echo ================================================
echo "              __  ______  ______              "
echo "             /  |/  / _ \/_  __/              "
echo "        __  / /|_/ / , _/ / /  __             "
echo "       /_/ /_/  /_/_/|_| /_/  /_/             "
echo "    ___  ___  ____     _________________      "
echo "   / _ \/ _ \/ __ \__ / / __/ ___/_  __/      "
echo "  / ___/ , _/ /_/ / // / _// /__  / /         "
echo " /_/  /_/|_|\____/\___/___/\___/ /_/          "
echo ================================================
echo BUILDER NAME = ${KBUILD_BUILD_USER}
echo BUILDER HOSTNAME = ${KBUILD_BUILD_HOST}
echo CONFIG NAME = ${DEFCONFIG}
echo TOOLCHAIN VERSION = ${KBUILD_COMPILER_STRING}
echo DATE = $(TZ=Asia/Jakarta date +"%Y%m%d-%H%M")
echo ================================================

mkdir -p out
make O=out ARCH=arm64 $DEFCONFIG

msg -e "\nStarting compilation...\n"
make -j$(nproc --all) O=out ARCH=arm64 \
    CC=clang \
    LD=ld.lld \
    AR=llvm-ar \
    AS=llvm-as \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip \
    CROSS_COMPILE=$GCC_64_DIR/bin/aarch64-linux-android- \
    CROSS_COMPILE_ARM32=$GCC_32_DIR/bin/arm-linux-androideabi- \
    CLANG_TRIPLE=aarch64-linux-gnu- Image.gz-dtb dtbo.img

if [ -f "out/arch/arm64/boot/Image.gz-dtb" ] && [ -f "out/arch/arm64/boot/dtbo.img" ]; then
    msg -e "\nKernel compiled succesfully! Zipping up...\n"
    if [ -d "$AK3_DIR" ]; then
        cp -r $AK3_DIR AnyKernel3
        elif ! git clone -q https://github.com/kutemeikito/AnyKernel3; then
        msg1 -e "\nAnyKernel3 repo not found locally and cloning failed! Aborting..."
        exit 1
    fi
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel3
    cp out/arch/arm64/boot/dtbo.img AnyKernel3
    rm -f *zip
    cd AnyKernel3
    git checkout master &> /dev/null
    zip -r9 "${HOME}/${ZIPNAME}" * -x '*.git*' README.md *placeholder
    cd ..
    rm -rf AnyKernel3
    rm -rf out/arch/arm64/boot
    msg -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
    msg "Zip: ${ZIPNAME}"
    info
    push
    else
    msg1 -e "\nCompilation failed!"
    exit 1
fi
