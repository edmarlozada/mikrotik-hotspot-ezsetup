# ==============================
# Miktrotik Config HotSpot Interface
# by: Chloe Renae & Edmar Lozada
# ==============================
:put "Miktrotik Config HotSpot Interface";

/{:local cfg [[:parse [/system script get "config" source]]]

# --- [ HS Subnet ] --- #
:local HSIPNET ("10.0");
:local HSIPSUB ($cfg->"IPSubNet");
:local HSIPBEG ("50");
:local HSIPEND ("240");

# --- [ Bridge ] --- #
:local BridgeHS     ($cfg->"BridgeHS");
:local BridgeHSNote ("bridge ( HS )");

# --- [ ADDRESS HS ] --- #
:local HSNetwork  ($HSIPNET. "." .$HSIPSUB. ".0");
:local HSAddress  ($HSIPNET. "." .$HSIPSUB. ".1");
:local HSGateway  ($HSIPNET. "." .$HSIPSUB. ".1");

# --- [ DHCP HS ] --- #
:local HSDHCPServ ("dhcp-hs");
:local HSPoolName ("dhcp_pool_hs_" .$HSIPSUB. "." .$HSIPBEG);
:local HSPoolAddr ($HSIPNET. "." .$HSIPSUB. "." .$HSIPBEG. "-" .$HSIPNET. "." .$HSIPSUB. "." .$HSIPEND);


# ==============================
# Interface Bridge
# ------------------------------
:if ([/interface bridge find name=$BridgeHS]="") do={
      /interface bridge  add name=$BridgeHS }
/interface bridge set [find name=$BridgeHS] comment=$BridgeHSNote disabled=no
:put "(Config HS) /interface bridge => name:[$BridgeHS]"

# ==============================
# Interface List
# ------------------------------
# :if ([/interface list find name=LAN]="") do={
#      /interface list  add name=LAN }
# put "(Config HS) /interface list (LAN)"

:if ([/interface list member find interface=$BridgeHS]="") do={
     /interface list member  add interface=$BridgeHS  list=LAN }
     /interface list member set [find interface=$BridgeHS] list=LAN comment=$BridgeHSNote
:put "(Config HS) /interface list member => list:[LAN] interface:[$BridgeHS]"

# ==============================
# BRIDGE HS IP-Addresses
# ------------------------------
:if ([/ip address find interface=$BridgeHS]="") do={
     /ip address  add interface=$BridgeHS address=($HSAddress."/24") }
/ip address set [find interface=$BridgeHS] \
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
# Interface / Bridge Port
# ------------------------------
:local eActive;
:foreach iRec in=[/interface ethernet find] do={
  :if (($iRec!="*1") and ($iRec!="*2")) do={
    :local iCtr  [pick $iRec 1 [:len $iRec]];
    :local ether [/interface ethernet get $iRec default-name];
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
  :local wifiNote ("ether9 ( LAN-HS-WiFi )");
  /interface wireless set [find default-name=wlan1] name=ether9 comment=$wifiNote;
  :put "(Config HS) /interface wireless => name=[wlan1] comment=[$wifiNote]";
  :if ([/interface bridge port find interface=[/interface get [find default-name=wlan1] name]]="") do={
        /interface bridge port  add interface=[/interface get [find default-name=wlan1] name]  bridge=$BridgeHS };
  /interface bridge  port set [find interface=[/interface get [find default-name=wlan1] name]] bridge=$BridgeHS comment=$wifiNote;
  :put "(Config HS) /interface bridge port => name=[wlan1] bridge=[$BridgeHS] comment=[$wifiNote]";
}
:local iRec "*2";
:local iCtr  [pick $iRec 1 [:len $iRec]];
:local ether [/interface ethernet get $iRec default-name];
:local iNote ("$ether ( LAN-HS-$iCtr )");
/interface set $iRec name=$ether comment=$iNote disabled=no;
:put "(Config HS) /interface => name=[$ether] comment=[$iNote]";
:if ([/interface bridge port find interface=$ether]="") do={
      /interface bridge port  add interface=$ether  bridge=$BridgeHS };
/interface bridge  port set [find interface=$ether] bridge=$BridgeHS comment=$iNote;
:put "(Config HS) /interface bridge port => name=[$ether] bridge=[$BridgeHS] comment=[$iNote]";


# ------------------------------
:console clear }
:put "Finishing Up. Wait..."
:delay 10s

