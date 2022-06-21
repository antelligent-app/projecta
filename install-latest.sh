#! /bin/sh

sudo raspi-config nonint do_rgpio 1
sudo raspi-config nonint do_camera 1
sudo raspi-config nonint do_serial 1
sudo raspi-config nonint do_i2c 1
sudo raspi-config nonint do_onewire 1
sudo raspi-config nonint do_spi 1

sudo apt update
sudo apt-get install jq -y
sudo apt install network-manager -y
sudo apt install network-manager-gnome -y
sudo apt install git -y

sudo mkdir -p /home/chefberrypi/
sudo chown -fR pi:pi /home/chefberrypi/
cd /home/chefberrypi/
git clone --depth=1 https://github.com/antelligent-app/hx711.git
cd hx711
sudo ./install-deps.sh
make && sudo make install

cd /tmp
wget https://raw.githubusercontent.com/rohitnarayan-me/rpichef-releases/main/versions.json
RELEASE_PATH=$(cat versions.json | jq -r ".latest.releasePath")
wget $RELEASE_PATH -O chef-eye.deb
sudo dpkg -i chef-eye.deb



