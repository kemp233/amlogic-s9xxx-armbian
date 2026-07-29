echo "Boot script loaded from ${devtype} ${devnum}"

setenv distro_bootpart 1

setenv bootargs "earlyprintk ${earlyprintk} rw root=UUID=0ca07788-d938-4baf-bc11-65ca871087ca rootfstype=ext4 rootwait fsck.repair=yes panic=0 ${bootargs_extra} consoleblank=0 loglevel=0 rootflags=data=journal"

setenv image "/Image"
setenv ramdisk "uInitrd"
setenv dtbdir "/boot/dtb"
setenv ftd_file "${ftdtree}"

fatload ${devtype} ${devnum}:${distro_bootpart} ${ramdisk_addr_r} ${ramdisk}
fatload ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} ${image}
fatload ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${dtbdir}/${ftdtree}

# Detect RK3566 board
if test -e ${devtype} ${devnum}:${distro_bootpart} ${dtbdir}/rockchip/rk3566-lb2004.dtb; then
  fdt addr ${fdt_addr_r}
  fatload ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${dtbdir}/rockchip/rk3566-lb2004.dtb
else
  setenv fdt_addr_r ""
fi

booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}

# mkimage -C none -A arm64 -T script -d boot.cmd boot.scr