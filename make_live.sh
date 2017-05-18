#http://willhaley.com/blog/create-a-custom-debian-live-environment/

sudo apt-get install \
    debootstrap syslinux isolinux squashfs-tools \
    genisoimage rsync



# Create a directory for the live environment.
mkdir $HOME/live_boot


sudo debootstrap \
    --arch=i386 \
    --variant=minbase \
    jessie $HOME/live_boot/chroot http://ftp.us.debian.org/debian/

sudo chroot $HOME/live_boot/chroot

echo "debian-live_1" > /etc/hostname

apt-get update && \
apt-get install --no-install-recommends --yes --force-yes \
    nvidia-kernel-3.16.0-4-amd64 live-boot \
    network-manager net-tools wireless-tools wpagui \
    tcpdump wget openssh-client \
    blackbox xserver-xorg-core xserver-xorg xinit xterm \
    pciutils usbutils gparted ntfs-3g hfsprogs rsync dosfstools \
    syslinux partclone nano pv \
    rtorrent iceweasel chntpw && \
apt-get clean




