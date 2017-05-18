mkdir -p $HOME/live_boot/image/{live,isolinux}

(cd $HOME/live_boot && \
    sudo mksquashfs chroot image/live/filesystem.squashfs -e boot
)

(cd $HOME/live_boot && \
    cp chroot/boot/vmlinuz-3.16.0-4-586 image/live/vmlinuz1
    cp chroot/boot/initrd.img-3.16.0-4-586 image/live/initrd1
)


cp isolinux.cfg $HOME/live_boot/image/isolinux/isolinux.cfg

(cd $HOME/live_boot/image/ && \
    cp /usr/lib/ISOLINUX/isolinux.bin isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/menu.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/hdt.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/ldlinux.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libutil.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libmenu.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libcom32.c32 isolinux/ && \
    cp /usr/lib/syslinux/modules/bios/libgpl.c32 isolinux/ && \
    cp /usr/share/misc/pci.ids isolinux/ && \
    cp /boot/memtest86+.bin live/memtest
)


genisoimage \
    -rational-rock \
    -volid "Debian Live" \
    -cache-inodes \
    -joliet \
    -hfs \
    -full-iso9660-filenames \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -output $HOME/live_boot/debian-live.iso \
    $HOME/live_boot/image



