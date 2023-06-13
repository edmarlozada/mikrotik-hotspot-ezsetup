# ==============================
# Miktrotik HotSpot Router
# by: Chloe Renae & Edmar Lozada
# ==============================
/{:put "(HotSpot) Miktrotik HotSpot Router";

:local cfg [[:parse [/system script get "cfg-hotspot" source]]]

# --- [ HS Subnet ] --- #
:local HSIPNET ("10.0");
:local HSIPSUB ($cfg->"IPSubNet");
:local HSIPBEG ("50");
:local HSIPEND ("240");

# --- [ HS Bridge ] --- #
:local BridgeHS     ($cfg->"BridgeHS");
:local BridgeHSNote ("bridge ( HS )");

# --- [ HS Address ] --- #
:local HSNetwork  ($HSIPNET. "." .$HSIPSUB. ".0");
:local HSAddress  ($HSIPNET. "." .$HSIPSUB. ".1");
:local HSGateway  ($HSIPNET. "." .$HSIPSUB. ".1");

# --- [ HS DHCP ] --- #
:local HSDHCPServ ("dhcp-hs");
:local HSPoolName ("dhcp_pool_hs_" .$HSIPSUB. "." .$HSIPBEG);
:local HSPoolAddr ($HSIPNET. "." .$HSIPSUB. "." .$HSIPBEG. "-" .$HSIPNET. "." .$HSIPSUB. "." .$HSIPEND);


# ==============================
# Interface Bridge
# ------------------------------
:if ([/interface bridge find name=$BridgeHS]="") do={
      /interface bridge  add name=$BridgeHS }
/interface bridge  set [find name=$BridgeHS] comment=$BridgeHSNote disabled=no
:put "(Config HS) /interface bridge => name:[$BridgeHS]"

# ==============================
# Interface List
# ------------------------------
:if ([/interface list find name=LAN]="") do={
     /interface list  add name=LAN }
:put "(Config HS) /interface list (LAN)"

:if ([/interface list member find interface=$BridgeHS]="") do={
     /interface list member  add interface=$BridgeHS  list=LAN }
     /interface list member set [find interface=$BridgeHS] list=LAN comment=$BridgeHSNote
:put "(Config HS) /interface list member => list:[LAN] interface:[$BridgeHS]"

# ==============================
# BRIDGE HS IP-Addresses
# ------------------------------
:if ([/ip address find interface=$BridgeHS]="") do={
      /ip address  add interface=$BridgeHS address=($HSAddress."/24") }
/ip address set  [find interface=$BridgeHS] \
    address=($HSAddress."/24") \
    network=$HSNetwork \
    comment=$BridgeHSNote
:put "(Config HS) /ip address => address:[$HSAddress] network:[$HSNetwork] interface:[$BridgeHS]"

# ==============================
# DHCP Server
# ------------------------------
:if ([/ip pool find name=$HSPoolName]="") do={
     /ip pool  add name=$HSPoolName  ranges=$HSPoolAddr }
/ip pool set [find name=$HSPoolName] ranges=$HSPoolAddr comment="$HSPoolName $HSPoolAddr"
:put "(Config HS) /ip pool => name:[$HSPoolName] ranges:[$HSPoolAddr]"

:if ([/ip dhcp-server find interface=$BridgeHS]="") do={
     /ip dhcp-server  add interface=$BridgeHS name=$HSDHCPServ }
/ip dhcp-server set [find interface=$BridgeHS] \
    name=$HSDHCPServ \
    address-pool=$HSPoolName \
    insert-queue-before=bottom \
    lease-time=1d \
    disabled=no
:put "(Config HS) /ip dhcp-server => name:[$HSDHCPServ] interface:[$BridgeHS] pool:[$HSPoolName]"

:if ([/ip dhcp-server network find address=($HSNetwork."/24")]="") do={
     /ip dhcp-server network  add address=($HSNetwork."/24") }
/ip dhcp-server network set [find address=($HSNetwork."/24")] \
    gateway=$HSGateway \
    dns-server=$HSGateway \
    comment="$HSDHCPServ (Address & Gateway)"
:put "(Config HS) /ip dhcp-server network => address:[$HSNetwork] gateway:[$HSGateway] dns-server:[$HSGateway]"

# ==============================
# Mikrotik Clock (Date & Time)
# primary-ntp   = 121.58.193.100 ( dost.gov.ph )
# secondary-ntp = 45.86.70.11 ( 0.asia.pool.ntp.org )
# ------------------------------
/system clock set time-zone-autodetect=no time-zone-name=Asia/Manila
:put "(Config) /system clock => time-zone-autodetect:[no] time-zone-name:[Asia/Manila]"

/ip cloud set update-time=no
/system ntp client set enabled=yes \
   primary-ntp=121.58.193.100 \
   secondary-ntp=45.86.70.11 \
   server-dns-names=asia.pool.ntp.org
:put "(Config) /system ntp client => primary-ntp:[121.58.193.100] secondary-ntp:[45.86.70.11]"

/system package update set channel=long-term

# ==============================
# Set Systems Logging
# ------------------------------
/system logging action set memory memory-lines=1
/system logging action set memory memory-lines=1000
/system logging set [find topics="info"] disabled=yes
:if ([/system logging find topics="script"]="")       do={/system logging add topics="script"}
/system logging set [find topics="script"] disabled=no
:if ([/system logging find topics="hotspot"]="")       do={/system logging add topics="hotspot"}
/system logging set [find topics="hotspot"] disabled=yes
:if ([/system logging find topics="hotspot;info"]="") do={/system logging add topics="hotspot,info"}
/system logging set [find topics="hotspot;info"] disabled=no
:put "(Config) /system logging => topics:[script] topics:[hotspot] topics:[hotspot;info]"

# ==============================
# DNS Settings
# ------------------------------
# /ip dns set servers=(208.67.222.222,8.8.8.8,1.1.1.1)
/ip dns set allow-remote-requests=yes
:put "(Config) /ip dns => allow-remote-requests:[yes]"

# ==============================
# User => Name and Password
# ------------------------------
local WinboxUser ($cfg->"WinboxUser")
local WinboxPass ($cfg->"WinboxPass")
:if ([/user find name=$WinboxUser]="") do={
      /user  add name=$WinboxUser  password=$WinboxPass group=full }
/user  set [find name=$WinboxUser] password=$WinboxPass group=full comment="Winbox User (Admins)" disabled=no
:put "(Config) /user => name:[$WinboxUser]"

# Admin User
/user set [find name=($cfg->"AdminUser")] password=($cfg->"AdminPass")
/user set [find name="admin"] disabled=($cfg->"AdminOff")
:put "(Config) /user => name:[admin] disabled:[$($cfg->"AdminOff")]"

# ==============================
# Wireless Profiles
# ------------------------------
:if ([/interface wireless find default-name=wlan1]!="") do={
  /interface wireless reset-configuration [find default-name=wlan1]
  /interface wireless set [find default-name=wlan1] \
    mode=ap-bridge \
    wps-mode=disabled \
    wireless-protocol=802.11 \
    band=2ghz-b/g/n \
    channel-width=20/40mhz-eC \
    frequency=auto \
    disabled=no
  /interface wireless set [find default-name=wlan1] \
    ssid=($cfg->"WiFiSSID")
  :put "(Config) /interface wireless => name:[wlan1] ssid:[$($cfg->"WiFiSSID")]"
}

# ==============================
# Interface / Bridge Port
# ------------------------------
:foreach iRec in=[/interface ethernet find] do={
  local ether [/interface get $iRec default-name];
  :if (($ether!="ether1") and ($ether!="ether2")) do={
    :local iCtr  [pick $ether 5 [:len $ether]];
    :local iNote ("$ether ( LAN-HS-$iCtr )");
    /interface set $iRec name=$ether comment=$iNote disabled=no;
    :put "(Config HS) /interface => name=[$ether] comment=[$iNote]";
    :if ([/interface bridge port find interface=$ether]="") do={
          /interface bridge port  add interface=$ether  bridge=$BridgeHS };
    /interface bridge  port set [find interface=$ether] bridge=$BridgeHS comment=$iNote;
    :put "(Config HS) /interface bridge port => name=[$ether] bridge=[$BridgeHS] comment=[$iNote]";
  }
}
:if ([/interface wireless find default-name=wlan1]!="") do={
  :local wifiNote ("etherw ( LAN-HS-WiFi )");
  /interface wireless set [find default-name=wlan1] name=etherw comment=$wifiNote;
  :put "(Config HS) /interface wireless => name=[wlan1] comment=[$wifiNote]";
  :if ([/interface bridge port find interface=[/interface get [find default-name=wlan1] name]]="") do={
        /interface bridge port  add interface=[/interface get [find default-name=wlan1] name]  bridge=$BridgeHS };
  /interface bridge  port set [find interface=[/interface get [find default-name=wlan1] name]] bridge=$BridgeHS comment=$wifiNote;
  :put "(Config HS) /interface bridge port => name=[wlan1] bridge=[$BridgeHS] comment=[$wifiNote]";
}

# ------------------------------
:put "(3_hotspot_router.rsc) end...";
}
