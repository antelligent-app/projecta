#!/bin/bash

sudo raspi-config nonint do_rgpio 1
sudo raspi-config nonint do_camera 0
sudo raspi-config nonint do_serial 1
sudo raspi-config nonint do_i2c 1
sudo raspi-config nonint do_onewire 1
sudo raspi-config nonint do_spi 1
sudo raspi-config nonint do_vnc 1
sudo raspi-config nonint do_ssh 1
sudo raspi-config nonint do_blanking 0
sudo raspi-config nonint do_vnc 0

sudo apt update
sudo apt install fping -y
sudo apt install jq -y
sudo apt install jpegoptim -y
sudo apt install git -y
sudo apt install network-manager -y
sudo apt install wmctrl -y
sudo apt install gnome-system-tools -y
sudo apt install i2c-tools -y
sudo apt install firefox-esr -y

while [ "$(fping google.com | grep alive)" == "" ]
do
    echo "Waiting for internet connection..."
    sleep 10
done
echo "Internet connection available now, proceeding with next package"

sudo apt install network-manager-gnome -y

while [ "$(fping google.com | grep alive)" == "" ]
do
    echo "Waiting for internet connection..."
    sleep 10
done
echo "Internet connection available now, proceeding..."

if grep -q "denyinterfaces wlan0" "/etc/dhcpcd.conf"; then
    echo "denyinterfaces wlan0 already present in /etc/dhcpcd.conf"
    else
    echo "denyinterfaces wlan0 not present in /etc/dhcpcd.conf. Adding it..."
    echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf
fi

echo "" > /etc/NetworkManager/NetworkManager.conf 
echo "[main]" >> /etc/NetworkManager/NetworkManager.conf 
echo "plugins=ifupdown,keyfile" >> /etc/NetworkManager/NetworkManager.conf
echo "dhcp=internal" >> /etc/NetworkManager/NetworkManager.conf
echo "" >> /etc/NetworkManager/NetworkManager.conf
echo "[ifupdown]" >> /etc/NetworkManager/NetworkManager.conf
echo "managed=true" >> /etc/NetworkManager/NetworkManager.conf

sudo mkdir -p /home/chefberrypi/
sudo chown -fR pi:pi /home/chefberrypi/
cd /home/chefberrypi/
wget https://raw.githubusercontent.com/antelligent-app/projecta/main/shutdown-board.py -O shutdown-board.py
git clone --depth=1 https://github.com/antelligent-app/hx711.git
cd hx711
sudo ./install-deps.sh
make && sudo make install
sudo chown -fR pi:pi /home/chefberrypi/

cd /tmp
wget https://raw.githubusercontent.com/antelligent-app/projecta/main/versions.json
RELEASE_PATH=$(cat versions.json | jq -r ".latest.releasePath")
if [ $1 ] && [ $1 = "--beta" ]; then
    echo "Using beta version"
    RELEASE_PATH=$(cat versions.json | jq -r ".beta.releasePath")
fi
wget $RELEASE_PATH -O chef-eye.deb
sudo dpkg -i chef-eye.deb

wget http://raspbian.raspberrypi.org/raspbian/pool/main/f/florence/libflorence-1.0-1_0.6.3-1.2_armhf.deb -O lib-florence.deb
sudo dpkg -i lib-florence.deb

wget http://raspbian.raspberrypi.org/raspbian/pool/main/f/florence/florence_0.6.3-1.2_armhf.deb -O florence.deb
sudo dpkg -i florence.deb

wget https://download.teamviewer.com/download/linux/teamviewer-host_armhf.deb -O teamviewer.deb
sudo dpkg -i teamviewer.deb

sudo apt install -f -y

sudo systemctl enable teamviewerd.service
sudo systemctl start teamviewerd.service
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager


gpginited="/home/chefberrypi/.gpginited"

if [ -f "$gpginited" ] ; then
    rm "$gpginited"
fi


echo " init=/usr/lib/raspi-config/init_resize.sh" >> /boot/cmdline.txt
tr -d '\n' < /boot/cmdline.txt > /boot/cmdline_bkp.txt
mv /boot/cmdline_bkp.txt /boot/cmdline.txt
sudo wget -O /etc/init.d/resize2fs_once https://raw.githubusercontent.com/antelligent-app/projecta/main/resize2fs_once
sudo chmod +x /etc/init.d/resize2fs_once
sudo systemctl enable resize2fs_once


echo "i2c-bcm2708" >> /etc/modules
echo "i2c-dev" >> /etc/modules
cd ~
wget https://raw.githubusercontent.com/antelligent-app/projecta/main/setup_hwclock.sh
chmod a+x setup_hwclock.sh

echo "Restarting in 15 seconds..."
echo "After system restart is complete, please run ~/setup_hwclock.sh to setup HWClock."
echo "Press ctrl+c to abort rebooting."

sleep 15
sudo reboot