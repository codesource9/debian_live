#!/bin/bash


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


BANNER="=====debian x86 live cd iso generator========"
echo $BANNER


apt-get install -y  debootstrap syslinux isolinux squashfs-tools genisoimage rsync
    
    
mkdir $HOME/live_boot

debootstrap  --arch=i386  --variant=minbase  jessie $HOME/live_boot/chroot http://ftp.us.debian.org/debian/

pass="\$6\$//wwIzNt\$wn5fxfhq4RpxLOqUd/z8d54EnH9ZVTkaZzgyhBcgDMwFo35Jvy0Lz8F.tubMaM1996LgsEXbcqWbVAwfvYdIJ1"
sed -i -e  "s,^root:[^:]\+:,root:$pass:," $HOME/live_boot/chroot/etc/shadow

#fzf addition
echo  "cd /root;git clone https://github.com/junegunn/fzf.git" > $HOME/live_boot/chroot/etc/rc.local



chroot $HOME/live_boot/chroot  /bin/bash -c "uname -a; \
sleep 3; \
echo debian-live-x86 > /etc/hostname; \
apt-get update; \
apt-get install  --yes --force-yes live-boot  network-manager net-tools wireless-tools wpagui tcpdump wget openssh-client blackbox xserver-xorg-core xserver-xorg xinit xterm pciutils usbutils gparted syslinux partclone nano pv rtorrent iceweasel chntpw ntfs-3g hfsprogs rsync dosfstools git; apt-get install  --yes --force-yes linux-image-3.16.0-4-586; apt-get clean"

clear

mkdir -p $HOME/live_boot/image/{live,isolinux}

(cd $HOME/live_boot && mksquashfs chroot image/live/filesystem.squashfs -e boot)

(cd $HOME/live_boot &&  cp chroot/boot/vmlinuz-3.16.0-4-586 image/live/vmlinuz1 && cp chroot/boot/initrd.img-3.16.0-4-586 image/live/initrd1)


cat > $HOME/live_boot/image/isolinux/isolinux.cfg <<- EOM
UI menu.c32
prompt 0
menu title Debian Live
timeout 10
label Debian Live x86
menu label ^Debian Live x86
menu default
kernel /live/vmlinuz1
append initrd=/live/initrd1 boot=live
EOM


cd $HOME/live_boot/image/ && \
    cp /usr/lib/ISOLINUX/isolinux.bin isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/menu.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/hdt.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/ldlinux.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libutil.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libmenu.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libcom32.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libgpl.c32 isolinux/ && \
    cp /usr/share/misc/pci.ids isolinux




genisoimage  -rational-rock  -volid "Debian Live"  -cache-inodes -joliet  -hfs  -full-iso9660-filenames  -b isolinux/isolinux.bin  -c isolinux/boot.cat  -no-emul-boot  -boot-load-size 4  -boot-info-table   -output $HOME/live_boot/debian-live-x86.iso  $HOME/live_boot/image
