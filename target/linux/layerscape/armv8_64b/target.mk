# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2016 Jiang Yutang <jiangyutang1978@gmail.com>

ARCH:=aarch64
BOARDNAME:=ARMv8 64-bit based boards
KERNELNAME:=Image dtbs
DEPENDS:=+@KERNEL_BTRFS_FS +@KERNEL_BTRFS_FS_POSIX_ACL

# Use the ImmortalWrt 24.10.6 kernel package identifier for this kernel release.
LINUX_VERMAGIC_OVERRIDE = $(if $(filter 6.6.133-1,$(LINUX_VERSION)-$(LINUX_RELEASE)),80d60e5e25c8b4f01df92769064a3bbe)

define Target/Description
	Build firmware images for NXP Layerscape ARMv8 64-bit based boards.
endef
