#!/system/bin/sh

### Seroid Updater Script

if [ "$(id -u)" != 0 ]; then
ls / 2> /dev/null
if [ "$?" != 0 ]; then
exec su -c /system/bin/sh $(readlink -f $0) "$@"
exit 1
fi
fi

PATH="$(echo $PATH | grep -v data):/sbin:/sbin/su:/su/bin:/su/xbin:/system/bin:/system/xbin:"
clear

help() {
    
    echo "Seroid Updater Script - 1.0\
    \n\nOptions\
    \n  --system        Installs sudo to system/bin running android 11 and below. Script must run from recovery.\
    \n      Sub Option for system\n--system-a12     Installs sudo to system/bin from recovery for devices running android 12 and above.\n--patch-system          Patches specified file with sudo binary to install from recovery.\n--system-os     Install sudo to system/bin while booted into system instead of recovery. Mostly magisk will undo the changes after reboot. Works for all android versions.\
    \n  --reinstall         Executes /data/adb/Seroid/.install\
    \n  --install-binary        Install Specified Binary and Replaces the Previous one"
    
    exit $1
    
}

install_system() {
    
    if [ -z "$1" ]; then
        echo "Script error."
        echo "To fix, please verify that inside install_system_a12 function (120) under first if statement (126) is having code 12 and the else (128) has code 0.\nAlso check if Option parser option 3 (186) has code 11."
        exit 1
    fi
    
    if [ "$1" -ne 0 ] && [ "$1" -ne 12 ] && [ "$1" -ne 11 ]; then
        echo "Script error."
        echo "To fix, please verify that inside install_system_a12 function (120) under first if statement (126) is having code 12 and the else (128) has code 0.\nAlso check if Option parser option 3 (186) has code 11."
        exit 1
    fi
    
    if [ "$1" -eq 0 ]; then
        echo "Cancelling Installation."
        exit 1
    fi
    
    if [ "$1" -eq 9 ]; then
        echo "Installating Binary In Os"
        start=$(date +%s%N)
        echo "Mounting System Read-Write"
        
        ERR=/data/adb/Seroid/.errors/
        
        mount -o remount,rw / 2> $ERR/.mount
        
        if [ "$?" -ne 0 ]; then
            echo "Mounting error."
            cat $ERR/.mount
            rm -rf $ERR
            exit 1
        fi
        
        mount -o remount,rw /system
        
        cp /data/adb/Seroid/sudo.aarch64 /system/bin/sudo
        chmod 775 /system/bin/sudo
        chown root:root /system/bin/sudo
        
        mount -o remount,ro / 2> $ERR/.remount
        
        if [ "$?" -ne 0 ]; then
            echo "Remounting error."
            cat $ERR/.mount
            rm -rf $ERR
            echo "Execute: \"mount -o remount,ro /\" in a root shell or reboot device."
            exit 1
        fi
        
        mount -o remount,ro /system 2> /dev/null
        rm -rf $ERR 2> /dev/null
        end=$(date +%s%N)
        echo "Finished Installing.\nDone in $(expr $(expr $end - $start) / 1000000000) Second(s)"
        
        exit 0
        
    fi
    
    INSTALL_LOCATION="/system/bin/"
    
    if [ "$1" -eq 12 ]; then
        INSTALL_LOCATION="/system_root/system/bin/"
    fi
    
    echo "Enter 0 if your data partition is decrypted, Enter 1 if it isn't and Enter any 6 if you have patched the system."
    read state
    
    if [ "$state" -eq 1 ]; then
        echo "Please reboot to system and enter su -c sh /data/adb/Seroid/update.sh --patch-system"
        exit 1
    elif [ "$state" -eq 6 ]; then
    
        echo "Please Enter The File Location You Have Patched(/system/): "
        read PATCH
        
        if [ "$(echo $PATCH | cut -d / -f 2)" != "system" ]; then
        PATCH="/system/$PATCH"
        fi
        
        if [ ! -f $PATCH ]; then
            echo "Patch doesn't seem to be at $PATCH"
            exit 1
        fi
        
        $PATCH --test-patch 2> /dev/null
        
        if [ "$?" -ne 110 ]; then
            echo "Patch is incorrect. Not a valid patch.\nMake sure magisk doesn't revert the changes and you don't have systemless hosts module."
            exit 1
        fi
        
        cp -r $PATCH $INSTALL_LOCATION/sudo
        chmod 775 $INSTALL_LOCATION/sudo
        chown root:root $INSTALL_LOCATION/sudo
        
        if [ "$?" -ne 0 ]; then
            echo "Fatal: Copying error."
            exit 1
        fi
        
        echo "Install successful."
        echo "Clearing console in 3 seconds"
        sleep 3
        clear
        echo "Rebooting device in 5 seconds"
        sleep 5
        reboot
        
    elif [ "$state" -eq 0 ]; then
        
        echo "Using /data"
        
        cp -r /data/adb/Seroid/sudo.aarch64 $INSTALL_LOCATION/sudo
        chmod 775 $INSTALL_LOCATION/sudo
        chown root:root $INSTALL_LOCATION/sudo
        
        if [ "$?" -ne 0 ]; then
            echo "Fatal: Copying error."
            exit 1
        fi
        
        echo "Install successful."
        echo "Clearing console in 3 seconds"
        sleep 3
        clear
        echo "Rebooting device in 5 seconds"
        sleep 5
        reboot
        
    else
        echo "Invalid Selection $state."
        exit 1
    fi
    
}

install_system_os() {
    
    echo "These system changes will be reverted by magisk on every boot. Enter 0 To proceed."
    read proceed
    
    if [ proceed -ne 0 ]; then
        echo "Cancelling Installation."
    fi
    
    install_system 9
    
}

patch_system() {
    
    start=$(date +%s%N)
    
    echo "System Patching Utility"
    echo "Best files to patch\n/system/etc/hosts\n/system/etc/mkshrc"
    echo "Enter the file to patch (/system/)"
    read PATCHFILE
    
    if [ "$(echo $PATCHFILE | cut -d / -f 2)" != "system" ]; then
        PATCHFILE="/system/$PATCHFILE"
    fi
    
    if [ ! -f $PATCHFILE ]; then
        echo "File Not Found $PATCHFILE"
        exit 1
    fi
    
    echo "Patching $PATCHFILE"
    
    if [ ! -f /data/adb/Seroid/sudo.aarch64 ]; then
        echo "Binary file not Found"
        echo "Expected location /data/adb/Seroid/sudo.aarch64"
        exit 1
    fi
    
    $ERRDIR=/data/adb/Seroid/.errors/.tmp/
    
    mkdir /data/adb/Seroid/.errors/
    mkdir $ERRDIR
    
    mount -o remount,rw / 2> $ERRDIR/.mount
    
    if [ "$?" -ne 0 ]; then
        echo "Mounting Read-Write Error"
        cat $ERRDIR/.mount
        rm -rf /data/adb/Seroid/.errors/ 2> /dev/null
        exit 1
    fi
    
    mount -o remount,rw /system 2> /dev/null
    
    cp -r $PATCHFILE /data/adb/Seroid/$PATCHFILE.patch
    cp /data/adb/Seroid/sudo.aarch64 $PATCHFILE 2> $ERRDIR/.cp
    
    if [ "$?" -ne 0 ]; then
        echo "Patching File Error"
        cat $ERRDIR/.cp
        rm -rf /data/adb/Seroid/.errors/ 2> /dev/null
        exit 1
    fi
    
    mount -o remount,ro / 2> $ERRDIR/.romount
    
    if [ "$?" -ne 0 ]; then
        echo "Mounting Read-Only Error"
        cat $ERRDIR/.romount
        rm -rf /data/adb/Seroid/.errors/ 2> /dev/null
        echo "Execute: \"mount -o remount,ro /\" in a root shell or reboot device."
        exit 1
    fi
    
    mount -o remount,ro /system 2> /dev/null
    rm -rf /data/adb/Seroid/.errors/ 2> /dev/null
    
    end=$(date +%s%N)
    
    echo "Patched System Successfully.\n*Finished In $(expr $(expr $end - $start) / 1000000000) Second(s)*"
    
    exit 0
    
}

install_binary() {
    
    start=$(date +%s%N)
    
    TMPPATH=/data/adb/Seroid/tmp/
    
    if [ ! -f $BINARYPATH ]; then
        echo "File not found $BINARYPATH"
        exit 1
    fi
    echo "Installating $BINARYPATH"
    
    chmod 770 $BINARYPATH
    chown root:root $BINARYPATH
    mv $BINARYPATH $TMPPATH/binaryfile
    EXEC_FILE=$TMPPATH/binaryfile
    
    su -c find /data/data -name 'bin' >> $TMPPATH/bins
    
    while read line
    do
    
    cp $EXEC_FILE $line/sudo 2> /dev/null
    chown $(ls -ld $line 2> /dev/null | cut -d " " -f 3):$(ls -ld $line 2> /dev/null | cut -d " " -f 3) $line/sudo 
    
    done < $TMPPATH/bins
    
    rm -rf $TMPPATH/*
    
    end=$(date +%s%N)
    
    echo "Finished in $(expr $(expr $end - $start) / 1000000000) Second(s)"
    
}

reinstall() {
    
    cd /data/adb/Seroid/
    
    TYPE=0
    
    if [ ! -f /data/adb/Seroid/.install ]; then
        TYPE=1
    fi
    
    if [ $TYPE -eq 0 ]; then
        mkdir /data/adb/Seroidinstalltmp/
        chmod 770 /data/adb/Seroid/.install
        chown root:root /data/adb/Seroid/.install
        cp /data/adb/Seroid/.install /data/adb/Seroidinstalltmp/install.sh
        mkdir /data/adb/Seroidinstalltmp/binaries/
        cp /data/adb/Seroid/sudo.aarch64 /data/adb/Seroidinstalltmp/binaries/sudo.aarch64 2> /dev/null
        if [ "$?" -ne 0 ]; then
            echo "Binary not found. Attempting to find a copy of binary from anywhere."
            su -c find /data -name 'sudo' >> /data/adb/Seroid/sudo.files
            SUCCESS=0
            while read line
            do
                cp $line /data/adb/Seroidinstalltmp/binaries/sudo.aarch64
                if [ "$?" -eq 0 ]; then
                    SUCCESS=1
                    break
                fi
            done < sudo.files
            
            if [ "$SUCCESS" -ne 1 ]; then
                echo "Fatal: No binary found to reinstall.\nUse --install-binary to install binary from Specified location."
                exit 1
            fi
        fi
        . /data/adb/Seroid/Seroid.conf
        echo "Removing Old Files.."
        rm -rf $DATA_DIR
        while read line
        do
            STDOUTFILE=/data/adb/Seroidinstalltmp/conf
            if [ "$line" == "# Install Time Configs" ]; then
                echo "# Install Time Configs" >> $STDOUTFILE
                break
            fi
            echo $line >> $STDOUTFILE
        done < Seroid.conf
        cd /data/adb/Seroidinstalltmp/
        su -c sh /data/adb/Seroidinstalltmp/install.sh && rm -rf /data/adb/Seroidinstalltmp/
    fi
    
}

install_system_a12() {
    
    echo "Modifiying System Partition in Recovery for Android Versions 12 And Above Would Have High Chances To Create A Boot Loop. Proceed?[Y/n]"
    read proceed
    
    if [ $proceed == "y" ] || [ $proceed == "Y" ]; then
        install_system 12
    else
        install_system 0
    fi
    
}

if [ "$#" -lt 1 ]; then
help 1
fi

BINARYPATH=
OPTION=0

while [ $# -ge 1 ]; do
    case "$1" in
        --install-binary )
            shift
            BINARYPATH="$1"
            OPTION=1
            break
            ;;
        --reinstall )
            shift
            OPTION=2
            break
            ;;
        --system )
            shift
            OPTION=3
            break
            ;;
        --system-os )
            shift
            OPTION=9
            break
            ;;
        --system-a12 )
            shift
            OPTION=4
            break
            ;;
        --patch-system )
            shift
            OPTION=8
            break
            ;;
        --)
            # No more options left.
            shift
            break
            ;;
    esac
  shift
done

if [ $OPTION -eq 1 ]; then
    install_binary $BINARYPATH
elif [ $OPTION -eq 2 ]; then
    reinstall
elif [ $OPTION -eq 9 ]; then
    install_system_os
elif [ $OPTION -eq 4 ]; then
    install_system_a12
elif [ $OPTION -eq 3 ]; then
    install_system 11
elif [ "$OPTION" -eq 8 ]; then
    patch_system
else
    help
fi