# ==============================
# Miktrotik HotSpot Router
# by: Chloe Renae & Edmar Lozada
# ==============================
/{put "(Config LAN) Miktrotik HotSpot Router"
local cfg [[parse [/system script get "cfg-hotspot" source]]]

# --- [ Subnet LAN ] --- #
local iIP1st "10"
local iIP2nd "0"
local iIP3rd ($cfg->"IPSubNet")
local iIPBEG "50"
local iIPEND "249"
local iIPNET "$iIP1st.$iIP2nd.$iIP3rd"

# --- [ Bridge LAN ] --- #
local iBrName ($cfg->"BridgeHS")
local iBrNote "bridge ( Hotspot )"


# ==============================
# Interface Bridge
# ------------------------------
if ([/interface bridge find name=$iBrName]="") do={
     /interface bridge  add name=$iBrName}
/interface bridge set [find name=$iBrName] comment=$iBrNote disabled=no
put "(Config LAN) /interface bridge => name=[$iBrName] comment=[$iBrNote]"

# ==============================
# Interface List
# ------------------------------
if ([/interface list find name=LAN]="") do={
     /interface list  add name=LAN}
put "(Config LAN) /interface list (LAN)"

if ([/interface list member find interface=$iBrName]="") do={
     /interface list member  add interface=$iBrName  list=LAN }
/interface list member set [find interface=$iBrName] list=LAN comment=$iBrNote
put "(Config LAN) /interface list member => list=[LAN] interface=[$iBrName] comment=[$iBrNote]"

# ==============================
# Bridge LAN IP-Addresses
# ------------------------------
local iNetwork  "$iIPNET.0"
local iAddress  "$iIPNET.1/24"
if ([/ip address find interface=$iBrName]="") do={
     /ip address  add interface=$iBrName address=$iAddress }
/ip address set [find interface=$iBrName] \
    address=$iAddress \
    network=$iNetwork \
    comment=$iBrNote
put "(Config LAN) /ip address => address=[$iAddress] network=[$iNetwork] interface=[$iBrName]"

# ==============================
# DHCP Server
# ------------------------------
local iDHCPServ "dhcp-hotspot"
local iPoolName "pool_hs_$iIPNET"
local iPoolAddr "$iIPNET.$iIPBEG-$iIPNET.$iIPEND"
if ([/ip pool find name=$iPoolName]="") do={
     /ip pool  add name=$iPoolName  ranges=$iPoolAddr }
/ip pool set [find name=$iPoolName] ranges=$iPoolAddr comment="$iBrName ( Pool )"
put "(Config LAN) /ip pool => name=[$iPoolName] ranges=[$iPoolAddr]"

if ([/ip dhcp-server find interface=$iBrName]="") do={
     /ip dhcp-server  add interface=$iBrName name=$iDHCPServ }
/ip dhcp-server set [find interface=$iBrName] \
    name=$iDHCPServ \
    address-pool=$iPoolName \
    insert-queue-before=bottom \
    lease-time=1d \
    disabled=no
put "(Config LAN) /ip dhcp-server => name=[$iDHCPServ] interface=[$iBrName] pool=[$iPoolName]"

local iGateway  "$iIPNET.1"
local iNetwork  "$iIPNET.0/24"
if ([/ip dhcp-server network find address=$iNetwork]="") do={
     /ip dhcp-server network  add address=$iNetwork }
/ip dhcp-server network set [find address=$iNetwork] \
    gateway=$iGateway \
    comment="$iBrName ( Address & Gateway )"
put "(Config LAN) /ip dhcp-server network => address=[$iNetwork] gateway=[$iGateway] dns-server=[$iGateway]"

# ==============================
# DNS Settings
# ------------------------------
# /ip dns set servers=(208.67.222.222,8.8.8.8,1.1.1.1)
/ip dns set allow-remote-requests=yes
put "(Config LAN) /ip dns => allow-remote-requests=[yes]"

# ==============================
# Mikrotik Clock (Date & Time)
# primary-ntp   = 121.58.193.100 ( dost.gov.ph )
# secondary-ntp = 45.86.70.11 ( 0.asia.pool.ntp.org )
# ------------------------------
/system clock set time-zone-autodetect=no time-zone-name=Asia/Manila
put "(Config LAN) /system clock => time-zone-autodetect=[no] time-zone-name=[Asia/Manila]"

/ip cloud set update-time=no
/system ntp client set enabled=yes \
   primary-ntp=121.58.193.100 \
   secondary-ntp=45.86.70.11 \
   server-dns-names=asia.pool.ntp.org
put "(Config LAN) /system ntp client => primary-ntp=[121.58.193.100] secondary-ntp=[45.86.70.11]"

/system package update set channel=long-term

# ==============================
# Set Systems Logging
# ------------------------------
/system logging set [find topics="info"] disabled=yes
if ([/system logging find topics="script"]="") do={/system logging add topics="script"}
/system logging set [find topics="script"] disabled=no
if ([/system logging find topics="hotspot"]="") do={/system logging add topics="hotspot"}
/system logging set [find topics="hotspot"] disabled=yes
if ([/system logging find topics="hotspot;info"]="") do={/system logging add topics="hotspot,info"}
/system logging set [find topics="hotspot;info"] disabled=no
/system logging action set memory memory-lines=1
/system logging action set memory memory-lines=1000
put "(Config LAN) /system logging => topics=[script] topics=[hotspot] topics=[hotspot;info]"

# ==============================
# User => Name and Password
# ------------------------------
local WinboxUser ($cfg->"WinboxUser")
local WinboxPass ($cfg->"WinboxPass")
if ([/user find name=$WinboxUser]="") do={
      /user  add name=$WinboxUser  password=$WinboxPass group=full }
/user  set [find name=$WinboxUser] password=$WinboxPass group=full comment="Winbox User (Admins)" disabled=no
put "(Config LAN) /user => name=[$WinboxUser]"

# Admin User
/user set [find name=($cfg->"AdminUser")] password=($cfg->"AdminPass")
/user set [find name="admin"] disabled=($cfg->"AdminOff")
put "(Config LAN) /user => name=[admin] disabled=[$($cfg->"AdminOff")]"

# ==============================
# Wireless Profiles
# ------------------------------
if ([/interface wireless find default-name=wlan1]!="") do={
  /interface wireless reset-configuration [find default-name=wlan1]
  local WiFiProf "wsp_wp2_aes"
  if ([/interface wireless security-profiles find name=$WiFiProf]="") do={
       /interface wireless security-profiles add  name=$WiFiProf }
  /interface wireless security-profiles set [find name=$WiFiProf] \
    mode=dynamic-keys \
    group-ciphers=aes-ccm \
    unicast-ciphers=aes-ccm \
    authentication-types=wpa2-psk \
    wpa-pre-shared-key=($cfg->"WiFiPass") \
    wpa2-pre-shared-key=($cfg->"WiFiPass")
  put "(Config LAN) /interface wireless security-profiles => security-profiles=[$WiFiProf] [aes-ccm] [wpa2-psk]"
  /interface wireless set [find default-name=wlan1] \
    mode=ap-bridge \
    wps-mode=disabled \
    wireless-protocol=802.11 \
    band=2ghz-b/g/n \
    channel-width=20/40mhz-eC \
    frequency=auto \
    ssid=($cfg->"WiFiSSID") \
    security-profile=$WiFiProf \
    default-authentication=yes \
    disabled=yes
  put "(Config LAN) /interface wireless => name=[wlan1] ssid=[$($cfg->"WiFiSSID")]"
}

# ==============================
# Interface / Bridge Port
# ------------------------------
foreach iRec in=[/interface ethernet find] do={
  local ether [/interface get $iRec default-name]
  if (($ether!="ether1") and ($ether!="ether2")) do={
    local iCtr  [pick $ether 5 [len $ether]]
    local iEthNote ("$ether ( HotSpot-$iCtr )")
    local ethName [/interface get [find default-name=$ether] name]
    /interface set [find name=$ethName] comment=$iEthNote disabled=no
    put "(Config LAN) /interface => name=[$ethName] comment=[$iEthNote]"
    if ([/interface bridge port find interface=$ethName]="") do={
         /interface bridge port  add interface=$ethName  bridge=$iBrName
         put "(Config LAN) /interface bridge port add => name=[$ethName] bridge=[$iBrName] comment=[$iEthNote]" }
    /interface bridge port set [find interface=$ethName] bridge=$iBrName comment=$iEthNote
    put "(Config LAN) /interface bridge port => name=[$ethName] bridge=[$iBrName] comment=[$iEthNote]"
  }
}

if ([/interface wireless find default-name=wlan1]!="") do={
  local wifiNote ("etherw ( HotSpot-WiFi )")
  local ethName [/interface get [find default-name=wlan1] name]
  /interface wireless set [find name=$ethName] comment=$wifiNote
  put "(Config LAN) /interface wireless => name=[$ethName] comment=[$wifiNote]"
  if ([/interface bridge port find interface=$ethName]="") do={
       put "(Config LAN) /interface bridge port add => name=[$ethName] bridge=[$iBrName] comment=[$wifiNote]"
       /interface bridge port  add interface=$ethName  bridge=$iBrName }
  /interface bridge port set [find interface=$ethName] bridge=$iBrName comment=$wifiNote
  put "(Config LAN) /interface bridge port => name=[$ethName] bridge=[$iBrName] comment=[$wifiNote]"
}

# ------------------------------
put "(3_hotspot_router.rsc) end..."
}
