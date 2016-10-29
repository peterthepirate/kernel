#!/bin/sh

ZCATC=/usr/bin/zcat
MAKEC=/usr/bin/make
MKINITRDC=/sbin/mkinitrd
TARC=/usr/bin/tar
RSYNCC=/usr/bin/rsync
WGETC=/usr/bin/wget
LNC=/usr/bin/ln
CPC=/usr/bin/cp
AWKC=/usr/bin/awk
ECHOC=/usr/bin/echo
LILOC=/sbin/lilo
GPGC=/usr/bin/gpg
UNXZC=/usr/bin/unxz
F=https

if [ ! -z "$1" ]; then

	RELEASE=$1

	if [ ! -f "linux-$RELEASE.tar" ]; then
	
		if [ $F == rsync ]; then
		FETCH=rsync://rsync.kernel.org/pub/linux/kernel/v4.x/linux-$RELEASE.tar.xz
		FETCHS=rsync://rsync.kernel.org/pub/linux/kernel/v4.x/linux-$RELEASE.tar.sign
			$ECHOC "fetching kernel checksum w/ $RSYNCC -av $FETCHS"
			$RSYNCC -av $FETCHS ./
			$ECHOC "done fetching kernel checksum"
		
			$ECHOC "fetching kernel source w/ $RSYNCC -av $FETCH"
			$RSYNCC -av $FETCH ./
			$ECHOC "done fetching kernel source"
		fi
		
		
		if [ $F == https ]; then
		FETCH=https://www.kernel.org/pub/linux/kernel/v4.x/linux-$RELEASE.tar.xz
		FETCHS=https://www.kernel.org/pub/linux/kernel/v4.x/linux-$RELEASE.tar.sign
			$ECHOC "fetching kernel checksum w/ $WGETC -nv $FETCHS"
			$WGETC -nv $FETCHS
			$ECHOC "done fetching kernel checksum"
		
			$ECHOC "fetching kernel source w/ $WGETC -nv $FETCH"
			$WGETC -nv $FETCH
			$ECHOC "done fetching kernel source"
		fi

			$ECHOC "verifying kernel source integrity w/ $GPGC --verify linux-$RELEASE.tar.sign"
			$UNXZC linux-$RELEASE.tar.xz
			$GPGC --verify linux-$RELEASE.tar.sign
			$ECHOC "done verifying kernel source integrity"

			$ECHOC "extracting kernel source w/ $TARC -xf linux-$RELEASE.tar" 
			$TARC -xf linux-$RELEASE.tar 
			$ECHOC "done fetching kernel source"

	else
		$ECHOC "extracting kernel source w/ $TARC -xf linux-$RELEASE.tar" 
		$TARC -xf linux-$RELEASE.tar 
		$ECHOC "done fetching kernel source"
	fi		
	
	cd linux-$RELEASE

	$ECHOC "0) $ZCAT /proc/config.gz > ./.config"
	$ECHOC "1) $CPC /home/.stuff/.config ./"

	read choice
	case $choice in
		0)
		$ZCATC /proc/config.gz > ./.config;;
		1)
		$CPC /home/.stuff/.config ./;;	
		*)
		$ECHOC "you must choose between option 0 and 1"
		exit
		;;
	esac

	$ECHOC "$MAKEC oldconfig"
	$MAKEC oldconfig
	
	$ECHOC "$MAKEC bzImage modules"
	$MAKEC bzImage modules
	
	$ECHOC "$MAKEC modules_install"
	$MAKEC modules_install

	$ECHOC "$CPC arch/x86/boot/bzImage /boot/vmlinuz-$RELEASE"
	$CPC arch/x86/boot/bzImage /boot/vmlinuz-$RELEASE
	
	$ECHOC "$CPC System.map /boot/System.map-$RELEASE"
	$CPC System.map /boot/System.map-$RELEASE
	
	$ECHOC "$CPC .config /boot/config-$RELEASE"
	$CPC .config /boot/config-$RELEASE
	
	$ECHOC "$MKINITRDC -c -k $RELEASE-smp -m ext4"
	$MKINITRDC -c -k $RELEASE-smp -f ext4 -r /dev/sda1 -m xhci-pci:ohci-pci:ehci-pci:xhci-hcd:uhci-hcd:ehci-hcd:hid:usbhid:i2c-hid:hid_generic:hid-cherry:hid-logitech:hid-logitech-dj:hid-logitech-hidpp:hid-lenovo:hid-microsoft:hid_multitouch:jbd2:mbcache:ext4 -u -o /boot/initrd.gz.$RELEASE

	$ECHOC "append the file lilo.conf"
	$ECHOC "image = /boot/vmlinuz-$RELEASE
		initrd=/boot/initrd.gz.$RELEASE
		root = /dev/sda1
		label = s$RELEASE
		read-only" >> /etc/lilo.conf
	
	$ECHOC "$LILOC -v"
	$LILOC -v

else

$ECHOC "--"
$ECHOC "usage is $0 <version_of_the_kernel_archive>"
$ECHOC "example: is $0 4.4.14"
$ECHOC "--"

fi

