#!/bin/bash

set -e

export PATH=`realpath ../gcc-arm-9.2-2019.12-x86_64-aarch64-none-linux-gnu/bin`:$PATH
echo $PATH

CURRENTDIR=`pwd`
echo "CURRENTDIR: ${CURRENTDIR}"
BUILDDIR=${CURRENTDIR}-build-linux
echo "BUILDDIR: ${BUILDDIR}"
if [ -d ${BUILDDIR} ]; then
	echo "clean ${BUILDDIR}"
	rm -rf ${BUILDDIR}
fi
mkdir -p ${BUILDDIR}
exec > >(tee ${BUILDDIR}/log.eaidk-linux.log) 2>&1

echo "******************************"
echo "*     Clean Uboot Config     *"
echo "******************************"
make Q= distclean
echo " * make distclean done! [$?]"

echo "******************************"
echo "*     Make Uboot Config      *"
echo "******************************"
make Q= O=${BUILDDIR} ARCH=arm  CROSS_COMPILE="aarch64-none-linux-gnu-" eaidk-610-rk3399_defconfig
echo " * make rk3399_linux_defconfig done! [$?]"

echo "******************************"
echo "*     Make AArch64 Uboot     *"
echo "******************************"
#make Q= O=${BUILDDIR} ARCH=arm V=1 CROSS_COMPILE="aarch64-none-linux-gnu-" ARCHV=aarch64 --jobs=`nproc` u-boot-dtb.bin
make Q= O=${BUILDDIR} ARCH=arm V=1 CROSS_COMPILE="aarch64-none-linux-gnu-" ARCHV=aarch64 --jobs=`nproc` 
echo " * make done! [$?]"

echo " * All done!"


exit 0



tools/mkimage -n rk3399 -T rksd -d /data/armbian.git/cache/sources/rkbin-tools/rk33/rk3399_ddr_933MHz_v1.25.bin idbloader.bin

cat /data/armbian.git/cache/sources/rkbin-tools/rk33/rk3399_miniloader_v1.26.bin >> idbloader.bin

/data/armbian.git/cache/sources/rkbin-tools/tools/loaderimage --pack --uboot ./u-boot-dtb.bin uboot.img 0x200000

/data/armbian.git/cache/sources/rkbin-tools/tools/trust_merger --replace bl31.elf /data/armbian.git/cache/sources/rkbin-tools/rk33/rk3399_bl31_v1.35.elf trust.ini


