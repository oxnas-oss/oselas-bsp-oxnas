# -*-makefile-*-
#
# Copyright (C) 2005-2008 by Robert Schwebel
#               2012 by Michael Olbrich <m.olbrich@pengutronix.de>
#               2013 by Stephan Linz <linz@li-pro.net>
#
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
PACKAGES-$(PTXCONF_UDEV) += udev

#
# Paths and names
#
ifdef PTXCONF_SYSTEMD
UDEV_VERSION	= $(SYSTEMD_VERSION)
UDEV		= $(SYSTEMD)
else
ifdef PTXCONF_UDEV_LEGACY
#UDEV_VERSION	:= 145
#UDEV_MD5	:= b3d3b5f88c7b81e7615700a04db685e1
UDEV_VERSION	:= 150
UDEV_MD5	:= 4ad5ada5f5cefb2517996825c1d2a7d6
#UDEV_VERSION	:= 172
#UDEV_MD5	:= bd122d04cf758441f498aad0169a454f
else
UDEV_VERSION	:= 182
UDEV_MD5	:= e31c83159b017e8ab0fa2f4bca758a41
endif
UDEV		:= udev-$(UDEV_VERSION)
UDEV_SUFFIX	:= tar.bz2
UDEV_URL	:= $(call ptx/mirror, KERNEL, utils/kernel/hotplug/$(UDEV).$(UDEV_SUFFIX))
UDEV_SOURCE	:= $(SRCDIR)/$(UDEV).$(UDEV_SUFFIX)
UDEV_DIR	:= $(BUILDDIR)/$(UDEV)
UDEV_LICENSE	:= GPLv2

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

#
# autoconf
#
UDEV_CONF_ENV := \
	$(CROSS_ENV) \
	CPPFLAGS="-I$(KERNEL_HEADERS_INCLUDE_DIR) $(CROSS_CPPFLAGS)"

UDEV_CONF_TOOL	:= autoconf
UDEV_CONF_OPT	:= \
	$(CROSS_AUTOCONF_ROOT) \
	$(GLOBAL_LARGE_FILE_OPTION) \
	--disable-static \
	--enable-shared \
	--disable-gtk-doc \
	--disable-gtk-doc-html \
	--disable-gtk-doc-pdf \
	--$(call ptx/endis,PTXCONF_UDEV_DEBUG)-debug \
	--$(call ptx/endis,PTXCONF_UDEV_SYSLOG)-logging \
	--$(call ptx/endis,PTXCONF_UDEV_LIBGUDEV)-gudev \
	--disable-introspection \
	--$(call ptx/endis,PTXCONF_UDEV_KEYMAPS)-keymap \
	--without-selinux \
	--with-pci-ids-path=/usr/share/pci.ids$(call ptx/ifdef, PTXCONF_PCIUTILS_COMPRESS,.gz,) \

ifdef PTXCONF_UDEV_LEGACY
#UDEV_CONF_OPT += \
#	--$(call ptx/endis,PTXCONF_UDEV_ACL)-udev_acl \
#	--$(call ptx/endis,PTXCONF_UDEV_PERSISTENT_EDD)-edd \
#	--libexecdir=/lib/udev \
#	--enable-hwdb
UDEV_CONF_OPT += \
	--disable-bluetooth \
	--disable-modem-modeswitch \
	\
	--with-kernel-headers-dir=$(KERNEL_HEADERS_INCLUDE_DIR) \
	--$(call ptx/endis,PTXCONF_UDEV_ACL)-acl \
	--$(call ptx/endis,PTXCONF_UDEV_PERSISTENT_PCI)-pcidb \
	--$(call ptx/endis,PTXCONF_UDEV_PERSISTENT_USB)-usbdb \
	--libexecdir=/lib/udev
else
UDEV_CONF_OPT += \
	--disable-manpages \
	--libexecdir=/lib \
	--with-rootprefix= \
	--with-rootlibdir=/lib \
	--$(call ptx/endis,PTXCONF_UDEV_MTD_PROBE)-mtd_probe \
	\
	--$(call ptx/endis,PTXCONF_UDEV_PERSISTENT_GENERATOR)-rule_generator \
	--disable-floppy \
	--with-usb-ids-path=/usr/share/usb.ids \
	--with-systemdsystemunitdir=/lib/systemd/system
endif

endif # PTXCONF_SYSTEMD

UDEV_RULES-y := \
	50-udev-default.rules \
	60-persistent-alsa.rules \
	60-persistent-input.rules \
	60-persistent-serial.rules \
	60-persistent-storage-tape.rules \
	60-persistent-storage.rules \
	95-udev-late.rules

ifndef PTXCONF_UDEV_LEGACY

UDEV_RULES-y += \
	42-usb-hid-pm.rules \
	75-net-description.rules \
	75-tty-description.rules \
	78-sound-card.rules

else

ifdef PTXCONF_UDEV_PERSISTENT_USB
ifdef PTXCONF_UDEV_PERSISTENT_PCI
UDEV_RULES-y += \
	75-net-description.rules \
	75-tty-description.rules \
	78-sound-card.rules
endif
endif

endif

ifdef PTXCONF_SYSTEMD

UDEV_RULES-y += \
	70-power-switch.rules \
	70-uaccess.rules \
	71-seat.rules \
	73-seat-late.rules

endif

UDEV_RULES-$(PTXCONF_UDEV_ACCELEROMETER)	+= 61-accelerometer.rules	# YES
ifdef PTXCONF_UDEV_LEGACY
UDEV_RULES-$(PTXCONF_UDEV_ACL)			+= 70-acl.rules		# YES
else
UDEV_RULES-$(PTXCONF_UDEV_ACL)			+= 70-udev-acl.rules		# YES
endif
UDEV_RULES-$(PTXCONF_UDEV_DRIVERS_RULES)	+= 80-drivers.rules	# YES
UDEV_RULES-$(PTXCONF_UDEV_KEYMAPS)		+= 95-keyboard-force-release.rules	# YES
UDEV_RULES-$(PTXCONF_UDEV_KEYMAPS)		+= 95-keymap.rules	# YES
UDEV_RULES-$(PTXCONF_UDEV_MTD_PROBE)		+= 75-probe_mtd.rules	# YES
UDEV_RULES-$(PTXCONF_UDEV_PERSISTENT_CDROM)	+= 60-cdrom_id.rules	# YES
UDEV_RULES-$(PTXCONF_UDEV_PERSISTENT_EDD)	+= 61-persistent-storage-edd.rules	# YES
UDEV_RULES-$(PTXCONF_UDEV_PERSISTENT_GENERATOR)	+= 75-cd-aliases-generator.rules	# YES
UDEV_RULES-$(PTXCONF_UDEV_PERSISTENT_GENERATOR)	+= 75-persistent-net-generator.rules	# YES
UDEV_RULES-$(PTXCONF_UDEV_PERSISTENT_V4L)	+= 60-persistent-v4l.rules	# YES

UDEV_HELPER-$(PTXCONF_UDEV_ACCELEROMETER)		+= accelerometer		# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_ATA)		+= ata_id	# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_CDROM)		+= cdrom_id	# YES
UDEV_HELPER-$(PTXCONF_UDEV_COLLECT)			+= collect	# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_EDD)		+= edd_id	# YES
UDEV_HELPER-$(PTXCONF_UDEV_KEYMAPS)			+= findkeyboards	# YES
UDEV_HELPER-$(PTXCONF_UDEV_KEYMAPS)			+= keyboard-force-release.sh	# YES
UDEV_HELPER-$(PTXCONF_UDEV_KEYMAPS)			+= keymap	# YES
UDEV_HELPER-$(PTXCONF_UDEV_MTD_PROBE)			+= mtd_probe		# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_GENERATOR)	+= rule_generator.functions	# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_SCSI)		+= scsi_id	# YES
UDEV_HELPER-$(PTXCONF_UDEV_ACL)				+= udev-acl		# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_V4L)		+= v4l_id	# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_GENERATOR)	+= write_cd_rules	# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_GENERATOR)	+= write_net_rules	# YES

ifdef PTXCONF_UDEV_LEGACY
UDEV_RULES-$(PTXCONF_UDEV_LEGACY)			+= 50-firmware.rules	# YES
UDEV_HELPER-$(PTXCONF_UDEV_LEGACY)			+= firmware	# YES
UDEV_HELPER-$(PTXCONF_UDEV_LEGACY)			+= input_id	# YES
UDEV_HELPER-$(PTXCONF_UDEV_LEGACY)			+= path_id	# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_PCI)		+= pci-db	# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_USB)		+= usb-db	# YES
UDEV_HELPER-$(PTXCONF_UDEV_PERSISTENT_USB)		+= usb_id	# YES
endif

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ifdef PTXCONF_SYSTEMD
$(STATEDIR)/udev.extract.post: $(STATEDIR)/systemd.install.post
$(STATEDIR)/udev.install.unpack: $(STATEDIR)/systemd.install.post
endif

$(STATEDIR)/udev.targetinstall:
	@$(call targetinfo)

	@$(call install_init, udev)
	@$(call install_fixup, udev,PRIORITY,optional)
	@$(call install_fixup, udev,SECTION,base)
	@$(call install_fixup, udev,AUTHOR,"Stephan Linz <linz@li-pro.net>")
	@$(call install_fixup, udev,DESCRIPTION,missing)

ifdef PTXCONF_UDEV_ETC_CONF	# YES
	@$(call install_alternative, udev, 0, 0, 0644, /etc/udev/udev.conf)
endif

ifdef PTXCONF_UDEV_LEGACY	# YES
	@$(call install_copy, udev, 0, 0, 0755, -, /sbin/udevd)
	@$(call install_copy, udev, 0, 0, 0755, -, /sbin/udevadm)
else
ifdef PTXCONF_SYSTEMD
	@$(call install_copy, udev, 0, 0, 0755, -, /lib/systemd/systemd-udevd)
	@$(call install_copy, udev, 0, 0, 0755, -, /usr/bin/udevadm)
else
	@$(call install_copy, udev, 0, 0, 0755, -, /lib/udev/udevd)
	@$(call install_copy, udev, 0, 0, 0755, -, /bin/udevadm)
endif
endif

	@$(foreach rule, $(UDEV_RULES-y), \
		$(call install_copy, udev, 0, 0, 0644, -, \
			/lib/udev/rules.d/$(rule));)

ifdef PTXCONF_UDEV_KEYMAPS	# YES
	@cd $(UDEV_PKGDIR) && \
	for keymap in `find lib/udev/keymaps/ -type f`; do \
		$(call install_copy, udev, 0, 0, 0644, -, /$$keymap); \
	done
endif

ifdef PTXCONF_UDEV_CUST_RULES
	@if [ -d $(PTXDIST_WORKSPACE)/projectroot/lib/udev/rules.d/ ]; then \
		$(call install_tree, udev, 0, 0, \
			$(PTXDIST_WORKSPACE)/projectroot/lib/udev/rules.d, \
			/lib/udev/rules.d); \
	else \
		echo "UDEV_CUST_RULES is enabled but Directory containing" \
			"customized udev rules is missing!"; \
		exit 1; \
	fi
endif

	@$(foreach helper, $(UDEV_HELPER-y), \
		$(call install_copy, udev, 0, 0, 0755, -, \
			/lib/udev//$(helper));)

ifdef PTXCONF_UDEV_ACL		# YES
	@$(call install_link, udev, ../../udev/udev-acl, \
		/lib/ConsoleKit/run-seat.d/udev-acl.ck)
endif

ifdef PTXCONF_UDEV_LIBUDEV	# YES
	@$(call install_lib, udev, 0, 0, 0644, libudev)
endif

ifdef PTXCONF_UDEV_LIBGUDEV	# YES
	@$(call install_lib, udev, 0, 0, 0644, libgudev-1.0)
endif

ifdef PTXCONF_UDEV_STARTSCRIPT
ifdef PTXCONF_INITMETHOD_BBINIT
	@$(call install_alternative, udev, 0, 0, 0755, /etc/init.d/udev)

ifneq ($(call remove_quotes,$(PTXCONF_UDEV_BBINIT_LINK)),)
	@$(call install_link, udev, \
		../init.d/udev, \
		/etc/rc.d/$(PTXCONF_UDEV_BBINIT_LINK))
endif
endif
ifdef PTXCONF_INITMETHOD_UPSTART
	@$(call install_alternative, udev, 0, 0, 0644, /etc/init/udev.conf)
	@$(call install_alternative, udev, 0, 0, 0644, /etc/init/udevmonitor.conf)
	@$(call install_alternative, udev, 0, 0, 0644, /etc/init/udevtrigger.conf)
	@$(call install_alternative, udev, 0, 0, 0644, /etc/init/udev-finish.conf)
endif
endif
	@$(call install_finish, udev)

	@$(call touch)

# vim: syntax=make
