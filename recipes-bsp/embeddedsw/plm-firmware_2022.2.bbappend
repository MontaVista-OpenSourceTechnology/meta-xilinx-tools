# Should not need any external patches
SRC_URI = "${EMBEDDEDSW_SRCURI}"

# We WANT to default to this version when available
DEFAULT_PREFERENCE = "100"

inherit xsctapp xsctyaml

# This needs to match the value in plmfw.bbappend
PLM_IMAGE_NAME = "plm-${MACHINE}"

B = "${S}/${XSCTH_PROJ}"

XSCTH_PROC_IP = "psv_pmc"
XSCTH_PROC_IP:versal-net = "psx_pmc"
XSCTH_APP  = "versal PLM"

# XSCT version provides it's own toolchain, so can build in any environment
COMPATIBLE_HOST:versal = "${HOST_SYS}"

# Clear this for a Linux build, using the XSCT toolchain
EXTRA_OEMAKE:linux = ""

# Workaround for hardcoded toolchain items
XSCT_PATH_ADD:append:elf = "\
${UNPACKDIR}/bin:"

MB_OBJCOPY = "mb-objcopy"

do_compile:prepend:elf() {
  mkdir -p ${UNPACKDIR}/bin
  echo "#! /bin/bash\n${CC} \$@" > ${UNPACKDIR}/bin/mb-gcc
  echo "#! /bin/bash\n${AS} \$@" > ${UNPACKDIR}/bin/mb-as
  echo "#! /bin/bash\n${AR} \$@" > ${UNPACKDIR}/bin/mb-ar
  echo "#! /bin/bash\n${AR} \$@" > ${UNPACKDIR}/bin/mb-gcc-ar
  echo "#! /bin/bash\n${OBJCOPY} \$@" > ${UNPACKDIR}/bin/mb-objcopy
  chmod 0755 ${UNPACKDIR}/bin/mb-gcc
  chmod 0755 ${UNPACKDIR}/bin/mb-as
  chmod 0755 ${UNPACKDIR}/bin/mb-ar
  chmod 0755 ${UNPACKDIR}/bin/mb-gcc-ar
  chmod 0755 ${UNPACKDIR}/bin/mb-objcopy
}

do_compile:append() {
  ${MB_OBJCOPY} -O binary ${B}/${XSCTH_PROJ}/executable.elf ${B}/${XSCTH_PROJ}/executable.bin
}

# xsctapp sets it's own do_install, replace it with the real one
do_install() {
    :
}

do_deploy() {
    install -Dm 0644 ${B}/${XSCTH_PROJ}/executable.elf ${DEPLOYDIR}/${PLM_BASE_NAME}.elf
    ln -sf ${PLM_BASE_NAME}.elf ${DEPLOYDIR}/${PLM_IMAGE_NAME}.elf
    install -m 0644 ${B}/${XSCTH_PROJ}/executable.bin ${DEPLOYDIR}/${PLM_BASE_NAME}.bin
    ln -sf ${PLM_BASE_NAME}.bin ${DEPLOYDIR}/${PLM_IMAGE_NAME}.bin
}
