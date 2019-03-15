#!/bin/bash


# Automatically re-run script under  if not root
if [ $(id -u) -ne 0 ]; then
	echo "Re-running script under ..."
	sudo "$0" "$@"
	exit
fi
# Preparing Varribles
SaveToIMG="false"
POSITIONAL=()
USER=
PASSWD=
URL="https://mirrors.tuna.tsinghua.edu.cn/ubuntu-cdimage/ubuntu-base/releases/18.04.2/release/ubuntu-base-18.04.2-base-arm64.tar.gz"
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -u|--user)
    USER="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--password)
    PASSWD="$2"
    shift # past argument
    shift # past value
    ;;
    -b|--base)
    URL="$2"
    shift # past argument
    shift # past value
    ;;
    --save-to-img)
    SaveToIMG="true"
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

if [ ${USER}n == ""n ]
then
read -p "Input username:" USER
fi

if [ ${PASSWD}n == ""n ]
then
read -p "Input password:" PASSWD
fi
echo -e "\033[31m Username: $USER\n Password: $PASSWD\033[0m"
if [ $SaveToIMG == "true" ]
then
echo -e "\033[36m  Creating Image\033[0m"
dd if=/dev/zero of=ubuntu.img bs=1M count=3072
mkfs.ext4 ubuntu.img
echo -e "\033[36m  Mounting Image\033[0m"
fi
 rm -rf ubuntu-mount
 mkdir ubuntu-mount
if [ $SaveToIMG == "true" ]
then
mount ubuntu.img ubuntu-mount
fi
echo -e  "\033[36m  Getting ubuntu rootfs base\033[0m"
wget -c $URL -O base.tar.gz
cd ubuntu-mount
tar -xpf ../base.tar.gz
cd ..
echo  -e "\033[36m  Setting up drivers\033[0m"
cp -b /etc/resolv.conf ubuntu-mount/etc/resolv.conf
rm ubuntu-mount/etc/apt/sources.list
cp ./drivers/sources.list ubuntu-mount/etc/apt/sources.list
cp -b -r ./drivers/system ubuntu-mount/
cp -b -r ./drivers/lib ubuntu-mount/
echo -e  "\033[36m  Changing Root\033[0m"
cat <<EOF |  bash ./tools/ch-mount.sh -m ubuntu-mount/
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
cat <<EOF |  chroot ubuntu-mount/
echo -e  "\033[36m  Installing Packages:base\033[0m"
apt-get install -y  language-pack-en-base screen ntp  ssh net-tools ethtool pkg-config wireless-tools ifupdown network-manager iputils-ping bash-completion htop synaptic alsa-utils nano vim git udev build-essential sshfs openssh-server telnetd bluez telnet nmon curl language-pack-zh-hans
echo -e  "\033[36m  Installing Packages:video\033[0m"
apt-get install -y gstreamer1.0-plugins-base gstreamer1.0-tools gstreamer1.0-alsa gstreamer1.0-plugins-good  gstreamer1.0-plugins-bad alsa-utils
echo -e  "\033[36m  Installing Packages:check\033[0m"
apt-get install -f -y
echo  -e "\033[36m  Installing Packages:clean\033[0m"
rm -rf /var/lib/apt/lists/* /var/cache/man/*
echo  -e "\033[36m  Setting users\033[0m"
useradd -s '/bin/bash' -m -G adm, $USER
passwd $USER
$PASSWD
$PASSWD
passwd root
$PASSWD
$PASSWD
echo  -e "\033[36m  Done\033[0m"
exit
EOF
echo  -e "\033[36m  Umounting\033[0m"
bash ./tools/ch-mount.sh -u ubuntu-mount/
rm -Rf ubuntu-mount/dev/* ubuntu-mount/run/*
echo  -e "\033[36m  Packing\033[0m"
./tools/make_ext4fs -s -l3072M rootfs.img ubuntu-mount
echo  -e "\033[36m  Package has save to rootfs.img\033[0m"
if [ $SaveToIMG == "true" ]
then
umount ubuntu.img
fi



