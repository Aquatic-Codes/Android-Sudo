# 
# This is a magisk module.
# 
# This file won't be shipped with classic install
# 
### Copyrights (c) Chaturya - Seroid
### Download only from offical github page
#
# 
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#
# /LICENSE.md for more information
#

SKIPUNZIP=1
# Do not install from recovery
confirm_not_recovery() {
    if $BOOTMODE; then
        ui_print "* Seroid Installer *"
    else
        ui_print "Installing from recoveries is not supproted"
        abort "Use the Update Script Instead."
    fi
}

confirm_not_recovery

ui_print "Installating Seroid To /system/bin"

ui_print "Placing Files.."

# We will try to place local sudo binary
# So that the versions will not vary

mkdir -p $MODPATH/system/bin/

cp /data/adb/Seroid/sudo.aarch64 $MODPATH/system/bin/sudo

if [ "$?" != 0 ]; then
    # If attempt fails, install the availabe
    # Sudo binary in zip, mostly latest version
    unzip -o "$ZIPFILE" 'binary' -d "$MODPATH/system/bin/sudo" &> /dev/null
    if [ "$?" != 0 ]; then
        # All attempts failed.
        abort "Unable to place files"
    else
        ui_print "Inflated Sudo Binary"
    fi
else
    ui_print "Copied local(installed) sudo version"
fi

unzip -o "$ZIPFILE" 'module.prop' -d "$MODPATH" &> /dev/null
unzip -o "$ZIPFILE" 'guide.md' -d "$MODPATH" &> /dev/null
ui_print "Inflated Guide"
unzip -o "$ZIPFILE" 'LICENSE' -d "$MODPATH" &> /dev/null
unzip -o "$ZIPFILE" 'post-fs-data.sh' -d "$MODPATH" &> /dev/null
if [ "$?" != 0 ]; then
    abort "Error inflating post fs data script"
else
    ui_print "Inflated post-fs-data.sh"
fi
unzip -o "$ZIPFILE" 'service.sh' -d "$MODPATH" &> /dev/null
if [ "$?" != 0 ]; then
    abort "Error inflating late start service script"
else
    ui_print "Inflated service.sh"
fi

ui_print "*Installation Successfull*"
