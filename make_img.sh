echo -e "\033[36m  Creating Image\033[0m"
#dd if=/dev/zero of=ubuntu.img bs=1M count=3072
#sudo mkfs.ext4 ubuntu.img
echo -e "\033[36m  Mounting Image\033[0m"
sudo mkdir ubuntu-mount
#sudo mount ubuntu.img ubuntu-mount
echo -e  "\033[36m  Getting ubuntu rootfs base\033[0m"
sudo wget -c https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cdimage/ubuntu-base/releases/18.04.2/release/ubuntu-base-18.04.2-base-arm64.tar.gz -O base.tar.gz
cd ubuntu-mount
sudo tar -xpf ../base.tar.gz
cd ..
echo  -e "\033[36m  Setting up drivers\033[0m"
sudo cp -b /etc/resolv.conf ubuntu-mount/etc/resolv.conf
sudo rm ubuntu-mount/etc/apt/sources.list
sudo cp ./drivers/sources.list ubuntu-mount/etc/apt/sources.list
sudo cp -b -r ./drivers/system ubuntu-mount/
sudo cp -b -r ./drivers/lib ubuntu-mount/
echo -e  "\033[36m  Changing Root\033[0m"
cat <<EOF | sudo bash ./tools/ch-mount.sh -m ubuntu-mount/
echo -e  "\033[36m  Setting hostname\033[0m"
echo "starpi">/etc/hostname
echo "127.0.0.1 localhost">>/etc/hosts
echo "127.0.1.1 starpi">>/etc/hosts
echo -e  "\033[36m  Installing Packages:update\033[0m"
apt-get update
echo -e  "\033[36m  Installing Packages:unminisize\033[0m"
unminimize
y
y
y
y
y
y
y
y
EOF
cat <<EOF | sudo chroot ubuntu-mount/
echo -e  "\033[36m  Installing Packages:base\033[0m"
apt-get install -y  language-pack-en-base screen ntp sudo ssh net-tools ethtool pkg-config wireless-tools ifupdown network-manager iputils-ping bash-completion htop synaptic alsa-utils nano vim git udev build-essential sshfs openssh-server telnetd bluez telnet nmon curl language-pack-zh-hans
echo -e  "\033[36m  Installing Packages:video\033[0m"
apt-get install -y gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-plugins-good  gstreamer1.0-plugins-bad alsa-utils
echo -e  "\033[36m  Installing Packages:check\033[0m"
apt-get install -f -y
echo  -e "\033[36m  Installing Packages:clean\033[0m"
rm -rf /var/lib/apt/lists/* /var/cache/man/*
echo  -e "\033[36m  Setting users\033[0m"
useradd -s '/bin/bash' -m -G adm,sudo $1
passwd $1
$2
$2
passwd root
$2
$2
echo  -e "\033[36m  Done\033[0m"
exit
EOF
echo  -e "\033[36m  Umounting\033[0m"
sudo bash ./tools/ch-mount.sh -u ubuntu-mount/
sudo rm -Rf ubuntu-mount/dev/* ubuntu-mount/run/*
echo  -e "\033[36m  Packing\033[0m"
sudo ./tools/make_ext4fs -s -l3072M rootfs.img ubuntu-mount
echo  -e "\033[36m  Package has save to rootfs.img\033[0m"
#sudo umount ubuntu.img



