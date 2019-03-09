echo -e "\033[36m  Creating Image\033[0m"
dd if=/dev/zero of=ubuntu.img bs=1M count=4096
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
sudo cp -b -r /system ubuntu-mount/
sudo cp -b -r ./lib/firmware ubuntu-mount/lib
sudo cp -b -r ./lib/modules ubuntu-mount/lib
sudo cp -b -r ./lib/modprobe.d ubuntu-mount/lib
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
#apt-get install rsyslog -y
#dpkg-reconfigure rsyslog
apt-get install -y language-pack-en-base sudo ssh net-tools ethtool wireless-tools ifupdown network-manager iputils-pingbash-completion htop synaptic alsa-utils rsyslog nano vim git udev build-essential blueman sshfs openssh-server
echo -e  "\033[36m  Installing Packages:video\033[0m"
apt-get install -y gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-plugins-good  gstreamer1.0-plugins-bad alsa-utils
echo -e  "\033[36m  Installing Packages:qt\033[0m"
apt-get install -y libqt5opengl5 libqt5qml5 libqt5quick5 libqt5widgets5 libqt5gui5 libqt5core5a qml-module-qtquick2 libqt5multimedia5 libqt5multimedia5-plugins libqt5multimediaquick-p5
echo -e  "\033[36m  Installing Packages:check\033[0m"
apt-get install -f -y
echo  -e "\033[36m  Installing Packages:clean\033[0m"
rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/*
chmod -R +x /bin/* /sbin/* /lib/* /usr/share/* /usr/local/share/* /usr/bin/* /usr/sbin/* /usr/lib/* /usr/local/bin/* /usr/local/lib/* /usr/local/sbin/*
chmod -R -x /lib/systemd/system
echo  -e "\033[36m  Setting users\033[0m"
useradd -s '/bin/bash' -m -G adm,sudo star
passwd star
$1
$1
passwd root
$1
$1
echo  -e "\033[36m  Done\033[0m"
exit
EOF
echo  -e "\033[36m  Umounting\033[0m"
sudo bash ch-mount.sh -u ubuntu-mount/
rm -rf ubuntu-mount/dev/* ubuntu-mount/proc/* ubuntu-mount/sys/* ubuntu-mount/dev/pts/*
echo  -e "\033[36m  Packing\033[0m"
./make_ext4fs -s -l4096M -a root -L rootfs rootfs.img ubuntu-mount
echo  -e "\033[36m  Package has save to rootfs.img\033[0m"
sudo umount ubuntu.img



