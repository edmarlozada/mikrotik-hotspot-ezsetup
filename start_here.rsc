# ==============================
# Mikrotik Script to Automate 
# Setup/Config your Mikrotik with
# just simple commands for Beginners.
# Author:
# - Chloe Renae & Edmar Lozada
# - Gcash (0909-3887889)
# Facebook Contact:
# - https://www.facebook.com/chloe.renae.9
# ------------------------------
# IMPORTANT NOTE!!!
# - Port 1 => WAN
# - Port 2 => PC/Laptop Winbox
# How to install:
# - Open file "start_here.txt"
# - Provide the information needed
# - Save this file after editing
# - Drag and Drop all files to winbox terminal
# - Execute the ff. on winbox terminal:
#   import init
#   $install mikrotik_basic
#   $install mikrotik_advance
#   $install hotspot_interface
#   $install hotspot_advance
#   $install hotspot_server
# ------------------------------
/{:put "Loading Config..."

### Internet Service Provider [Globe/Smart/PLDT/Starlink/etc].
:local ISPName    "PLDT"
### IP subnet of LAN "192.168.x.0" & Hotspot "10.0.x.0".
:local IPSubNet   "4"
### hotspot folder path: hex="flash/hotspot" haplite="hotspot".
:local HSFolder   "hotspot"

# === mikrotik winbox username/password ===
:local WinboxUser "winbox_admins"
:local WinboxPass "admins"
:local AdminUser  "admin"
:local AdminPass  "admin"
:local AdminOff   "no"

# === mikrotik wifi (if available) ===
### mikrotik wifi SSID. Edit value below to change.
:local WiFiSSID   "HotSpot.WiFi"
### mikrotik wifi password. Edit value below to change.
:local WiFiPass   "hotspotwifi"

# === telegram (optional if disabled) ===
### enable telegram. 1 if you want to enable telegram.
:local isTelegram  0
### Bot API Token Telebot. Edit value below to change.
:local TGBotToken "xxxxxxxxxx"
### Group Chat ID Login. Edit value below to change.
:local TGrpChatID "xxxxxxxxxx"


# ------------------------------
# Do not edit below this point!
# ------------------------------
{ :local eName "config"
  :local eSource "# $eName #\r
# ------------------------------\r
# Init/Setup/Config/Installer\r
# by: Chloe Renae & Edmar Lozada\r
# ------------------------------\r
:local config {\r
 \"ISPName\"=\"$ISPName\";\r
 \"IPSubNet\"=\"$IPSubNet\";\r
 \"WinboxUser\"=\"$WinboxUser\";\r
 \"WinboxPass\"=\"$WinboxPass\";\r
 \"AdminUser\"=\"$AdminUser\";\r
 \"AdminPass\"=\"$AdminPass\";\r
 \"AdminOff\"=\"$AdminOff\";\r
 \"WiFiSSID\"=\"$WiFiSSID\";\r
 \"WiFiPass\"=\"$WiFiPass\";\r
 \"HSFolder\"=\"$HSFolder\";\r
 \"HSUPName\"=\"hsProfile\";\r
 \"HSServer\"=\"hsServer$IPSubNet\";\r
 \"HSQueue\"=\"queue_hsServer$IPSubNet\";\r
 \"QueueType\"=\"sfq-queue\";\r
 \"isTelegram\"=\"$isTelegram\";\r
 \"TGBotToken\"=\"$TGBotToken\";\r
 \"TGrpChatID\"=\"$TGrpChatID\";\r
 \"BridgePC\"=\"bridge-pc\";\r
 \"BridgeHS\"=\"bridge-hs\";\r
 \"BridgeWAN\"=\"bridge-wan\";\r
 \"edmarlozada\"=\"edmarlozada\"
}\r
:return \$config\r\n"
# ------------------------------
:if ([/system script find name="$eName"]="") do={ /system script add name="$eName" }
/system script set [find name="$eName"] source=$eSource owner=$eName comment="( $eName )"
}
# ------------------------------
}

#:console clear
#/file remove "start_here.txt"
