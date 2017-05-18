#http://willhaley.com/blog/create-a-custom-debian-live-environment/
rm -rf $HOME/live_boot

apt-get install \
   debootstrap syslinux isolinux squashfs-tools \
    genisoimage rsync



# Create a directory for the live environment.
mkdir $HOME/live_boot


debootstrap \
    --arch=i386 \
    --variant=minbase \
    jessie $HOME/live_boot/chroot http://ftp.us.debian.org/debian/

chroot $HOME/live_boot/chroot

echo "debian-live_4" > /etc/hostname

apt-get update && \
apt-get install --no-install-recommends --yes --force-yes \
    linux-image-3.16.0-4-586 live-boot \
    network-manager net-tools wireless-tools wpagui \
    w3m wget openssh-client openssh-server \
    blackbox xserver-xorg-core xserver-xorg xinit xterm xfce4-terminal \
    pciutils usbutils gparted hfsprogs rsync \
    syslinux partclone pv \
    firefox-esr man bpython git iptables locate nfs-common vim hdparm && \
apt-get clean




