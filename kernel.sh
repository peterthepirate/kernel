#!/bin/sh

ZCATC=/usr/bin/zcat
MAKEC=/usr/bin/make
MKINITRDC=/sbin/mkinitrd
TARC=/usr/bin/tar
WGETC=/usr/bin/wget
LNC=/usr/bin/ln
CPC=/usr/bin/cp
AWKC=/usr/bin/awk
ECHOC=/usr/bin/echo
LILOC=/sbin/lilo
GPGC=/usr/bin/gpg


if [ ! -z "$1" ]; then

	RELEASE=$1
	FETCH=ftp://ftp.kernel.org/pub/linux/kernel/v3.x/linux-$RELEASE.tar.xz
	FETCHS=ftp://ftp.kernel.org/pub/linux/kernel/v3.x/linux-$RELEASE.tar.sign

	$ECHOC "fetching kernel checksum w/ $WGETC -nv $FETCHS"
	$WGETC -nv $FETCHS
	$ECHOC "done fetching kernel checksum"
	
	$ECHOC "fetching kernel source w/ $WGETC -nv $FETCH"
	$WGETC -nv $FETCH
	$ECHOC "done fetching kernel source"
	
	$ECHOC "verifying kernel source integrity w/ $GPGC --verify linux-$RELEASE.tar.sign"
	$GPGC --verify linux-$RELEASE.tar.sign
	$ECHOC "done verifying kernel source integrity"
	
	$ECHOC "extracting kernel source w/ $TARC -Jxf linux-$RELEASE.tar.xz" 
	$TARC -Jxf linux-$RELEASE.tar.xz 
	$ECHOC "done fetching kernel source"
	
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
		$ECHOC "you must choose between option 0 and 1";;
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
	$MKINITRDC -c -k $RELEASE-smp -m ext4 -o /boot/initrd.gz.$RELEASE

	$ECHOC "append the file lilo.conf"
	$ECHOC "image = /boot/vmlinuz-$RELEASE
		initrd=/boot/initrd.gz.$RELEASE
		root = /dev/sda1
		label = s$RELEASE
		read-only" >> /etc/lilo.conf
	
	$ECHOC "$LILOC -v"
	$LILOC -v

else

echo "--"
echo "usage is $0 <version_of_the_kernel_archive>"
echo "example: is $0 3.1.1"
echo "--"

fi

