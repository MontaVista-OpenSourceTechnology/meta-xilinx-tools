DESCRIPTION = "Device Tree generation and packaging for BSP Device Trees using DTG from Xilinx"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://xadcps/data/xadcps.mdd;md5=f7fa1bfdaf99c7182fc0d8e7fd28e04a"

require recipes-bsp/device-tree/device-tree.inc
inherit xsctdt xsctyaml
BASE_DTS ?= "system-top"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

S = "${WORKDIR}/git"

DT_VERSION_EXTENSION ?= "xilinx-${XILINX_RELEASE_VERSION}"
PV = "${DT_VERSION_EXTENSION}+git${SRCPV}"

XSCTH_BUILD_CONFIG = ""
YAML_COMPILER_FLAGS ?= ""
XSCTH_APP = "device-tree"
XSCTH_MISC = " -hdf_type ${HDF_EXT}"

YAML_MAIN_MEMORY_CONFIG:ultra96 ?= "psu_ddr_0"
YAML_CONSOLE_DEVICE_CONFIG:ultra96 ?= "psu_uart_1"

YAML_MAIN_MEMORY_CONFIG:kc705 ?= "mig_7series_0"
YAML_CONSOLE_DEVICE_CONFIG:kc705 ?= "axi_uartlite_0"

YAML_DT_BOARD_FLAGS:ultra96 ?= "{BOARD avnet-ultra96-rev1}"
YAML_DT_BOARD_FLAGS:zcu102 ?= "{BOARD zcu102-rev1.0}"
YAML_DT_BOARD_FLAGS:zcu106 ?= "{BOARD zcu106-reva}"
YAML_DT_BOARD_FLAGS:zc702 ?= "{BOARD zc702}"
YAML_DT_BOARD_FLAGS:zc706 ?= "{BOARD zc706}"
YAML_DT_BOARD_FLAGS:zedboard ?= "{BOARD zedboard}"
YAML_DT_BOARD_FLAGS:zc1254 ?= "{BOARD zc1254-reva}"
YAML_DT_BOARD_FLAGS:kc705 ?= "{BOARD kc705-full}"
YAML_DT_BOARD_FLAGS:zcu104 ?= "{BOARD zcu104-revc}"
YAML_DT_BOARD_FLAGS:zcu111 ?= "{BOARD zcu111-reva}"
YAML_DT_BOARD_FLAGS:zcu1275 ?= "{BOARD zcu1275-revb}"
YAML_DT_BOARD_FLAGS:zcu1285 ?= "{BOARD zcu1285-reva}"
YAML_DT_BOARD_FLAGS:zcu216 ?= "{BOARD zcu216-reva}"
YAML_DT_BOARD_FLAGS:zcu208 ?= "{BOARD zcu208-reva}"
YAML_DT_BOARD_FLAGS_virt-versal ?= "{BOARD versal-virt}"
YAML_DT_BOARD_FLAGS:vck-sc ?= "{BOARD zynqmp-e-a2197-00-reva}"
YAML_DT_BOARD_FLAGS:v350 ?= "{BOARD versal-v350-reva}"
YAML_DT_BOARD_FLAGS:vck5000 ?= "{BOARD versal-vck5000-reva}"
YAML_DT_BOARD_FLAGS:vck190 ?= "{BOARD versal-vck190-reva-x-ebm-01-reva}"
YAML_DT_BOARD_FLAGS:vmk180 ?= "{BOARD versal-vmk180-reva-x-ebm-01-reva}"
YAML_DT_BOARD_FLAGS:vc-p-a2197-00 ?= "{BOARD versal-vc-p-a2197-00-reva-x-prc-01-reva}"
YAML_DT_BOARD_FLAGS:ac701 ?= "{BOARD ac701-full}"
YAML_DT_BOARD_FLAGS:kc705 ?= "{BOARD kc705-full}"
YAML_DT_BOARD_FLAGS:kcu105 ?= "{BOARD kcu105}"
YAML_DT_BOARD_FLAGS:sp701 ?= "{BOARD sp701-rev1.0}"
YAML_DT_BOARD_FLAGS:vcu118 ?= "{BOARD vcu118-rev2.0}"
YAML_DT_BOARD_FLAGS:k26 ?= "{BOARD zynqmp-sm-k26-reva}"
YAML_DT_BOARD_FLAGS:zcu670 ?= "{BOARD zcu670-revb}"
YAML_DT_BOARD_FLAGS:vpk120 ?= "{BOARD versal-vpk120-reva}"
YAML_DT_BOARD_FLAGS:vpk-sc ?= "{BOARD zynqmp-vpk120-reva}"

YAML_OVERLAY_CUSTOM_DTS = "pl-final.dts"
CUSTOM_PL_INCLUDE_DTSI ?= ""
EXTRA_DT_FILES ?= ""
EXTRA_OVERLAYS ?= ""

DT_FILES_PATH = "${XSCTH_WS}/${XSCTH_PROJ}"
DT_INCLUDE:append = " ${WORKDIR}"
DT_PADDING_SIZE = "0x1000"
DTC_FLAGS:append = "${@['', ' -@'][d.getVar('YAML_ENABLE_DT_OVERLAY') == '1']}"

COMPATIBLE_MACHINE:zynq = ".*"
COMPATIBLE_MACHINE:zynqmp = ".*"
COMPATIBLE_MACHINE:microblaze = ".*"
COMPATIBLE_MACHINE:versal = ".*"

SRC_URI:append:ultra96 = "${@bb.utils.contains('MACHINE_FEATURES', 'mipi', ' file://mipi-support-ultra96.dtsi file://pl.dtsi', '', d)}"

SRC_URI:append = "${@" ".join(["file://%s" % f for f in (d.getVar('EXTRA_DT_FILES') or "").split()])}"
SRC_URI:append = "${@['', ' file://${CUSTOM_PL_INCLUDE_DTSI}'][d.getVar('CUSTOM_PL_INCLUDE_DTSI') != '']}"
SRC_URI:append = "${@" ".join(["file://%s" % f for f in (d.getVar('EXTRA_OVERLAYS') or "").split()])}"

do_configure[cleandirs] += "${DT_FILES_PATH} ${B}"
do_deploy[cleandirs] += "${DEPLOYDIR}"

do_configure:append:ultra96() {
        if [ -e ${WORKDIR}/mipi-support-ultra96.dtsi ]; then
               cp ${WORKDIR}/mipi-support-ultra96.dtsi ${DT_FILES_PATH}/mipi-support-ultra96.dtsi
               cp ${WORKDIR}/pl.dtsi ${DT_FILES_PATH}/pl.dtsi
               echo '/include/ "mipi-support-ultra96.dtsi"' >> ${DT_FILES_PATH}/${BASE_DTS}.dts
        fi
}

do_configure:append () {
    if [ -n "${CUSTOM_PL_INCLUDE_DTSI}" ]; then
        [ ! -f "${CUSTOM_PL_INCLUDE_DTSI}" ] && bbfatal "Please check that the correct filepath was provided using CUSTOM_PL_INCLUDE_DTSI"
        cp ${WORKDIR}/${CUSTOM_PL_INCLUDE_DTSI} ${XSCTH_WS}/${XSCTH_PROJ}/pl-custom.dtsi
    fi

    for f in ${EXTRA_DT_FILES}; do
        cp ${WORKDIR}/${f} ${DT_FILES_PATH}/
    done

    for f in ${EXTRA_OVERLAYS}; do
        cp ${WORKDIR}/${f} ${DT_FILES_PATH}/
        echo "/include/ \"$f\"" >> ${DT_FILES_PATH}/${BASE_DTS}.dts
    done

}

do_compile:prepend() {
    listpath = d.getVar("DT_FILES_PATH")
    try:
        os.remove(os.path.join(listpath, "system.dts"))
    except OSError:
        pass
}

do_install:append:microblaze () {
    for DTB_FILE in `ls *.dtb`; do
        dtc -I dtb -O dts -o ${D}/boot/devicetree/mb.dts ${B}/${DTB_FILE}
    done
}

DTB_FILE_NAME = "${BASE_DTS}.dtb"

FILES:${PN}:append:microblaze = " /boot/devicetree/*.dts"

EXTERNALSRC_SYMLINKS = ""
