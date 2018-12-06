MV_KERNEL_BRANCH ?= "mvl-4.14/msd.eval.xilinx-zynq"
MV_KERNEL_TREE ?= "git://github.com/MontaVista-OpenSourceTechnology/linux-mvista-2.4.git;protocol=https"
MV_KERNELCACHE_BRANCH ?= "yocto-4.14"
MV_KERNELCACHE_TREE ?= "git://github.com/MontaVista-OpenSourceTechnology/yocto-kernel-cache;protocol=https"

require recipes-kernel/linux/linux-yocto.inc

SRCREV_machine ?= "${MV_KERNEL_BRANCH}"
SRCREV_meta ?= "${MV_KERNELCACHE_BRANCH}"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"


S = "${WORKDIR}/git"

LINUX_VERSION = "4.14"
KERNEL_VERSION_SANITY_SKIP="1"
PV = "${LINUX_VERSION}+git${SRCPV}"

SRC_URI = "${MV_KERNEL_TREE};branch=${MV_KERNEL_BRANCH};name=machine \
           ${MV_KERNELCACHE_TREE};type=kmeta;name=meta;branch=${MV_KERNELCACHE_BRANCH};destsuffix=${KMETA}"
SRC_URI += "file://defconfig"

DEPENDS += "elfutils-native"

KMETA = "kernel-meta"
KCONF_BSP_AUDIT_LEVEL = "0"
COMPATIBLE_MACHINE_zedboard-zynq7 = "zedboard-zynq7"
COMPATIBLE_MACHINE_zc702_zynq7 = "zc702-zynq7"
