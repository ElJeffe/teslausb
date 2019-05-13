#!/bin/bash


# This script will modify the cmdline.txt file on a freshly flashed Raspbian Stretch/Lite
# It readies it for SSH, USB OTG, USB networking, and Wifi
#
# Pass it the path to the location at which the "boot" filesystem is mounted.
# E.g. on a Mac:
#   ./setup-piForHeadlessConfig.sh /Volumes/boot
# or on Ubuntu:
#   ./setup-piForHeadlessConfig.sh /media/$USER/boot
# cd /Volumes/boot (or wherever the boot folder is mounted)
# chmod +x setup-piForHeadlessConfig.sh
# ./setup-piForHeadlessConfig.sh
#
# Put the card in your Pi, and reboot!

# Creates the ssh file if needed, since Raspbian now disables 
# ssh by default if the file isn't present

BOOT_DIR="$(pwd)"

function verify_file_exists () {
  local file_name="$1"
  local expected_path="$2"
  
  if [ ! -e "$expected_path/$file_name" ]
    then
      echo "STOP: Didn't find $file_name at $expected_path."
      exit 1
  fi  
}

verify_file_exists "cmdline.txt" "$BOOT_DIR"
verify_file_exists "config.txt" "$BOOT_DIR"


CMDLINE_TXT_PATH="$BOOT_DIR/cmdline.txt"
CONFIG_TXT_PATH="$BOOT_DIR/config.txt"

if ! grep -q "dtoverlay=dwc2" $CONFIG_TXT_PATH
then
   echo "Updating $CONFIG_TXT_PATH ..."
   echo "" >> "$CONFIG_TXT_PATH"
   echo "dtoverlay=dwc2" >> "$CONFIG_TXT_PATH"
else
   echo "$CONFIG_TXT_PATH already contains the required dwc2 module"
fi

if ! grep -q "dwc2,g_ether" $CMDLINE_TXT_PATH
then
  echo "Updating $CMDLINE_TXT_PATH ..."
  sed -i'.bak' -e "s/rootwait/rootwait modules-load=dwc2,g_ether/" -e "s@ init=/usr/lib/raspi-config/init_resize.sh@@" "$CMDLINE_TXT_PATH"
else
  echo "$CMDLINE_TXT_PATH already updated with modules and removed initial resize script."
fi

echo "Enabling SSH ..."
touch "$BOOT_DIR/ssh"


echo ""
echo '-- Files updated and ready for SSH over USB --'
echo ""