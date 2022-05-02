# Uninstall

ui_print "Uninstalling Seroid Completely"

mkdir /data/adb/Clearsudo/
mv /data/adb/Seroid/sudo* /data/adb/Clearsudo/
mv /data/adb/Seroid/Seroid.conf /data/adb/Clearsudo/
rm -rf /data/adb/Seroid/*
rm -rf /data/adb/modules/Seroid_sudo/*

ui_print "Execute /data/adb/Clearsudo/sudo --remove"
ui_print "Base uninstalling finished"