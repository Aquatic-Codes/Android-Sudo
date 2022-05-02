#! /system/bin/sh

### Run as root
### Seroid Installation Script

not_android() {

echo "Not running a Android Platform."
echo "Failed to install"
echo "GNU/Linux users, use sudo"
exit 1

}

if [ -d /data/adb/Seroid ]; then
echo "Warning: Seroid files are already found, Note that old configuration files will be deleted."
echo "Update scripts will be made soon."
fi

if [ ! -f /system/bin/getprop ] || [ ! -f /system/bin/am ] || [ ! -f /system/bin/pm ] || [ ! -f /system/build.prop ] || [ "$(getprop >> /dev/null ; echo $?)" != 0 ] || [ -d /var ] || [ -d /usr ] || [ -d /boot ] || [ ! -d /system ]; then
not_android
fi

if [ "$(id -u)" != 0 ];
then
echo "Must run this script as root."
echo "command: su -c sh install.sh"
echo "Not running as root."
exit 1
fi

clear

LOGFILE=$PWD/install.log

rm -rf $LOGFILE 2> /dev/null
touch $LOGFILE
chmod 777 $LOGFILE
chown root:root $LOGFILE

echo "[ ! ] Storing device information.."
    
     echo "*Installation started*" >> $LOGFILE
    echo "*Gathering Device Information*" >> $LOGFILE
    echo "[ * ] Android Version: $(getprop ro.build.version.release)" >> $LOGFILE
    echo "[ * ] Secure Boot: $(getprop ro.boot.secureboot)" >> $LOGFILE
    echo "[ * ] Selinux Status: $(getprop ro.boot.selinux)" >> $LOGFILE
    echo "[ * ] Codename: $(getprop ro.product.name)" >> $LOGFILE
    echo "[ * ] Model: $(getprop ro.product.odm.model)" >> $LOGFILE
    echo "[ * ] Manufacturer: $(getprop ro.product.odm.manufacturer)" >> $LOGFILE
    echo "[ * ] Chipset: $(getprop ro.soc.manufacturer)" >> $LOGFILE
    echo "[ * ] Uname: $(uname -a)" >> $LOGFILE
    echo "[ * ] Superuser: $($(which su) -v)" >> $LOGFILE
    echo "*Gathered Device Information*" >> $LOGFILE

echo "Starting Installation.."

if [ "$(uname -m)" != "aarch64" ]; then
echo "Unsupported Device Arch $(uname -m) Supported only aarch64.\n*Quit Installation*" >> $LOGFILE
echo "Unsupported Device Arch"
echo "Try Building from source"
echo "Cancelling Installation"
exit 1
fi

echo "Checking binary.."

EXEC_FILE="./binaries/sudo.aarch64"

if [ ! -f $EXEC_FILE ]; then
echo "[ x ] Executeable Not Found" >> $LOGFILE
echo "Executeable not found."
exit 1
fi

echo "Done!\nInstalling.."

echo "Setting binary permissions" >> $LOGFILE
chmod 770 $EXEC_FILE 2>> $LOGFILE
chown root:root $EXEC_FILE 2>> $LOGFILE

echo "Permissions set" >> $LOGFILE

if [ -d /data/adb/Seroid ]; then
    if [ -f /data/adb/Seroid/Seroid.conf ]; then
    . /data/adb/Seroid/Seroid.conf
    rm -rf $DATA_DIR 2> /dev/null
    fi
    rm -rf /data/adb/Seroid
fi

mkdir /data/adb/Seroid/
chmod 774 /data/adb/Seroid/
mkdir /data/adb/Seroid/tmp/
chmod 770 /data/adb/Seroid/tmp/
chown root:root /data/adb/Seroid/tmp/

echo "Enter the directory to use for storing Information(/data/):"
read dir

if [ "$(echo $dir | cut -d / -f 2)" != "data" ]; then
    dir="/data/$dir"
fi

if [ -d $dir ]; then
echo "Directory already exists, Creating $dir/Seroid/"
mkdir $dir/Seroid/
echo "$dir/Seroid/" >> data.dir
echo "Created Directory" >> $LOGFILE
else
mkdir $dir
echo "$dir" >> data.dir
echo "Created Directory" >> $LOGFILE
fi

DATA_DIR=$(cat data.dir)
rm -rf data.dir
echo "Using $DATA_DIR"
echo "\nDATA_DIR=$DATA_DIR" >> $PWD/conf
mv ./conf /data/adb/Seroid/Seroid.conf 2> /dev/null
chmod 664 /data/adb/Seroid/Seroid.conf
chown root:root /data/adb/Seroid/Seroid.conf

mkdir $DATA_DIR/Access
mkdir $DATA_DIR/Apps

echo "Placing files" >> $LOGFILE

su -c find /data/data -name 'bin' >> tmp.bins

while read line
do
cp $EXEC_FILE $line/sudo 2>> $LOGFILE
if [ "$?" != 0 ]; then
echo "Installation Failed For $(line)" >> $LOGFILE
fi
chown $(ls -ld $line 2> /dev/null | cut -d " " -f 3):$(ls -ld $line 2> /dev/null | cut -d " " -f 3) $line/sudo
mkdir $DATA_DIR/Access/$(ls -ld $line 2> /dev/null | cut -d " " -f 3)/

### Application defaults

if [ ! -f $DATA_DIR/Access/$(ls -ld $line 2> /dev/null | cut -d " " -f 3)/passwd.str ]; then
    echo "global" >> $DATA_DIR/Access/$(ls -ld $line 2> /dev/null | cut -d " " -f 3)/passwd.str 2>> $LOGFILE
fi

if [ ! -f $DATA_DIR/Access/$(ls -ld $line 2> /dev/null | cut -d " " -f 3)/limits.conf ]; then
    echo "defaults" >> $DATA_DIR/Access/$(ls -ld $line 2> /dev/null | cut -d " " -f 3)/limits.conf 2>> $LOGFILE
fi

if [ ! -f $DATA_DIR/Apps/$(ls -ld $line 2> /dev/null | cut -d " " -f 3).sudo ]; then
    echo "request" >> $DATA_DIR/Apps/$(ls -ld $line 2> /dev/null | cut -d " " -f 3).sudo
fi

done < tmp.bins

rm -rf tmp.bins 2> /dev/null

echo "Installation Successfully Completed" >> $LOGFILE

echo "Installation Successfully"
echo "Doing Post install Tasks Before Closing"

mv $PWD/binaries/sudo.aarch64 /data/adb/Seroid/
chmod 770 /data/adb/Seroid/sudo.aarch64
chown root:root /data/adb/Seroid/sudo.aarch64
mv $PWD/install.sh /data/adb/Seroid/.install
chmod 000 /data/adb/Seroid/.install
chown root:root /data/adb/Seroid/.install
mv $PWD/update.sh /data/adb/Seroid/update.sh
chmod 775 /data/adb/Seroid/update.sh
chown root:root /data/adb/Seroid/update.sh
chmod 664 $LOGFILE

exit 0