echo "Setting system clock..."
modprobe i2c-dev
modprobe i2c-bcm2708
modprobe rtc-ds1307
echo ds1307 0x68 >/sys/class/i2c-adapter/i2c-1/new_device
timedatectl set-ntp true
sleep 2
hwclock -w
echo "Creating system clock script..."
echo "#"\!"/bin/bash" >/etc/chefeyeclock.sh
echo "echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device" >>/etc/chefeyeclock.sh
echo "hwclock -s" >>/etc/chefeyeclock.sh
echo "exit 0" >>/etc/chefeyeclock.sh
chmod 755 /etc/chefeyeclock.sh
echo "Creating system clock service..."
echo "[Unit]" >>/etc/systemd/system/chefeyeclock.service
echo "Description=Set hardware clock in Raspberry Pi" >>/etc/systemd/system/chefeyeclock.service
echo "Before=nodered.service" >>/etc/systemd/system/chefeyeclock.service
echo "" >>/etc/systemd/system/chefeyeclock.service
echo "[Service]" >>/etc/systemd/system/chefeyeclock.service
echo "Type=oneshot" >>/etc/systemd/system/chefeyeclock.service
echo "User=root" >>/etc/systemd/system/chefeyeclock.service
echo "ExecStart=/etc/chefeyeclock.sh" >>/etc/systemd/system/chefeyeclock.service
echo "" >>/etc/systemd/system/chefeyeclock.service
echo "[Install]" >>/etc/systemd/system/chefeyeclock.service
echo "WantedBy=multi-user.target" >>/etc/systemd/system/chefeyeclock.service
systemctl enable chefeyeclock.service
echo "Adding clock modules to boot..."
echo "i2c-dev" >>/etc/modules-load.d/chefeyeclock.conf
echo "i2c-bcm2708" >>/etc/modules-load.d/chefeyeclock.conf
echo "rtc-ds1307" >>/etc/modules-load.d/chefeyeclock.conf