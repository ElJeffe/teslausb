#!/bin/bash

# scp sahess05@192.168.18.180:tools/TeslaCam/scripts/setup.sh .

function entry()
{
  if ! [ $(id -u) = 0 ]
    then
      echo "STOP: Run sudo -i."
      exit 1
  fi

  upgrade=1

  while test $# -gt 0
  do
    case ${1} in
      noupgrade)
        upgrade=0
        ;;
    esac
    shift
  done  

  if [ $upgrade == 1 ] 
  then
    echo "Upgrading packages"
    apt-get update
    apt-get --assume-yes upgrade
    apt-get install -y btrfs-tools vim dnsmasq hostapd
  fi

  echo "enable ssh"
  sudo systemctl enable ssh

  setup_ap

}

function setup_ap()
{
  echo "configure static IP" 
  if ! grep -q "^interface wlan0" /etc/dhcpcd.conf
  then
    echo "Update /etc/dhcpcd.conf"
    cat <<EOT >> /etc/dhcpcd.conf
interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant
EOT
    systemctl restart dhcpcd
  fi

  echo "Configure DHCP server"
  if ! grep -q "^interface=wlan0" /etc/dnsmasq.conf
  then
    echo "Update /etc/dnsmasq.conf"
    mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
    cat <<EOT >> /etc/dnsmasq.conf
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
EOT
    sudo systemctl reload dnsmasq
  fi

  echo "Configure hostapd"
  if ! grep -q "^interface=wlan0" /etc/hostapd/hostapd.conf
  then
    echo "Update /etc/hostapd/hostapd.conf"
    cat <<EOT >> /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=Cam
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=ElonMusk
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOT
  fi
  echo "Update /etc/default/hostapd"
  sed -i 's/^#DAEMON_CONF.*$/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd
  systemctl unmask hostapd
  systemctl enable hostapd
  systemctl start hostapd
  reboot
}

entry $@
