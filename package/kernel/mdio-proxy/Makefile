# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=mdio-proxy
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/nxp-qoriq/mdio-proxy-module.git
PKG_SOURCE_DATE:=2023-12-18
PKG_SOURCE_VERSION:=d2362c958abf9d17f62fe60817572de7c9714384
PKG_MIRROR_HASH:=1882a002efd0c9b7f8b011983ef43b51e26821f88cd3cc39d6a9aa12b57e8b71

PKG_LICENSE:=Dual BSD/GPL
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

define KernelPackage/mdio-proxy
  SUBMENU:=Network Devices
  TITLE:=NXP MDIO userspace proxy
  DEPENDS:=+kmod-libphy
  FILES:=$(PKG_BUILD_DIR)/mdio-proxy.ko
  AUTOLOAD:=$(call AutoLoad,35,mdio-proxy)
endef

define KernelPackage/mdio-proxy/description
Expose registered MDIO buses to userspace through the NXP MDIO proxy netlink
interface.
endef

define Build/Compile
	+$(KERNEL_MAKE) M="$(PKG_BUILD_DIR)" modules
endef

$(eval $(call KernelPackage,mdio-proxy))
