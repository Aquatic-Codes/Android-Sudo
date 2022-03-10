if [ "$(id -u)" != 0 ]; then
echo "Run the install script as root."
echo "su -c installSudo.sh"
echo "If using recovery, Android 12 Users run recovery-script-12.sh\nAndroid 11 and below users recovery-script.sh"
exit 1
fi

if [ -e "$PWD/install.log" ]; then
rm $PWD/install.log
touch $PWD/install.log
else
touch $PWD/install.log
fi

LOGFILE="$PWD/install.log"

chmod 666 $PWD/install.log

deviceInfo() {
    
    echo "[ - ] Gathering Device Information.." >> $LOGFILE
    echo "[ * ] Device Name: $(getprop ro.product.device)" >> $LOGFILE
    echo "[ * ] Android Version: $(getprop ro.build.version.release)" >> $LOGFILE
    echo "[ * ] Model: $(getprop ro.product.model)" >> $LOGFILE
    echo "[ * ] Manufacturer: $(getprop ro.product.manufacturer)" >> $LOGFILE
    echo "[ * ] Chipset: $(getprop ro.soc.manufacturer)" >> $LOGFILE
    echo "[ * ] Device Data: $(/system/bin/uname -a)" >> $LOGFILE
    echo "[ * ] Device's Current Path: $PATH" >> $LOGFILE
    echo "[ * ] Power Adapters: $(/system/bin/acpi -a)\n" >> $LOGFILE
    echo "[ - ] Device Information Gathered" >> $LOGFILE
    
}

installSudoX() {
    
    echo "\n\n\n\n[ ! ] Scanning Apps Data." >> $LOGFILE
    echo "[ - ] Ignoring Specific Bins.." >> $LOGFILE
    
    echo "Scanning bins.."
    
    su -c find /data/data/ -name \"bin\" | grep -v 'gmail' | grep -v 'apache' | grep -v 'java' | grep -v 'kotlin' | grep -v 'npm' | grep -v 'clang' | grep -v 'node_modules' | grep -v 'openjdk' >> bins.tmp.dat
    
    echo "[ - ] Scanned bins successfully" >> $LOGFILE
    
    echo "Installing sudo to apps.."
    
    echo "[ ! ] Installing sudo to apps.." >> $LOGFILE
    
while read line
do 
cp $PWD/sudo $line 2> /dev/null
echo "[ ! ] Installed sudo to $line" >> $LOGFILE
chmod 777 $line/sudo 2> /dev/null
echo "[ ! ] Set 777 permissions to $line/sudo" >> $LOGFILE
chown $(ls -ld $line 2> /dev/null | cut -d " " -f 3):$(ls -ld $line 2> /dev/null | cut -d " " -f 3) $line/sudo 2> /dev/null
echo "[ ! ] Changed sudo owner to the specific app" >> $LOGFILE
done < $PWD/bins.tmp.dat

rm -rf $PWD/bins.tmp.dat 2> /dev/null

echo "[ ! ] Installed sudo (apps)" >> $LOGFILE
echo "Installed sudo to apps successfully"

}

deviceInfo
clear
echo "Welcome and thanks for using our sudo binary."
echo "This binary is still under development."

echo "Checking architecture.."
if [ "$(uname -m)" != "aarch64" ];then
echo "[ ! ] Architecture Unsupported!">>$LOGFILE
echo "[ ! ] Architecture detected $(uname -m), Supported Architecture is only aarch64" >> $LOGFILE
echo "Unsupported Arch, Try to build/compile the source in your device.\nRaise a github issue for assistance!"
exit 1
fi

echo "Making settings folder.."
echo "[ ! ] Checking if some folder already exits" >> $LOGFILE

if [ -d /data/data/csral.sudo/ ]; then

echo "Data folder already found, Updating Sudo-Only.." 
echo "[ ! ] Data Folder Found, Installing Sudo (Updating)" >> $LOGFILE

else
if [ "$(cat /etc/mkshrc | grep 'csral.sudo.dir')" != "" ]; then

echo "Data folder already found, Updating Sudo-Only.."
echo "[ ! ] Data Folder Found, Installing Sudo (Updating)" >> $LOGFILE

else

mkdir /data/data/csral.sudo/ 2>> $LOGFILE
if [ $? != 0 ];
then
echo "Error Creating Data Folder"
echo "[ ! ] Creating Directory /data/data/csral.sudo (Failed)" >> $LOGFILE
exit 1
fi

echo "[ ! ] Created directory /data/data/csral.sudo" >> $LOGFILE

chcon "u:object_r:app_data_file:s0" /data/data/csral.sudo 2>> $LOGFILE
if [ $? != 0 ]; then
echo "Writing SeLinux context failed."
echo "[ ! ] Writing SeLinux To /data/data/csral.sudo (failed)" >> $LOGFILE
exit 1
fi

echo "[ ! ] Modified SeLinux Context Of /data/data/csral.sudo (Allowed all users to rwx)" >> $LOGFILE

chmod 777 /data/data/csral.sudo 2>> $LOGFILE
if [ $? != 0 ]; then
echo "Setting permission to data folder failed."
echo "[ ! ] Failed to set permission 777 to /data/data/csral.sudo" >> $LOGFILE
exit 1
fi

echo "[ ! ] Set 777 permissions to /data/data/csral.sudo" >> $LOGFILE
fi
fi

echo "Installing Sudo.."
echo "Mounting Partitions.."
mount -o remount,rw / 2>> $LOGFILE
if [ $? != 0 ];then
echo "Mounting Failed!"
exit 1
fi
echo "[ ! ] Mounted rootfs Read-Write" >> $LOGFILE
mount -o remount,rw /system 2>> $LOGFILE
echo "[ ! ] Mounted System Read-Write ( Will be mounted by root-fs, don't mind above entry if its a error)" >> $LOGFILE
echo "Copying Binary.."

if [ ! -f $PWD/sudo ]; then
echo "[ ! ] Sudo Binary Not Found Expected at $PWD/sudo" >> $LOGFILE
echo "Binary-File not found"
exit 1
fi

cp $PWD/sudo /system/bin/ 2>> $LOGFILE
if [ $? != 0 ]; then
echo "[ ! ] Copying Binary to /system/bin (failed)" >> $LOGFILE
echo "Copying failed"
exit 1
fi

echo "Copied Binary file"
echo "[ ! ] Binary File Placed to /system/bin/" >> $LOGFILE

echo "Setting permissions.."
chmod 777 /system/bin/sudo 2>> $LOGFILE
echo "[ ! ] Set permissions to 777 mode" >> $LOGFILE

echo "Executing /system/bin/sudo Every time would be messed up, Do you want us to try and detect any other bin directories in your apps?\n These include termux or any other.\n\n Scan For Other Bins(Apps)?[Y/n]"
echo "[ ! ] Sent input request to user (scanBins)" >> $LOGFILE
read scanBins
echo "[ ! ] Recived user input(scanbins): $scanBins" >> $LOGFILE
if [ "$(echo $scanBins | tr '[:upper:]' '[:lower:]' )" == "y" ]; then
echo "[ - ] ScanBins accepted" >> $LOGFILE
installSudoX
else
echo "[ ! ] ScanBins rejected" >> $LOGFILE
echo "Operation Denied By User."
fi

echo "\n\n\n[ * ] Installation Successful" >> $LOGFILE
echo "\n\n\nSuccessfully Installed Sudo"
echo "run: \"/system/bin/sudo\" to test\nRun \"sudo\" To test"
exit 0
