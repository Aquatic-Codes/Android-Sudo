if [ $(id -u) -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

if [ -f $PWD/install.log ]; then
rm $PWD/install.log
touch $PWD/install.log
chmod 777 $PWD/install.log
fi

chmod 777 $PWD/sudo 

echo "Thanks A Lot For Trying Out Sudo By Aquatic"
echo "Feel free to inform bugs at discord: Aquatic Aqral#4534\n\n"
echo "Installing Sudo Binary...\n"

echo "[ - ] Mounting partitions with required permissions..\n" 
echo "[ - ] Mounting partitions with required permissions..\n"  >> $PWD/install.log

mount -o remount,rw /
if [ $? != 0 ]; then
exit 1;
fi
echo "[ ! ] Remounted RootFS(/) To make /system RW\n" >> $PWD/install.log

echo "[ - ] Copying required files..."

cp $PWD/sudo /system/bin/
if [ $? != 0 ]; then
exit 1;
fi
echo "[ ! ] Copied sudo binary to /system/bin/" >> $PWD/install.log

echo "[ * ] Setting permissions.."

chmod 777 /system/bin/sudo
if [ $? != 0 ]; then
exit 1;
fi
echo "[ * ] Set 777 permission to sudo binary.">> $PWD/install.log

echo "[ ! ] Installation Successful!" >> $PWD/install.log

echo "Succesfully Installed Sudo."
echo "Run /system/bin/sudo to execute sudo"
echo "Or place the sudo file anywhere of your choice"
echo "Or run the local sudo file with ./sudo"
echo "Thanks for installing sudo!"
