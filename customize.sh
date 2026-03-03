#!/system/bin/sh
#set -e
#set -x

#exec > /data/local/tmp/installer_log.txt 2>&1

# Variables
SKIPMOUNT=false
PROPFILE=true
MONA=true

# Set module directory
MODDIR=${0%/*}
TMPDIR="${TMPDIR:-/dev/tmp}"
MODPATH="${MODPATH:-/data/local/tmp}"
LOG=/sdcard/PixelLauncher.log

# Replacement list
REPLACE="
/system/app/Launcher
/system/priv-app/Lawnchair
/system/priv-app/AsusLauncherDev
/system/priv-app/NothingLauncher3
/system/product/priv-app/ParanoidQuickStep
/system/product/priv-app/ShadyQuickStep
/system/product/priv-app/TrebuchetQuickStep
/system/product/priv-app/NusantaraLauncherQuickStep
/system/product/overlay/PixelLauncherIconsOverlay
/system/product/overlay/CustomPixelLauncherOverlay
/system/product/overlay/ThemedIconsOverlay.apk
/system/product/overlay/PixelLauncherIconsOverlay.apk
/system/product/overlay/CustomPixelLauncherOverlay.apk
/system/product/overlay/Launcher3QuickStep__auto_generated_rro_product.apk
/system/product/overlay/DerpLauncherQuickStep__auto_generated_rro_product.apk
/system/product/overlay/ParanoidLauncherTranslation.apk
/system/product/overlay/ParanoidLauncherOverlay.apk
/system/product/overlay/Launcher3Overlay.apk
/system/product/overlay/DerpLauncherOverlay.apk
/system/system_ext/priv-app/NusantaraLauncherQuickStep
/system/system_ext/priv-app/DerpLauncherQuickStep
/system/system_ext/priv-app/DerpThemePicker
/system/system_ext/priv-app/TrebuchetQuickStep
/system/system_ext/priv-app/Lawnchair
/system/system_ext/priv-app/ArrowLauncher
/system/system_ext/priv-app/ParanoidQuickStep
/system/system_ext/priv-app/ParanoidThemePicker
/system/system_ext/priv-app/Launcher3QuickStep
/system/system_ext/priv-app/Launcher3QuickStepMock
/system/system_ext/priv-app/WallpaperPickerGoogleRelease
/system/system_ext/priv-app/ThemePicker
/system_ext/priv-app/AfterHomeQuickStep
/system/product/priv-app/AfterHomeQuickStep
/system_ext/priv-app/AfterHomeQuickStep
/system_ext/priv-app/ThemePicker
/system_ext/priv-app/Launcher3QuickStep
"

# Variables
MODNAME=$(grep_prop name "$TMPDIR/module.prop")
MODVER=$(grep_prop version "$TMPDIR/module.prop")
DV=$(grep_prop author "$TMPDIR/module.prop")

Device=$(getprop ro.product.device)
Model=$(getprop ro.product.model)
Brand=$(getprop ro.product.brand)
Manufacturer=$(getprop ro.product.system.manufacturer)
Architecture=$(getprop ro.product.cpu.abi)
SDK=$(getprop ro.system.build.version.sdk)
ABI=$(getprop ro.system.product.cpu.abilist)
Android=$(getprop ro.system.build.version.release)
Type=$(getprop ro.system.build.type)
Built=$(getprop ro.system.build.date)
Time=$(date "+%d, %b - %H:%M %Z")
FINGERPRINT=$(getprop ro.system.build.fingerprint)
ID=$(getprop ro.system.build.id)
BTAG=$(getprop ro.system.build.tags)
BVER=$(getprop ro.system.build.version.incremental)
SP=$(getprop ro.build.version.security_patch)
HOST=$(getprop ro.build.host)
FBE=$(getprop ro.crypto.state)
FLAVOUR=$(getprop ro.build.flavor)
LOCALE=$(getprop ro.product.locale)
BT=$(getprop bt.max.hfpclient.connections)
CHIPSET=$(getprop ro.device.chipset)
DISPLAY=$(getprop ro.device.display_resolution)
NETFLIX=$(getprop ro.netflix.bsp_rev)
NFC=$(getprop ro.nfc.port)
MAINTAINER=$(getprop ro.device.maintainer)
CID=$(getprop ro.com.google.clientidbase)
SE=$(getenforce)

# Logger
debug() {
    echo "$1" | tee -a "$LOG"
}
  
# Installation starts
debug " " 
debug "-------------------------------------"
debug "- Fetching module info..."
debug "-------------------------------------"
debug "- Author: $DV"
debug "- Module：$MODNAME"
debug "- Version：$MODVER"

if [ "$BOOTMODE" ] && [ "$KSU" ]; then
echo -n "- Provider："
echo -n "KernelSU：$KSU_KERNEL_VER_CODE (kernel) + $KSU_VER_CODE (ksud)"
debug " " 
  if [ "$(which magisk)" ]; then
    debug "-----------------------------------------------------------"
    debug "! Multiple root implementation is NOT supported!"
    abort "-----------------------------------------------------------"
  fi
elif [ "$BOOTMODE" ] && [ "$MAGISK_VER_CODE" ]; then
echo -n "- Provider：💀 Magisk app"
debug " " 
else
debug "--------------------------------------------------------"
debug "Installation from recovery is not supported"
debug "Please install from KernelSU / Magisk or Apatch app"
  abort "--------------------------------------------------------"
fi

# Device Info
debug " " 
debug "-------------------------------------"
debug "- Fetching Device info..."
debug "-------------------------------------"
sleep 1
debug "- Brand Name：$Brand"
debug "- Device Name：$Device"
debug "- Model Name：$Model"
debug "- Device Manufacturer: $Manufacturer"
debug "- RAM：$(free | grep Mem | awk '{print $2}')"

# ROM Info
debug " " 
debug "-------------------------------------"
debug "- Fetching ROM info..."
debug "-------------------------------------"
sleep 1
debug "- Security Patch：$SP"
debug "- Data Encryption：$FBE"
debug "- Build ID：$ID"
debug "- Build Tag：$BTAG"
debug "- Build Flavour：$FLAVOUR"
debug "- ROM Build Date：$Built"
debug "- ROM Build Type：$Type"

# System Info
debug " " 
debug "-------------------------------------"
debug "- Fetching System info..."
debug "-------------------------------------"
sleep 1
debug "- SE Linux Status：$SE"
debug "- Privilege：$ROOT"
debug "- Default Language：$LOCALE"
debug "- Client ID：$CID"
debug "- ABI SUPPORT：$ABI"
debug "- Android Version：$Android"
debug "- Kernel: $(uname -r)"
debug "- CPU Architecture：$Architecture"
debug "- SDK Version：$SDK"

debug " " 
debug "-------------------------------------"
debug "- Optimising $MODNAME⚡"
debug "-------------------------------------"
debug " "
debug "- Redirecting to release source..."
debug "This module was released by 𝗠𝗘𝗢𝗪 𝗗𝗨𝗠𝗣"
nohup am start -a android.intent.action.VIEW -d https://t.me/MeowRedirect >/dev/null 2>&1 &
sleep 3

sleep 1 && debug "Always download modules from release source"