# SPDX-License-Identifier: GPL-2.0-only
# EFI disk builders adapted from target/linux/armsr/image/Makefile.

GRUB_TERMINALS :=
GRUB_SERIAL_CONFIG :=
GRUB_CONSOLE_CMDLINE_DEFAULT := earlycon

ifneq ($(CONFIG_GRUB_CONSOLE),)
  GRUB_TERMINALS += console
endif

GRUB_SERIAL := $(call qstrip,$(CONFIG_TARGET_SERIAL))
ifneq ($(GRUB_SERIAL),)
  GRUB_CONSOLE_CMDLINE_DEFAULT += console=$(GRUB_SERIAL),$(CONFIG_GRUB_BAUDRATE)n8$(if $(CONFIG_GRUB_FLOWCONTROL),r,)
  GRUB_SERIAL_CONFIG := serial --unit=0 --speed=$(CONFIG_GRUB_BAUDRATE) --word=8 --parity=no --stop=1 --rtscts=$(if $(CONFIG_GRUB_FLOWCONTROL),on,off)
  GRUB_TERMINALS += serial
endif

GRUB_TERMINAL_CONFIG := terminal_input $(GRUB_TERMINALS); terminal_output $(GRUB_TERMINALS)
GRUB_TIMEOUT := $(call qstrip,$(CONFIG_GRUB_TIMEOUT))
GRUB_TITLE := $(call qstrip,$(CONFIG_GRUB_TITLE))

DEVICE_VARS += GRUB_CONSOLE_CMDLINE

define Build/ls-grub-config
	$(INSTALL_DIR) $@.boot/efi/openwrt
	sed \
		-e 's#@SERIAL_CONFIG@#$(strip $(GRUB_SERIAL_CONFIG))#g' \
		-e 's#@TERMINAL_CONFIG@#$(strip $(GRUB_TERMINAL_CONFIG))#g' \
		-e 's#@GPT_ROOTPART@#root=$(GPT_ROOTPART) rootwait#g' \
		-e 's#@CMDLINE@#$(BOOTOPTS) $(GRUB_CONSOLE_CMDLINE)#g' \
		-e 's#@TIMEOUT@#$(GRUB_TIMEOUT)#g' \
		-e 's#@TITLE@#$(GRUB_TITLE)#g' \
		-e 's#@DEVICE_DTS@#$(DEVICE_DTS)#g' \
		./grub-efi.cfg > $@.boot/efi/openwrt/grub.cfg
endef

define Build/ls-combined-efi
	$(CP) $(IMAGE_KERNEL) $@.boot/efi/openwrt/Image
	$(CP) $(KDIR)/image-$(DEVICE_DTS).dtb $@.boot/efi/openwrt/$(DEVICE_DTS).dtb
	$(INSTALL_DIR) $@.boot/efi/boot
	$(CP) $(STAGING_DIR_IMAGE)/grub2/bootaa64.efi $@.boot/efi/boot/
	$(CP) $(STAGING_DIR_IMAGE)/grub2/bootaa64.efi $@.boot/efi/openwrt/
	# Pure UEFI needs no BIOS boot partition in the GPT alignment gap.
	KERNELPARTTYPE=ef GPT_NO_STUB="1" PADDING="1" \
		SIGNATURE="$(IMG_PART_SIGNATURE)" GUID="$(IMG_PART_DISKGUID)" \
		$(SCRIPT_DIR)/gen_image_generic.sh \
		$@ \
		$(CONFIG_TARGET_KERNEL_PARTSIZE) $@.boot \
		$(CONFIG_TARGET_ROOTFS_PARTSIZE) $(IMAGE_ROOTFS) \
		256
endef
