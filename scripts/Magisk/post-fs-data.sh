# Post Fs Data Execution
# Bootloop Preventer
## Max Attempts: 3

MODDIR=${0%/*}

if [ -f $MODDIR/check_reboot ]; then
    for directory in $(find /data/adb/modules/* -type d -prune)
    do
        touch $directory/disable
    done
    reboot
    exit
fi

touch check_reboot