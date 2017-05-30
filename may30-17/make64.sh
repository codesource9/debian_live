#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi


apt-get install -y  debootstrap syslinux isolinux squashfs-tools genisoimage rsync makepasswd
mkdir $HOME/live_boot
debootstrap  --arch=amd64  --variant=minbase  jessie $HOME/live_boot/chroot http://ftp.us.debian.org/debian/


#auto login
cp configs/getty@.service  $HOME/live_boot/chroot/lib/systemd/system/getty@.service

#fzf addition
echo "fzf='/opt/fzf'" >> $HOME/live_boot/chroot/etc/profile
echo 'if [  -d "$fzf" ]; then' >> $HOME/live_boot/chroot/etc/profile
echo "echo 'fzf ready'" >> $HOME/live_boot/chroot/etc/profile
echo "else" >> $HOME/live_boot/chroot/etc/profile
echo "cd /opt;git clone https://github.com/junegunn/fzf.git" >> $HOME/live_boot/chroot/etc/profile
echo "fi" >> $HOME/live_boot/chroot/etc/profile
#eof fzf addition


#auto startx
echo "[ -z \$DISPLAY  ] && exec startx" >> $HOME/live_boot/chroot/etc/profile


#installing linux image and install.list
chroot $HOME/live_boot/chroot  /bin/bash -c "echo debian-live-amd64 > /etc/hostname; echo 'nameserver 8.8.8.8' > /etc/resolv.conf \
apt-get update; apt-get install  --yes --force-yes linux-image-3.16.0-4-amd64"

#setting user password using chpasswd
read PASSWORD < configs/pass
chroot $HOME/live_boot/chroot  /bin/bash -c "echo root:$PASSWORD | /usr/sbin/chpasswd"

#reading install.list
filename="install.list"
while read -r line
do
    #messages to confirm
    echo "\n=========================================\n"
    echo "apt-get install  --yes --force-yes $line"
    echo "\n=========================================\n"
    sleep 3
    chroot $HOME/live_boot/chroot  /bin/bash -c "apt-get install  --yes --force-yes $line"
done < "$filename"

#final cleanup
chroot $HOME/live_boot/chroot  /bin/bash -c "apt-get clean"


#reading pip.list
filename="pip.list"
while read -r line
do
    chroot $HOME/live_boot/chroot  /bin/bash -c "pip install $line"
done < "$filename"


mkdir -p $HOME/live_boot/image/{live,isolinux}

(cd $HOME/live_boot && mksquashfs chroot image/live/filesystem.squashfs -e boot)

(cd $HOME/live_boot && cp chroot/boot/vmlinuz-3.16.0-4-amd64 image/live/vmlinuz1 && cp chroot/boot/initrd.img-3.16.0-4-amd64 image/live/initrd1)


cat > $HOME/live_boot/image/isolinux/isolinux.cfg <<- EOM
UI menu.c32
prompt 0
menu title Debian Live
timeout 10
label Debian Live x86_64
menu label ^Debian Live _64
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



genisoimage -rational-rock  -volid "Debian Live 64bit"  -cache-inodes -joliet  -hfs  -full-iso9660-filenames -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4  -boot-info-table  -output $HOME/live_boot/debian-live-amd64.iso  $HOME/live_boot/image
