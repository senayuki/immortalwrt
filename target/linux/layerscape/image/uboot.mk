# SPDX-License-Identifier: GPL-2.0-only
# U-Boot boot script generation; the bootloader is supplied by the firmware.

DEVICE_VARS += BOOT_SCRIPT UBOOT_BOOTARGS UBOOT_KERNEL_ADDR UBOOT_FDT_ADDR UBOOT_DPL_ADDR

define Build/ls-boot-script
	$(if $(BOOT_SCRIPT), \
		sed \
			-e 's#@ROOTPART@#$(GPT_ROOTPART)#g' \
			-e 's#@BOOTARGS@#$(strip $(UBOOT_BOOTARGS))#g' \
			-e 's#@KERNEL_ADDR@#$(UBOOT_KERNEL_ADDR)#g' \
			-e 's#@FDT_ADDR@#$(UBOOT_FDT_ADDR)#g' \
			-e 's#@DPL_ADDR@#$(UBOOT_DPL_ADDR)#g' \
			$(BOOT_SCRIPT).bootscript > $@.boot.cmd
		$(STAGING_DIR_HOST)/bin/mkimage -A arm64 -O linux -T script -C none \
			-a 0 -e 0 -n 'OpenWrt U-Boot boot script' \
			-d $@.boot.cmd $@.boot/boot.scr
		$(RM) $@.boot.cmd
	)
endef
