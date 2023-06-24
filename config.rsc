# ==============================
# mikrotik-hotspot-ezsetup v2.0
# Beginners easy Hotspot setup/config
# script for your mikrotik
# with just simple commands.
# Author:
# - Chloe Renae & Edmar Lozada
# - Gcash (0909-3887889)
# Facebook Contact:
# - https://www.facebook.com/chloe.renae.9
# Before you begin:
# - Port 1 ( WAN )
# - Port 2 ( PC/Laptop Winbox )
# - reset mt w/o default config
# How to install:
# - Edit file "0_start_here.rsc".
# - Provide the needed information.
# - Save this file after editing
# - Drag and Drop all files to winbox terminal
# - Execute each command on winbox terminal:
#   :import installer
#   $install hotspot
#   $install end
# ------------------------------
/{:put "(Config) Processing Config File...";

### Internet Service Provider [Globe/Smart/PLDT/Starlink/etc].
:local ISPName    "XXXX"
### IP subnet of LAN "192.168.x.0" & Hotspot "10.0.x.0".
:local IPSubNet   "4"

# === mikrotik winbox username/password ===
:local WinboxUser "winbox_admin"
:local WinboxPass "admin"
:local AdminUser  "admin"
:local AdminPass  "admin"
:local AdminOff   "no"

# === mikrotik wifi (if available) ===
### mikrotik wifi SSID. Edit value below to change.
:local WiFiSSID   "HotSpot.WiFi"
### mikrotik wifi password. Edit value below to change.
:local WiFiPass   "hotspotwifi"


# ------------------------------
# Do not edit below this point!
# ------------------------------
{ :local eName "cfg-hotspot";
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
 \"BridgeWAN\"=\"bridge-wan\";\r
 \"BridgePC\"=\"bridge-pc\";\r
 \"BridgeHS\"=\"bridge-hs\";\r
 \"HSUPName\"=\"hsProfile\";\r
 \"HSServer\"=\"hsServer$IPSubNet\";\r
 \"HSQueue\"=\"queue_hsServer$IPSubNet\";\r
 \"QueueType\"=\"sfq-queue\";\r
 \"QueueTurb\"=8;\r
 \"edmarlozada\"=\"edmarlozada\"
}\r
:return \$config\r\n";
# ------------------------------
:if ([/system script find name="$eName"]="") do={ /system script add name="$eName" }
/system script set [find name="$eName"] source=$eSource owner=$eName comment="( $eName )"
:put "(Config) /system script => name=[$eName]";
}
# ------------------------------
}
:put "(Config) end...";
