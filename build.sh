#!/bin/bash

function compile() 
{
rm -rf AnyKernel
source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
export ARCH=arm64
export KBUILD_BUILD_HOST=GITHUB
export KBUILD_BUILD_USER="DP00XD"
if [ ! -d "clang" ]; then
    wget "https://gitlab.com/clangsantoni/aosp_clang/-/archive/clang-r510928/aosp_clang-clang-r510928.tar.gz?ref_type=heads" -O "aosp-clang.tar.gz"
    mkdir clang && tar -xf aosp-clang.tar.gz -C clang --strip-components=1 && rm -rf aosp-clang.tar.gz
fi

[ -d "out" ] && rm -rf out || mkdir -p out

make O=out ARCH=arm64 RMX2020_defconfig

PATH="${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      CC="clang" \
                      LLVM=1 \
                      CONFIG_NO_ERROR_ON_MISMATCH=y
}

zipping() {
    IMAGE="out/arch/arm64/boot/Image.gz-dtb"

    if [[ ! -f "$IMAGE" ]]; then
        echo "❌ ERROR: Kernel image not found at $IMAGE"
        echo "❌ Aborting zip process."
        return 1
    fi

    git clone --depth=1 https://github.com/Realme-Monet/AnyKernel3.git AnyKernel || return 1
    cp "$IMAGE" AnyKernel || return 1

    DATE=$(date +"%Y%m%d-%H%M")
    ZIP_NAME="AETHER-${DATE}-OSS-MONET.zip"

    (
        cd AnyKernel || exit 1
        zip -r9 "$ZIP_NAME" .
        echo "✅ Zip created successfully: $ZIP_NAME"
    )
}

compile
zipping
