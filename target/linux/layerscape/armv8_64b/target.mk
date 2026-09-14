# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2016 Jiang Yutang <jiangyutang1978@gmail.com>

ARCH:=aarch64
BOARDNAME:=ARMv8 64-bit based boards
KERNELNAME:=Image dtbs
DEPENDS:=+@KERNEL_BTRFS_FS +@KERNEL_BTRFS_FS_POSIX_ACL

# Use the ImmortalWrt 25.12.2 kernel package identifier for this kernel release.
LINUX_VERMAGIC_OVERRIDE = $(if $(filter 6.12.103-1,$(LINUX_VERSION)-$(LINUX_RELEASE)),92fad1cbb3e6ab1597360641d4c15d49)

define Target/Description
	Build firmware images for NXP Layerscape ARMv8 64-bit based boards.
endef
