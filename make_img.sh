echo -e "\033[36m  Creating Image\033[0m"
dd if=/dev/zero of=ubuntu.img bs=1M count=3072
sudo mkfs.ext4 ubuntu.img
echo -e "\033[36m  Mounting Image\033[0m"
mkdir ubuntu-mount
sudo mount ubuntu.img ubuntu-mount
echo -e  "\033[36m  Getting ubuntu rootfs base\033[0m"
wget -c -q https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cdimage/ubuntu-base/releases/18.04.2/release/ubuntu-base-18.04.2-base-arm64.tar.gz -O base.tar.gz
cd ubuntu-mount
sudo tar -xpf ../base.tar.gz
cd ..
echo  -e "\033[36m  Setting up drivers\033[0m"
sudo cp -b /etc/resolv.conf ubuntu-mount/etc/resolv.conf
sudo rm ubuntu-mount/etc/apt/sources.list
sudo cp ./sources.list ubuntu-mount/etc/apt/sources.list
sudo cp -b -r ./system ubuntu-mount/
sudo cp -b -r ./lib ubuntu-mount/
echo -e  "\033[36m  Changing Root\033[0m"
cat <<EOF | sudo bash ch-mount.sh -m ubuntu-mount/
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
y
y
y
echo -e  "\033[36m  Installing Packages:base\033[0m"
apt-get install -y language-pack-en-base ntp sudo ssh net-tools ethtool wireless-tools ifupdown network-manager iputils-pingbash-completion htop synaptic alsa-utils rsyslog nano vim git udev build-essential blueman sshfs openssh-server
echo -e  "\033[36m  Installing Packages:video\033[0m"
apt-get install -y gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-plugins-good  gstreamer1.0-plugins-bad alsa-utils
echo -e  "\033[36m  Installing Packages:check\033[0m"
apt-get install -f -y
echo  -e "\033[36m  Installing Packages:clean\033[0m"
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/*
chmod -R +x /bin/* /sbin/* /lib/* /usr/share/* /usr/local/share/* /usr/bin/* /usr/sbin/* /usr/lib/* /usr/local/bin/* /usr/local/lib/* /usr/local/sbin/*
chmod -R -x /lib/systemd/system
chmod 4755 'which sudo' 'which passwd' 'which su' 'which chsh' 'which gpasswd' 'which mount' 'which umount' 'which chfn' 'which newgrp'
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
sudo bash ch-mount.sh -u ubuntu-mount/
sudo rm -rf ubuntu-mount/dev/* ubuntu-mount/proc/* ubuntu-mount/sys/* ubuntu-mount/dev/pts/*
echo  -e "\033[36m  Packing\033[0m"
sudo ./make_ext4fs -s -l3072M -a root -L rootfs rootfs.img ubuntu-mount
echo  -e "\033[36m  Package has save to rootfs.img\033[0m"
sudo umount ubuntu.img



